import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drive_recorder/conponents/alert_dialog.dart';
import 'package:flutter/material.dart';

// 发出 HTTP 请求并处理响应
class HttpRequest {
 BuildContext context;
 
 // 构造函数
 HttpRequest(this.context);
 
 // 请求的基础 URL
 String url = 'http://192.168.169.1/';
 
 // 发送 HTTP GET 请求
 Future<Map<String, dynamic>> getHttp(String request) async {
   Dio dio = Dio();
   try {
     Response response = await dio.get(url + request);
     Map<String, dynamic> responseData = response.data;
     return responseData;
   } catch (error) {
     return {'error': 'An error occurred'};
   }
 }

 // 发送 HTTP POST 请求
 void postHttp(String request) async {
   Dio dio = Dio();
   try {
     Response response = await dio.post(url + request);
     Map<String, dynamic> responseData = response.data;
     if (responseData['info'] == 'set success') {
       _showAlertDialog('成功', '修改成功');
     } else {
       _showAlertDialog('失败', '修改失败');
     }
   } catch (error) {
     _showAlertDialog('Error', error.toString());
   }
 }

 // 显示警报对话框
 void _showAlertDialog(String mytitle, String mycontent) {
   showDialog(
     context: context,
     builder: (_) {
       return MyAlertDialog(title: mytitle, content: mycontent);
     },
   );
 }

 // 建立 Socket 连接
 void connect() async {
   Socket socket = await Socket.connect('192.168.169.1', 5000);
   print('Connected to: ${socket.remoteAddress}:${socket.remotePort}');
 }

 // 打印 JSON 数据
 void PrintJson(Map<String, dynamic> jsonData) {
   jsonData['info'].forEach((key, value) {
     print('$key: $value');
   });
 }
}
