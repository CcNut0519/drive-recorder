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
        children: const <Widget>[
          DrawerHeader(
              child: Text(
                '历史连接记录',
                style: TextStyle(fontSize: 24),
              )),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Mettax'),
            subtitle: Text("2024-04-04 10:23:12"),
          ),
        ],
      ),
    );
  }
}