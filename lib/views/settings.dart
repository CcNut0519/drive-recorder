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
       ),
       body: ListView(
         children: [
           // WIFI名称设置部分
           ListTile(
             title: const Text('WIFI名称'),
             subtitle: const Text('设置设备的WIFI名称'),
             onTap: () {
               showDialog(
                 context: context,
                 builder: (BuildContext context) {
                   return AlertDialog(
                     title: const Text('更改WIFI名称'),
                     content: TextField(
                       controller: wifiName,
                       decoration: const InputDecoration(
                         labelText: '请输入新的WIFI名称',
                       ),
                     ),
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
                           http.postHttp(
                               'app/setwifi?wifissid=${wifiName.text}');
                           Navigator.of(context).pop(); // 关闭对话框
                         },
                       ),
                     ],
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
                   return AlertDialog(
                     title: const Text('更改WIFI密码'),
                     content: TextField(
                       controller: wifiPsw,
                       decoration: const InputDecoration(
                         labelText: '请输入新的WIFI密码',
                       ),
                     ),
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
                           http.postHttp(
                               'app/setwifi?wifipwd=${wifiPsw.text}');
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
             title: const Text('WIFI名称'),
             subtitle: const Text('设置设备的WIFI名称'),
             onTap: () {
               showDialog(
                 context: context,
                 builder: (BuildContext context) {
                   return const MyInputDialog(title: "更改WIFI名称", content: "设置设备的WIFI名称", baseMsg: "app/setwifi?wifissid=",);
                 },
               );
             },
           ),
         ],
       ));
 }
}
