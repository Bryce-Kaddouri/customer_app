import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class NotificationHelperV2 {
  final BuildContext context;

  NotificationHelperV2({required this.context});

  int notificationId = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  static const MethodChannel platform =
      MethodChannel('dexterx.dev/flutter_local_notifications_example');

  bool _notificationsEnabled = false;

  initNotification() {
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureSelectNotificationSubject();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      _notificationsEnabled = granted;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();

      _notificationsEnabled = grantedNotificationPermission ?? false;
    }
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      print('selectNotificationStream: $payload');
      /*await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SecondPage(payload),
        ),
      );*/
      context.push('/second/$payload');

      /*await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SecondPage(payload),
      ));*/
    });
  }

  Future<void> showNotificationWithActions(int id, String title, String body,
      Map<String, dynamic> payloadMap, String? imageUrl) async {
    String payloadString = jsonEncode(payloadMap);

    final ByteArrayAndroidBitmap? largeIcon;
    final ByteArrayAndroidBitmap? bigPicture;

    if (imageUrl != null) {
      largeIcon = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(imageUrl!));
      bigPicture =
          ByteArrayAndroidBitmap(await _getByteArrayFromUrl(imageUrl!));
    } else {
      largeIcon = null;
      bigPicture = null;
    }

    /// Defines a iOS/MacOS notification category for text input actions.
    const String darwinNotificationCategoryText = 'textCategory';

    /// Defines a iOS/MacOS notification category for plain actions.
    const String darwinNotificationCategoryPlain = 'plainCategory';
    const String navigationActionId = 'id_3';
    const String urlLaunchActionId = 'id_1';

    late AndroidNotificationDetails androidNotificationDetails;

    if (imageUrl != null) {
      androidNotificationDetails = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: BigPictureStyleInformation(
          bigPicture!,
/*
          largeIcon: largeIcon,
*/
/*
          contentTitle: 'overridden <b>big</b> content title',
*/
          htmlFormatContentTitle: true,
/*
          summaryText: 'summary <i>text</i>',
*/
          htmlFormatSummaryText: true,
        ),
        /* actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            urlLaunchActionId,
            'Action 1',
            icon: DrawableResourceAndroidBitmap('food'),
            contextual: true,
          ),
          AndroidNotificationAction(
            'id_2',
            'Action 2',
            titleColor: Color.fromARGB(255, 255, 0, 0),
            icon: DrawableResourceAndroidBitmap('secondary_icon'),
          ),
          AndroidNotificationAction(
            navigationActionId,
            'Action 3',
            icon: DrawableResourceAndroidBitmap('secondary_icon'),
            showsUserInterface: true,
            // By default, Android plugin will dismiss the notification when the
            // user tapped on a action (this mimics the behavior on iOS).
            cancelNotification: false,
          ),
        ],*/
      );
    } else {
      androidNotificationDetails = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            urlLaunchActionId,
            'Close',
            titleColor: Color.fromARGB(255, 255, 0, 0),
            icon: DrawableResourceAndroidBitmap('secondary_icon'),
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            navigationActionId,
            'Add To Calendar',
            titleColor: Colors.greenAccent,
            showsUserInterface: true,
            contextual: false,
            // By default, Android plugin will dismiss the notification when the
            // user tapped on a action (this mimics the behavior on iOS).
            cancelNotification: true,
          ),
        ],
      );
    }

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const DarwinNotificationDetails macOSNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const LinuxNotificationDetails linuxNotificationDetails =
        LinuxNotificationDetails(
      actions: <LinuxNotificationAction>[
        LinuxNotificationAction(
          key: urlLaunchActionId,
          label: 'Action 1',
        ),
        LinuxNotificationAction(
          key: navigationActionId,
          label: 'Action 2',
        ),
      ],
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
      linux: linuxNotificationDetails,
    );
    await flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payloadString);
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  Future<void> showBigPictureNotificationURL(
      String title, String body, String imgUrl) async {
    final String largeIconPath =
        await _downloadAndSaveFile('https://dummyimage.com/48x48', 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
        'https://dummyimage.com/400x800', 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'big text channel id', 'big text channel name',
            channelDescription: 'big text channel description',
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', notificationDetails);
  }
}
