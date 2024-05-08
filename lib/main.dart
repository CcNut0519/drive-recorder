import 'package:flutter/material.dart';
import 'package:drive_recorder/views/home.dart';
import 'package:drive_recorder/views/photo.dart';
import 'package:drive_recorder/views/settings.dart';
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
     home: const MyMaterialApp(),
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
   const BottomNavigationBarItem(icon: Icon(Icons.video_library), label: '媒体库'),
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
