import 'package:flutter/material.dart';

// 定义一个名为 MyAlertDialog 的 StatefulWidget 类，用于显示自定义的警告对话框
class MyAlertDialog extends StatefulWidget {
 const MyAlertDialog({super.key, required this.title, required this.content});
 final String title, content;

 @override
 State<StatefulWidget> createState() => _MyAlertDialogState();
}

// 定义 MyAlertDialog 的状态类 _MyAlertDialogState
class _MyAlertDialogState extends State<MyAlertDialog> {
 @override
 Widget build(BuildContext context) {
   // 构建警告对话框并返回
   return AlertDialog(
     title: Center(child: Text(widget.title)), // 设置标题并居中显示
     content: Text(widget.content), // 设置内容
     actions: [
       // 设置确认按钮
       TextButton(
           onPressed: () {
             Navigator.pop(context);
           },
           child: Text("确认")),
     ],
   );
 }
}
