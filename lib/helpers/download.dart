import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/formet.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:external_path/external_path.dart';
import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

typedef ProgressCallback = Function(double, double);
var currentfilepath = '';
var totalsize;

class AudioDownloader {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> downloadVideo(String Title, String videoUrl, String author,
      ProgressCallback onProgress) async {
    try {
      var path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);

      String formattedDate =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = '${processString(Title)}$formattedDate.mp3';
      // var path = await ExternalPath.getExternalStorageDirectories();

      String filePath = '/storage/emulated/0/Download/$fileName';

      try {
        var yt = YoutubeExplode();
        var manifest = await yt.videos.streamsClient.getManifest(videoUrl);
        var info = manifest.audioOnly.withHighestBitrate();

        if (Audiosetting.get('quality') == 'High' ||
            Audiosetting.get('quality') == null) {
          info = manifest.audioOnly.withHighestBitrate();
        } else if (Audiosetting.get('quality') == 'Medium') {
          info = manifest.audioOnly[2];
        } else if (Audiosetting.get('quality') == 'Low') {
          info = manifest.audioOnly[0];
        } else {
          info = manifest.audioOnly.withHighestBitrate();
        }

        // commenting this for test purpose
        var stream = yt.videos.streamsClient.get(info);
        var file = File(filePath);
        var fileStream = file.openWrite();

        int downloadedBytes = 0;
        double totalBytes = info.size.totalBytes.toDouble();
        //  Convert bytes to megabytes// Convert bytes to megabytes
        await for (List<int> chunk in stream) {
          fileStream.add(chunk);
          downloadedBytes += chunk.length;
          double progress = downloadedBytes.toDouble();
          onProgress(progress, totalBytes);
        }

        await fileStream.flush();
        await fileStream.close();
// comment ends here

        yt.close();
      } catch (e) {}
      currentfilepath = filePath;
      try {
        notificationsPlugin.show(
          1,
          'Downloaded',
          '$fileName downloaded',
          await notificationDetails(),
        );
      } catch (e) {}

      MediaScanner.loadMedia(path: filePath);
    } catch (error) {}
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }
}

checkPermission() async {
  var status = await Permission.storage.status;

  if (!status.isGranted) {
    status = await Permission.storage.request();
  }
  if (status.isGranted) {
  } else {
    checkPermission();
  }
}

checkpermissionnotif() async {
  var status = await Permission.notification.status;

  if (!status.isGranted) {
    status = await Permission.notification.request();
  }
  if (status.isGranted) {
  } else {
    checkpermissionnotif();
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      // open
    });
  }
}
