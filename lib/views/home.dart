import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:drive_recorder/conponents/alert_dialog.dart';
import 'package:drive_recorder/conponents/drawer_view.dart';
import 'package:drive_recorder/conponents/db_helper.dart';
import 'package:sqflite/sqflite.dart' as sql;

// 定义主页类 HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 定义主页状态类，继承自主页类
class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late VlcPlayerController _videoPlayerController;
  static const _cachingMs = 500;
  String rtspAddr = 'rtsp://192.168.169.1';
  String buttonText = '点此连接设备';
  bool showButton = false;

  Future<void> initializePlayer() async {} // 初始化视频播放器

  @override
  void initState() {
    super.initState();
    initVlc();
  }

  void initVlc() {
    // 初始化 _videoPlayerController
    _videoPlayerController = VlcPlayerController.network(
      'rtsp://192.168.169.1',
      hwAcc: HwAcc.full,
      autoPlay: false,
      allowBackgroundPlayback: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.fileCaching(_cachingMs),
          VlcAdvancedOptions.networkCaching(_cachingMs),
          VlcAdvancedOptions.liveCaching(_cachingMs),
          VlcAdvancedOptions.clockSynchronization(0),
          VlcAdvancedOptions.clockJitter(_cachingMs),
        ]),
        audio: VlcAudioOptions([VlcAudioOptions.audioTimeStretch(true)]),
        video: VlcVideoOptions(
          [
            VlcVideoOptions.dropLateFrames(false), // 确保不跳过帧
            VlcVideoOptions.skipFrames(false) // 确保不跳过帧
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning(); // 停止扫描渲染器
    await _videoPlayerController.dispose(); // 释放资源
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    HttpRequest http = HttpRequest(context);
    Map<String, dynamic> deviceInfo = {
      'device_name': '',
      'device_ip': '192.168.169.1',
      'last_connected_time': '',
      'connected_count': 0,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        centerTitle: true,
      ),
      drawer: const DrawerView(),
      body: Center(
          child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: VlcPlayer(
              controller: _videoPlayerController,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.grey, color: Colors.blue)),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  http.getHttp('app/getproductinfo').then((result) {
                    if (result['result'] == 0) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('找到可用设备'),
                              content: Text(
                                  '设备名称：${result['info']['model']}\n设备厂商：${result['info']['company']}\n设备SOC：${result['info']['soc']}\n设备SP：${result['info']['sp']}'),
                              actions: [
                                TextButton(
                                  child: const Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('确认连接'),
                                  onPressed: () {
                                    http.getHttp('app/getdeviceattr');
                                    http.getHttp(
                                        'app/setsystime?date${DateTime.now().toString()}');
                                    http.getHttp('app/enterrecorder');
                                    http
                                        .getHttp('app/getmediainfo')
                                        .then((rtsp) {
                                      rtspAddr = rtsp['info']['rtsp'];
                                      print(rtspAddr);
                                    });
                                    http.getHttp('app/getparamvalue?param=rec');
                                    _videoPlayerController.play();
                                    deviceInfo['device_name'] =
                                        result['info']['model'];
                                    deviceInfo['last_connected_time'] =
                                        DateTime.now().toString();
                                    deviceInfo['connected_count'] =
                                        deviceInfo['connected_count'] + 1;
                                    showButton = true;
                                    setState(() {
                                      buttonText = result['info']['model'];
                                    });
                                    Get.snackbar('恭喜！', '已成功连接到行车记录仪',
                                        icon: const Icon(Icons.link));
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return const MyAlertDialog(
                                // 自定义提示对话框
                                title: '没有找到设备！',
                                content: '请检查wifi是否连接正确，或尝试重新连接设备。');
                          });
                    }
                  });
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              const Icon(
                Icons.link,
                color: Colors.blueGrey,
              )
            ],
          ),
        ],
      )),
      floatingActionButton: showButton
          ? Column(
              // 浮动操作按钮
              mainAxisAlignment: MainAxisAlignment.end, // 主轴对齐方式
              children: [
                FloatingActionButton(
                  child: const Icon(Icons.camera),
                  onPressed: () {
                    http.getHttp('app/snapshot').then((result) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return MyAlertDialog(
                                // 自定义提示对话框
                                title: '拍摄成功！',
                                content: result['info']);
                          });
                    });
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                    // 浮动操作按钮
                    child: const Icon(Icons.output_rounded),
                    onPressed: () {
                      http.getHttp('app/exitrecorder');
                      _videoPlayerController.pause();
                      rtspAddr = '';
                      buttonText = '点此连接设备';
                      setState(() {
                        showButton = false;
                      });
                    }),
              ],
            )
          : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
