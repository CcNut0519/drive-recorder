import 'package:flutter/material.dart';
import 'package:drive_recorder/views/home.dart';
import 'package:drive_recorder/views/photo.dart';
import 'package:drive_recorder/views/settings.dart';
import 'package:drive_recorder/conponents/alert_dialog.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:drive_recorder/conponents/drawer_view.dart';
import 'package:get/get.dart';

// 运行应用程序
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const ConnectPage(),
    );
  }
}

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    HttpRequest http = HttpRequest();
    return Scaffold(
      appBar: AppBar(
        title: const Text('请连接设备'),
      ),
      drawer: const DrawerView(),
      body: Center(
        child: ElevatedButton(
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
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyMaterialApp()),
                              );
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
          child: const Text('点此连接设备'),
        ),
      ),
    );
  }
}

class MyMaterialApp extends StatefulWidget {
  const MyMaterialApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<StatefulWidget> {
  //底栏列表
  List pages = [const HomePage(), const PhotoPage(), const SettingPage()];
  List<BottomNavigationBarItem> bottomItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.video_library), label: '媒体库'),
    const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
  ];
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        items: bottomItems,
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
    );
  }
}
