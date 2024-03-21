import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                '导航栏',
                style: TextStyle(color: Colors.white, fontSize: 24),
              )),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('主页'),
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('图库'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('设置'),
          ),
        ],
      ),
    );
  }
}