import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

FirebaseMessaging firebaseMessaging;

Future<void> initNotification() async {
  firebaseMessaging = FirebaseMessaging()
    ..requestNotificationPermissions()
    ..onIosSettingsRegistered.listen((IosNotificationSettings settings) {})
    ..configure(
      onMessage: (Map<String, dynamic> message) async {
        shownoti(message);
      },
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // データメッセージをハンドリング
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // 通知メッセージをハンドリング
    final dynamic notification = message['notification'];
  }
  print('onBackground: $message');
}

void shownoti(s) {
  showSimpleNotification(Text(s), background: Colors.amber);
}
