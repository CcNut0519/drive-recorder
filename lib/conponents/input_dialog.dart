import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';

// 定义一个名为 MyAlertDialog 的 StatefulWidget 类，用于显示自定义的警告对话框
class MyInputDialog extends StatefulWidget {
  const MyInputDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.baseMsg});
  final String title, content, baseMsg;

  @override
  State<StatefulWidget> createState() => _MyInputDialogState();
}

// 定义 MyAlertDialog 的状态类 _MyAlertDialogState
class _MyInputDialogState extends State<MyInputDialog> {
  var inputMsg = TextEditingController();

  @override
  Widget build(BuildContext context) {
    HttpRequest http = HttpRequest(context);
    // 构建警告对话框并返回
    return AlertDialog(
      title: Center(child: Text(widget.title)), // 设置标题并居中显示
      content: TextField(
        controller: inputMsg,
        decoration: InputDecoration(
          labelText: widget.content,
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
            http.postHttp("${widget.baseMsg}${inputMsg.text}");
            Navigator.of(context).pop(); // 关闭对话框
          },
        ),
      ],
    );
  }
}
