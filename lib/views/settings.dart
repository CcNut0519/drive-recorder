import 'package:drive_recorder/conponents/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/http.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool soundSwitch = false;
  String speakerVolume = ''; //播报音量
  String recSplitDuration = ''; //录制分段时间
  String recResolution = ''; //录制分辨率
  String wifiSsid = ''; //WIFI名称
  HttpRequest http = HttpRequest();
  String url = 'app/setwifi?wifissid=';

  void onSwitchChanged(bool value) {
    setState(() {
      soundSwitch = value;
    });
  }

// 获取播报音量
  void getSpeakerVolume() {
    http.getHttp('app/getparamvalue?param=speaker').then((value) {
      if (value['info']['value'] == 0) {
        setState(() {
          speakerVolume = '关闭';
        });
      } else if (value['info']['value'] == 1) {
        setState(() {
          speakerVolume = '低';
        });
      } else if (value['info']['value'] == 2) {
        setState(() {
          speakerVolume = '中';
        });
      } else if (value['info']['value'] == 3) {
        setState(() {
          speakerVolume = '高';
        });
      } else {
        setState(() {
          speakerVolume = '最高';
        });
      }
    });
  }

// 获取录制分辨率
  void getRecResolution() {
    http.getHttp('app/getparamvalue?param=rec_resolution').then((value) {
      if (value['info']['value'] == 0) {
        setState(() {
          recResolution = '720P';
        });
      } else if (value['info']['value'] == 1) {
        setState(() {
          recResolution = '1080P';
        });
      } else if (value['info']['value'] == 2) {
        setState(() {
          recResolution = '1296P';
        });
      } else {
        setState(() {
          recResolution = '2K';
        });
      }
    });
  }

  //获取录制分段时间
  void getRecSplitDuration() {
    http.getHttp('app/getparamvalue?param=rec_split_duration').then((value) {
      if (value['info']['value'] == 0) {
        setState(() {
          recSplitDuration = '1分钟';
        });
      } else {
        setState(() {
          recSplitDuration = '2分钟';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getSpeakerVolume();
    getRecResolution();
    getRecSplitDuration();
    http.getHttp('app/getdeviceattr').then((value) {
      setState(() {
        wifiSsid = value['info']['ssid'];
      });
    });
    // 返回包含设置页面内容的Scaffold
    return Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 设置圆角为10
                      color: const Color(0xFFDFEBF0), // 设置背景颜色
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('基础设置', style: TextStyle(fontSize: 20)),
                    )),
              ],
            ),
            // WIFI名称设置部分
            ListTile(
              title: const Text('WIFI名称'),
              subtitle: const Text('设置设备的WIFI名称'),
              trailing: Text(
                wifiSsid,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const MyInputDialog(
                      title: "更改WIFI名称",
                      content: "设置设备的WIFI名称",
                      baseMsg: "app/setwifi?wifissid=",
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
                    return const MyInputDialog(
                      title: "更改WIFI密码",
                      content: "设置设备的WIFI密码",
                      baseMsg: "app/setwifi?wifipwd=",
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('格式化SD卡'),
              subtitle: const Text('擦除你的存储卡信息'),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('再次确认'),
                      content: const Text('确认要擦除您的存储卡数据吗？'),
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
                            http.postHttp('app/sdformat');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "格式化成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text('恢复出厂设置'),
              subtitle: const Text('恢复设备端的设置项到出厂的默认状态'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('再次确认'),
                      content: const Text('确认要恢复出厂设置吗？'),
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
                            http.postHttp('app/reset');
                            Navigator.of(context).pop(); // 关闭对话框
                            Fluttertoast.showToast(
                                msg: "恢复出厂设置成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueGrey,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // 设置圆角为10
                      color: const Color(0xFFDFEBF0), // 设置背景颜色
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('视频设置', style: TextStyle(fontSize: 20)),
                    )),
              ],
            ),
            ListTile(
              title: const Text('录制声音'),
              subtitle: const Text('是否开启声音录制'),
              trailing: Switch(value: soundSwitch, onChanged: onSwitchChanged),
            ),
            ListTile(
              title: const Text('播报音量'),
              subtitle: const Text('调整设备语音播报声音大小'),
              trailing: Text(
                speakerVolume,
                style: const TextStyle(fontSize: 14),
              ),
              // trailing: Text('${http.getHttp('app/getparamvalue?param=speaker')}'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('选择播报音量'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '0');
                            },
                            child: const Text(
                              '关闭',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '1');
                            },
                            child: const Text(
                              '低',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '2');
                            },
                            child: const Text(
                              '中',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '3');
                            },
                            child: const Text(
                              '高',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '4');
                            },
                            child: const Text(
                              '最高',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value != null) {
                    http.postHttp(
                        'app/setparamvalue?param=speaker&value=$value');
                    setState(() {
                      getSpeakerVolume();
                    });
                  }
                });
              },
            ),
            ListTile(
              title: const Text('视频分辨率'),
              subtitle: const Text('调整录制视频分辨率'),
              trailing: Text(
                recResolution,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('选择播报音量'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '0');
                            },
                            child: const Text(
                              '720P',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '1');
                            },
                            child: const Text(
                              '1080P',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '2');
                            },
                            child: const Text(
                              '1296P',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '3');
                            },
                            child: const Text(
                              '2K',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value != null) {
                    http.postHttp(
                        'app/setparamvalue?param=rec_resolution&value=$value');
                    setState(() {
                      getRecResolution();
                    });
                  }
                });
              },
            ),
            ListTile(
              title: const Text('视频录制时长'),
              subtitle: const Text('调整设备循环录制的单个视频时长'),
              trailing: Text(
                recSplitDuration,
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('选择录制时长'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '0');
                            },
                            child: const Text(
                              '1分钟',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, '1');
                            },
                            child: const Text(
                              '2分钟',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value != null) {
                    http.postHttp(
                        'app/setparamvalue?param=rec_split_duration&value=$value');
                    setState(() {
                      getRecSplitDuration();
                    });
                  }
                });
              },
            ),
          ],
        ));
  }
}
