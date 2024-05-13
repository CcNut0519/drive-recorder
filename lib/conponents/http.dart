import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// 发出 HTTP 请求并处理响应
class HttpRequest {
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
  Future<Map<String, dynamic>> postHttp(String request) async {
    Dio dio = Dio();
    try {
      Response response = await dio.post(url + request);
      Map<String, dynamic> responseData = response.data;
      Fluttertoast.showToast(
          msg: "修改成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
      return responseData;
    } catch (error) {
      return {'error': 'An error occurred'};
    }
  }
}
