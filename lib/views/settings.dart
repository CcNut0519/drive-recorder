import 'package:drive_recorder/conponents/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';

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

  String url = 'app/setwifi?wifissid=';

  @override
  Widget build(BuildContext context) {
    HttpRequest http = HttpRequest(context);

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
          ],
        ));
  }
}
