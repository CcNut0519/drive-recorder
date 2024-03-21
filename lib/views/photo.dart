import 'package:flutter/material.dart';

// 图片页面，继承自StatefulWidget
class PhotoPage extends StatefulWidget {
 const PhotoPage({super.key});

 @override
 State<StatefulWidget> createState() => _PhotoPageState();
}

// 图片页面状态，混入SingleTickerProviderStateMixin用于TabController
class _PhotoPageState extends State<PhotoPage> with SingleTickerProviderStateMixin {
 late TabController _tabController; // 选项卡控制器
 int _selectedIndex = 0; // 用于跟踪选项卡的索引

 // 图片分类
 List<String> categories = [
   'LOOP',
   'EMR',
   'EVENT',
   'PARK'
 ];

 // 用于跟踪每个分类选项对应的图片列表
 List<List<String>> imageLists = [
   ['images/loop.jpg', 'images/loop.jpg', 'images/loop.jpg'], // LOOP
   ['images/emr.jpeg', 'images/emr.jpeg'], // EMR
   ['images/event.png', 'images/event.png', 'images/event.png'], // EVENT
   ['images/park.jpg'], // PARK
 ];

 @override
 void initState() {
   super.initState();
   _tabController = TabController(length: categories.length, vsync: this); // 初始化TabController
   _tabController.addListener(() {
     setState(() {
       _selectedIndex = _tabController.index; // 监听选项卡变化并更新索引
     });
   });
 }

 @override
 void dispose() {
   _tabController.dispose(); // 释放资源
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('媒体库'), // 页面标题
       bottom: TabBar(
         controller: _tabController, // 传入TabController
         tabs: categories.map((category) => Tab(text: category)).toList(), // 根据分类构建选项卡
       ),
     ),
     body: GridView.builder(
       itemCount: imageLists[_selectedIndex].length, // 根据索引获取对应分类的图片数量
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
         crossAxisCount: 3, // 每行显示3张图片
       ),
       itemBuilder: (BuildContext context, int index) {
         return Image.asset(imageLists[_selectedIndex][index]); // 根据索引获取对应分类的图片路径
       },
     ),
   );
 }
}
