import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

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
  late VlcPlayerController _videoPlayerController;
  // static const _cachingMs = 500;
  late bool isPlaying = true;
  int _selectedIndex = 0; // 用于跟踪选项卡的索引

  // 图片分类
  List<String> categories = ['循环录像', '紧急录像', '事件', '停车监控'];

  // 用于跟踪每个分类选项对应的图片列表
  List<List<Map<String, dynamic>>> imageLists = [
    [], // LOOP
    [], // EMR
    [], // EVENT
    [], // PARK
  ];

  Future<void> initializePlayer() async {} // 初始化视频播放器

  void loadImageData() async {
    for (var list in imageLists) {
      list.clear();
    }
    HttpRequest http = HttpRequest();
    var result = await http.getHttp('app/getfilelist');
    List<dynamic> info = result['info'];

    for (var item in info) {
      String folder = item['folder'];
      List<dynamic> files = item['files'];

      // 将每个文件夹中的文件路径存储到对应的 imageLists 中
      for (var file in files) {
        String dateString = file['createtimestr'];

        String year = dateString.substring(0, 4);
        String month = dateString.substring(4, 6);
        String day = dateString.substring(6, 8);
        String hour = dateString.substring(8, 10);
        String minute = dateString.substring(10, 12);
        String second = dateString.substring(12, 14);

        String formattedDateTime = '$year年$month月$day日\n$hour:$minute:$second';
        imageLists[getFolderIndex(folder)].add({
          'name': file['name'],
          'date': formattedDateTime,
        });
      }
    }
    // 重新构建界面
    setState(() {});
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      // 获取临时目录路径
      String tempDirPath = (await getTemporaryDirectory()).path;

      // 下载文件保存路径
      String filePath = '$tempDirPath/$fileName';

      // 开始下载文件
      final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: tempDirPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      // 下载任务监听
      FlutterDownloader.registerCallback((id, status, progress) async {
        if (taskId == id && status == DownloadTaskStatus.complete) {
          // 下载完成后将文件从临时目录移动到永久存储目录
          // 获取永久存储目录路径
          Directory? externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            String storageDirPath = externalDir.path;
            String newFilePath = '$storageDirPath/$fileName';
            // 移动文件
            File(filePath).renameSync(newFilePath);
          } else {
            print('无法获取外部存储目录路径');
          }
        }
      });
    } catch (e) {
      print('下载文件时出错：$e');
    }
  }

  @override
  void initState() {
    super.initState();
    // initVlc();
    _tabController = TabController(
        length: categories.length, vsync: this); // 初始化TabController
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index; // 监听选项卡变化并更新索引
      });
    });

    loadImageData();
  }

  void initVlc(String videoAddr) {
    const cachingMs = 500;
    // 初始化 _videoPlayerController
    _videoPlayerController = VlcPlayerController.network(videoAddr,
        hwAcc: HwAcc.full,
        autoPlay: true,
        allowBackgroundPlayback: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.fileCaching(cachingMs),
            VlcAdvancedOptions.networkCaching(cachingMs),
            VlcAdvancedOptions.liveCaching(cachingMs),
            VlcAdvancedOptions.clockSynchronization(0),
            VlcAdvancedOptions.clockJitter(cachingMs),
          ]),
          audio: VlcAudioOptions([VlcAudioOptions.audioTimeStretch(true)]),
          video: VlcVideoOptions(
            [
              VlcVideoOptions.dropLateFrames(false), // 确保不跳过帧
              VlcVideoOptions.skipFrames(false) // 确保不跳过帧
            ],
          ),
        ));
    _videoPlayerController.addListener(() {
      // 获取所有状态的回调
      if (_videoPlayerController.autoInitialize) {
        if (_videoPlayerController.value.isBuffering) {
          // 视频正在缓冲
          Fluttertoast.showToast(
              msg: "视频正在缓冲",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }

        if (_videoPlayerController.value.isEnded) {
          // 视频播放完成
          Fluttertoast.showToast(
              msg: "视频播放完成",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }

        if (_videoPlayerController.value.hasError) {
          // 播放器发生错误
          Fluttertoast.showToast(
              msg: "视频播放错误",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blueGrey,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }

      // 其他状态处理...
    });
  }

  @override
  void dispose() async {
    _tabController.dispose(); // 释放资源
    super.dispose();
    await _videoPlayerController.stopRendererScanning(); // 停止扫描渲染器
    await _videoPlayerController.dispose(); // 释放资源
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
    HttpRequest http = HttpRequest();
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
            crossAxisCount: 2, // 每行显示3张图片
            mainAxisSpacing: 15.0, // 主轴（竖直方向）上的间隔大小
            crossAxisSpacing: 15.0, // 交叉轴（水平方向）上的间隔大小
            childAspectRatio: 1.1,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                initVlc(
                    'http://192.168.169.1${imageLists[_selectedIndex][index]['name']}');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(imageLists[_selectedIndex][index]['date']),
                      content: SizedBox(
                        height: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VlcPlayer(
                              controller: _videoPlayerController,
                              aspectRatio: 16 / 9,
                              placeholder: const Center(
                                  child: CircularProgressIndicator(
                                      backgroundColor: Colors.grey,
                                      color: Colors.blue)),
                            ),
                            const SizedBox(
                              height: 1.5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (isPlaying) {
                                      _videoPlayerController.pause();
                                    } else {
                                      _videoPlayerController.play();
                                    }
                                    isPlaying = !isPlaying;
                                  });
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('删除'),
                          onPressed: () {
                            http.postHttp(
                                'app/deletefile?file=${imageLists[_selectedIndex][index]['name']}');
                            Navigator.of(context).pop(); // 关闭对话框
                            loadImageData();
                          },
                        ),
                        TextButton(
                          child: const Text('下载'),
                          onPressed: () {
                            downloadFile(
                                'app/deletefile?file=${imageLists[_selectedIndex][index]['name']}',
                                '${imageLists[_selectedIndex][index]['date']}.ts');
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.network(
                        'http://192.168.169.1/app/getthumbnail?file=${imageLists[_selectedIndex][index]['name']}',
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // 如果加载进度为null，则返回原始的图片小部件
                          } else {
                            return const Center(
                              child:
                                  CircularProgressIndicator(), // 加载中显示一个圆形进度指示器
                            );
                          }
                        },
                      ),
                    ),
                    Text(
                      imageLists[_selectedIndex][index]
                          ['date'], // 根据索引获取对应分类的图片日期
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            loadImageData();
          }), // 新增按钮
    );
  }
}
