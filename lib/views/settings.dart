import 'package:drive_recorder/conponents/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 表示设置页面的StatefulWidget
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

// 表示设置页面的State
class _SettingPageState extends State<SettingPage> {
  var wifiName = TextEditingController();
  var wifiPsw = TextEditingController();
  bool soundSwitch = false;
  String speakerVolume = '';
  HttpRequest http = HttpRequest();
  String url = 'app/setwifi?wifissid=';

  void onSwitchChanged(bool value) {
    setState(() {
      soundSwitch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    http.getHttp('app/getparamvalue?param=speaker').then((value) {
      if (value['info']['value'] == 0) {
        speakerVolume = '关闭';
      } else if (value['info']['value'] == 1) {
        speakerVolume = '低';
      } else if (value['info']['value'] == 2) {
        speakerVolume = '中';
      } else if (value['info']['value'] == 3) {
        speakerVolume = '高';
      } else {
        speakerVolume = '最高';
      }
    });
    // 返回包含设置页面内容的Scaffold
    return Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 设置圆角为10
                      color: const Color(0xFFDFEBF0), // 设置背景颜色
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('基础设置', style: TextStyle(fontSize: 20)),
                    )),
              ],
            ),
            // WIFI名称设置部分
            ListTile(
              title: const Text('WIFI名称'),
              subtitle: const Text('设置设备的WIFI名称'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MyInputDialog(
                      title: "更改WIFI名称",
                      content: "设置设备的WIFI名称",
                      baseMsg: "app/setwifi?wifissid=",
                    );
                  },
                );
              },
            ),
            // WIFI密码设置部分
            ListTile(
              title: const Text('WIFI密码'),
              subtitle: const Text('设置设备的WIFI密码'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MyInputDialog(
                      title: "更改WIFI密码",
                      content: "设置设备的WIFI密码",
                      baseMsg: "app/setwifi?wifipwd=",
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('格式化SD卡'),
              subtitle: const Text('擦除你的存储卡信息'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('再次确认'),
                      content: const Text('确认要擦除您的存储卡数据吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: const Text('确认'),
                          onPressed: () {
                            http.postHttp('app/sdformat');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "格式化成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('恢复出厂设置'),
              subtitle: const Text('恢复设备端的设置项到出厂的默认状态'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('再次确认'),
                      content: const Text('确认要恢复出厂设置吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: const Text('确认'),
                          onPressed: () {
                            http.postHttp('app/reset');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "恢复出厂设置成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 设置圆角为10
                      color: const Color(0xFFDFEBF0), // 设置背景颜色
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('视频设置', style: TextStyle(fontSize: 20)),
                    )),
              ],
            ),
            ListTile(
              title: const Text('录制声音'),
              subtitle: const Text('是否开启声音录制'),
              trailing: Switch(value: soundSwitch, onChanged: onSwitchChanged),
            ),
            ListTile(
              title: const Text('播报音量'),
              subtitle: const Text('调整设备语音播报声音大小'),
              trailing: Text(speakerVolume),
              // trailing: Text('${http.getHttp('app/getparamvalue?param=speaker')}'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(''),
                      content: const Text(''),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: const Text('确认'),
                          onPressed: () {
                            http.postHttp('app/sdformat');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "格式化成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('视频分辨率'),
              subtitle: const Text('调整录制视频分辨率'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('再次确认'),
                      content: const Text('确认要擦除您的存储卡数据吗？'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: const Text('确认'),
                          onPressed: () {
                            http.postHttp('app/sdformat');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "格式化成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('视频录制时长'),
              subtitle: const Text('调整设备循环录制的单个视频时长'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(''),
                      content: const Text(''),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: const Text('确认'),
                          onPressed: () {
                            http.postHttp('app/sdformat');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "格式化成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ));
  }
}
