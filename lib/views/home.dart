import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:drive_recorder/conponents/alert_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drive_recorder/conponents/drawer_view.dart';
import 'package:drive_recorder/main.dart';
import 'package:drive_recorder/views/photo.dart';
import 'package:drive_recorder/views/settings.dart';
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
  Map<String, dynamic> deviceInfo = {
    'device_name': '',
    'device_ip': '192.168.169.1',
    'last_connected_time': '',
    'connected_count': 0,
  };

  Future<void> initializePlayer() async {} // 初始化视频播放器

  @override
  void initState() {
    super.initState();
    initCam();
    initVlc();
  }

  void initCam() async {
    HttpRequest http = HttpRequest();
    http.getHttp('app/getdeviceattr');
    http.getHttp('app/setsystime?date${DateTime.now().toString()}');
    http.getHttp('app/enterrecorder');
    http.getHttp('app/getmediainfo').then((rtsp) {
      rtspAddr = rtsp['info']['rtsp'];
      print(rtspAddr);
    });
    http.getHttp('app/getparamvalue?param=rec');
    _videoPlayerController.play();
    // deviceInfo['device_name'] = result['info']['model'];
    deviceInfo['last_connected_time'] = DateTime.now().toString();
    deviceInfo['connected_count'] = deviceInfo['connected_count'] + 1;
    showButton = true;
    // setState(() {
    //   buttonText = result['info']['model'];
    // });
    Get.snackbar('恭喜！', '已成功连接到行车记录仪', icon: const Icon(Icons.link));
  }

  void initVlc() {
    // 初始化 _videoPlayerController
    _videoPlayerController = VlcPlayerController.network(
      'rtsp://192.168.169.1',
      hwAcc: HwAcc.full,
      autoPlay: true,
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
    _videoPlayerController.addListener(() {
      // 获取所有状态的回调
      if (_videoPlayerController.autoInitialize) {
        if (_videoPlayerController.value.isBuffering) {
          // 视频正在缓冲
          Fluttertoast.showToast(
              msg: "实时画面正在缓冲",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }

        if (_videoPlayerController.value.hasError) {
          // 播放器发生错误
          Fluttertoast.showToast(
              msg: "视频播放错误",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    });
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
    HttpRequest http = HttpRequest();

    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        centerTitle: true,
      ),
      // drawer: const DrawerView(),
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
          ElevatedButton(
            onPressed: () {
              http.getHttp('app/getproductinfo').then((result) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('设备名称：${result['info']['model']}'),
                        content: Text(
                            '设备厂商：${result['info']['company']}\n设备SOC：${result['info']['soc']}\n设备SP：${result['info']['sp']}'),
                      );
                    });
              });
            },
            child: const Text(
              '已连接：MettaX',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ),
        ],
      )),
      floatingActionButton: Column(
        // 浮动操作按钮
        mainAxisAlignment: MainAxisAlignment.end, // 主轴对齐方式
        children: [
          FloatingActionButton(
            child: const Icon(Icons.camera_alt),
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
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ConnectPage()));
              }),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
