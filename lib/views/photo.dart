import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';

// 图片页面，继承自StatefulWidget
class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PhotoPageState();
}

// 图片页面状态，混入SingleTickerProviderStateMixin用于TabController
class _PhotoPageState extends State<PhotoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // 选项卡控制器
  int _selectedIndex = 0; // 用于跟踪选项卡的索引

  // 图片分类
  List<String> categories = ['循环录像', '紧急录像', '事件', '停车监控'];

  // 用于跟踪每个分类选项对应的图片列表
  List<List<String>> imageLists = [
    [], // LOOP
    [], // EMR
    [], // EVENT
    [], // PARK
  ];

  void loadImageData() async {
  HttpRequest http = HttpRequest(context);
  var result = await http.getHttp('app/getfilelist');
  List<dynamic> info = result['info'];

  for (var item in info) {
    String folder = item['folder'];
    List<dynamic> files = item['files'];

    // 将每个文件夹中的文件路径存储到对应的 imageLists 中
    for (var file in files) {
      imageLists[getFolderIndex(folder)].add(file['name']);
    }
  }

  // 重新构建界面
  setState(() {});
}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: categories.length, vsync: this); // 初始化TabController
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index; // 监听选项卡变化并更新索引
      });
    });

    loadImageData();
  }

  @override
  void dispose() {
    _tabController.dispose(); // 释放资源
    super.dispose();
  }

  // 辅助函数：获取文件夹在 imageLists 中的索引
  int getFolderIndex(String folder) {
    switch (folder) {
      case 'loop':
        return 0;
      case 'emr':
        return 1;
      case 'event':
        return 2;
      case 'park':
        return 3;
      default:
        return -1; // 如果文件夹不是 loop、emr、event、park，则返回 -1
    }
  }

  @override
  Widget build(BuildContext context) {
    // HttpRequest http = HttpRequest(context);
    // http.getHttp('app/getfilelist').then((result) {
    //   List<dynamic> info = result['info'];

    //   for (var item in info) {
    //     String folder = item['folder'];
    //     List<dynamic> files = item['files'];

    //     // 将每个文件夹中的文件路径存储到对应的 imageLists 中
    //     for (var file in files) {
    //       imageLists[getFolderIndex(folder)].add(file['name']);
    //     }
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体库'), // 页面标题
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController, // 传入TabController
          tabs: categories
              .map((category) => Tab(text: category))
              .toList(), // 根据分类构建选项卡
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: imageLists[_selectedIndex].length, // 根据索引获取对应分类的图片数量
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 每行显示3张图片
            mainAxisSpacing: 10.0, // 主轴（竖直方向）上的间隔大小
            crossAxisSpacing: 10.0, // 交叉轴（水平方向）上的间隔大小
            childAspectRatio: 1.77,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Image.network(
              'http://192.168.169.1/app/getthumbnail?file=${imageLists[_selectedIndex][index]}',
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child; // 如果加载进度为null，则返回原始的图片小部件
                } else {
                  return const Center(
                    child: CircularProgressIndicator(), // 加载中显示一个圆形进度指示器
                  );
                }
              },
            ); // 根据索引获取对应分类的图片路径
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {});
          }), // 新增按钮
    );
  }
}
