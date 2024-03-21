import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:drive_recorder/conponents/alert_dialog.dart';

// 定义主页类 HomePage
class HomePage extends StatefulWidget {
 const HomePage({super.key});

 @override
 State<HomePage> createState() => _HomePageState(); // 创建并返回 _HomePageState 对象
}

// 定义主页状态类，继承自主页类
class _HomePageState extends State<HomePage> {
 var inuutGet = TextEditingController(text: 'app/getproductinfo'); // 初始化一个 TextEditingController 对象
 var inputPost = TextEditingController(text: 'app/setparam?param='); // 初始化一个 TextEditingController 对象
 late VlcPlayerController _videoPlayerController; // 声明一个延迟初始化的 VlcPlayerController 对象
 late String deviceName; // 设备名称
 bool showExtraText = false; // 是否显示额外文本

 Future<void> initializePlayer() async {} // 初始化视频播放器的方法

 @override
 void initState() { // 重写父类的 initState 方法
   super.initState();
   _videoPlayerController = VlcPlayerController.network( // 初始化 _videoPlayerController
     'rtsp://192.168.169.1', // 视频地址
     hwAcc: HwAcc.auto, // 自动硬件加速
     autoPlay: false, // 不自动播放
     options: VlcPlayerOptions( // 设置播放器选项
       advanced: VlcAdvancedOptions([ // 高级配置选项
         VlcAdvancedOptions.liveCaching(100), // 实时缓存
         VlcAdvancedOptions.networkCaching(100), // 网络缓存
       ]),
     ),
   );
 }

 @override
 void dispose() async { // 重写父类的 dispose 方法
   super.dispose();
   await _videoPlayerController.stopRendererScanning(); // 停止扫描渲染器
   await _videoPlayerController.dispose(); // 释放资源
 }

 @override
 Widget build(BuildContext context) { // 重写父类的 build 方法
   HttpRequest http = HttpRequest(context); // 创建一个 HttpRequest 对象
   //http.connect(); // 连接

   return Scaffold( // 返回一个 Scaffold 组件
     body: Center( // 居中显示内容
         child: Column( // 垂直布局
       children: [ // 子组件列表
         const SizedBox(height: 30), // 间距
         Padding( // 填充
           padding: const EdgeInsets.all(16.0),
           child: VlcPlayer( // VLC 播放器
             controller: _videoPlayerController, // 绑定控制器
             aspectRatio: 16 / 9, // 宽高比
             placeholder: const Center(child: CircularProgressIndicator()), // 占位符
           ),
         ),
         TextField( // 文本输入框
           controller: inuutGet, // 绑定控制器
           decoration: InputDecoration( // 输入框装饰
             labelText: '请输入GET地址', // 标签文本
             suffixIcon: IconButton( // 后缀图标按钮
               icon: const Icon(Icons.send), // 图标
               onPressed: () { // 点击事件
                 http.getHttp(inuutGet.text).then((result) { // 发起 GET 请求
                   showDialog( // 显示对话框
                       context: context,
                       builder: (_) {
                         return MyAlertDialog( // 自定义提示对话框
                             title: 'get info', content: result.toString());
                       });
                 });
               },
             ),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // 输入框边框
           ),
         ),
         const SizedBox(height: 20), // 间距
         TextField( // 文本输入框
           controller: inputPost, // 绑定控制器
           decoration: InputDecoration( // 输入框装饰
             labelText: '请输入POST地址', // 标签文本
             suffixIcon: IconButton( // 后缀图标按钮
               icon: const Icon(Icons.send), // 图标
               onPressed: () { // 点击事件
                 http.postHttp(inputPost.text); // 发起 POST 请求
               },
             ),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // 输入框边框
           ),
         ),
         if (showExtraText) // 如果 showExtraText 为真
           Text( // 文本组件
             deviceName, // 文本内容
             style: const TextStyle(fontSize: 16, color: Colors.blueGrey), // 文本样式
           ),
       ],
     )),
     floatingActionButton: Column( // 浮动操作按钮
       mainAxisAlignment: MainAxisAlignment.end, // 主轴对齐方式
       children: [ // 子组件列表
         FloatingActionButton( // 浮动操作按钮
           child: const Icon(Icons.camera), // 图标
           onPressed: () { // 点击事件
             http.getHttp('app/snapshot').then((result) { // 发起 GET 请求
               showDialog( // 显示对话框
                   context: context,
                   builder: (_) {
                     return MyAlertDialog( // 自定义提示对话框
                         title: '拍摄成功！', content: result['info']);
                   });
             });
           },
         ),
         const SizedBox(height: 10), // 间距
         FloatingActionButton( // 浮动操作按钮
             child: const Icon(Icons.link), // 图标
             onPressed: () async { // 点击事件
               http.getHttp('app/enterrecorder'); // 进入录像模式
               http.getHttp('app/setsystime?date${DateTime.now().toString()}'); // 设置系统时间
               print(DateTime.now().toString()); // 打印当前时间
               Get.snackbar('恭喜！', '已成功连接到行车记录仪', icon: const Icon(Icons.link)); // 显示 snackbar
               deviceName = '已连接：${(await http.getHttp('app/getproductinfo'))['info']['model']}'; // 获取设备信息
               _videoPlayerController.play(); // 播放视频
               setState(() {
                 showExtraText = true; // 更新状态，显示额外文本
               });
             }),
       ],
     ),
   );
 }
}
