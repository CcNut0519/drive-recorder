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
class _HomePageState extends State<HomePage> {
  late VlcPlayerController _videoPlayerController;
  String deviceName = '未连接到设备';

  Future<void> initializePlayer() async {} // 初始化视频播放器

  @override
  void initState() {
    super.initState();
    // 初始化 _videoPlayerController
    _videoPlayerController = VlcPlayerController.network(
      'rtsp://192.168.169.1',
      hwAcc: HwAcc.auto,
      autoPlay: false,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.liveCaching(100), // 实时缓存
          VlcAdvancedOptions.networkCaching(100), // 网络缓存
        ]),
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
    HttpRequest http = HttpRequest(context);
    Map<String, dynamic> deviceInfo = {
      'device_name': '',
      'device_ip': '192.168.169.1',
      'last_connected_time': '',
      'connected_count': 1,
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
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  title: const Text('设备信息'),
                  content: Text('设备名称：${deviceInfo['device_name']}\n设备IP：${deviceInfo['device_ip']}\n最后连接时间：${deviceInfo['last_connected_time']}\n连接次数：${deviceInfo['connected_count']}'),
                  actions: [
                    TextButton(
                      child: const Text('确定'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
            },
            child: Text(
              deviceName,
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ),
        ],
      )),
      floatingActionButton: Column(
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
              child: const Icon(Icons.link),
              onPressed: () async {
                // sql.Database database = await SQLHelper.db();
                http.getHttp('app/enterrecorder');
                http.getHttp('app/setsystime?date${DateTime.now().toString()}');
                print(DateTime.now().toString());
                Get.snackbar('恭喜！', '已成功连接到行车记录仪',
                    icon: const Icon(Icons.link));
                deviceName =
                    '已连接：${(await http.getHttp('app/getproductinfo'))['info']['model']}';
                _videoPlayerController.play();
                deviceInfo['device_name'] = deviceName;
                deviceInfo['connected_count'] =
                    deviceInfo['connected_count'] + 1;
                
                // await SQLHelper.insertDevice(database, deviceInfo);
                // 关闭数据库连接
                // await database.close();
              }),
        ],
      ),
    );
  }
}
