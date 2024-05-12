import 'package:flutter/material.dart';
import 'package:drive_recorder/conponents/db_helper.dart';

/// 抽屉View
class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Row(
              children: [
                Icon(Icons.history,
                    color: Colors.blueGrey, size: 30), // 使用图标代替文本
                SizedBox(width: 10), // 添加一些间距
                Text(
                  '历史连接记录',
                  style: TextStyle(fontSize: 24, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 设置圆角半径为10
              ),
              title: const Text('Mettax'),
              subtitle: const Text("2024-04-04 10:23:12"),
              trailing: const Icon(Icons.info_outline),
              tileColor: Colors.blueGrey[100],
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Mettax'),
                      content: Text(
                              '设备名称：Mettax\n设备IP：192.168.169.1\n最后连接时间：2024-04-04 10:23:12\n连接次数：1'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
