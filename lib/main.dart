import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ntcutelloview/pages/action_page.dart';
import 'package:ntcutelloview/pages/home_page.dart';
import 'package:ntcutelloview/pages/re.dart';

import 'package:ntcutelloview/pages/upload_page.dart';
import 'package:ntcutelloview/pages/test_face_page.dart';

import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return OverlaySupport(
        child: MaterialApp(
      title: 'Hello Flutter',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Scaffold(
        body: BottomNavigationController(),
      ),
      debugShowCheckedModeBanner: false,
    ));
  }
}

class BottomNavigationController extends StatefulWidget {
  BottomNavigationController({Key key}) : super(key: key);
  @override
  _BottomNavigationController createState() => _BottomNavigationController();
}

class _BottomNavigationController extends State<BottomNavigationController> {
  int _currentIndex = 0;
  final pages = [
    HomePage(),
    ActionPage(),
    UploadingImageToFirebaseStorage(),
    TestImageToSystem(),
    MainPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首頁')),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), title: Text('操作')),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file), title: Text('上傳新人')),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_outlined), title: Text('測試')),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_outlined), title: Text('測試2')),
        ],
        currentIndex: _currentIndex, //目前選擇頁索引值
        fixedColor: Colors.amber, //選擇頁顏色
        onTap: _onItemClick, //BottomNavigationBar 按下處理事件
      ),
    );
  }

  void _onItemClick(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
