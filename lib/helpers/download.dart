import 'package:audiotagger/audiotagger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/formet.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:async';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

typedef ProgressCallback = Function(double, double);
var currentfilepath = '';
var totalsize;
final tagger = new Audiotagger();

class VideoDownloader {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> downloadVideo(String Title, String videoUrl, String author,
      ProgressCallback onProgress) async {
    try {
      print('its here lol');

      var path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);

      String formattedDate =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = '${processString(Title)}$formattedDate.mp3';
      // var path = await ExternalPath.getExternalStorageDirectories();
      print('its here lol $path');
      String filePath = '/storage/emulated/0/Download/$fileName';
      print('its here $filePath');

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

        print(info);
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
        print('Downloaded');
        yt.close();
      } catch (e) {
        print('err is $e');
      }
      currentfilepath = filePath;

      notificationsPlugin.show(
        1,
        'Downloaded',
        '$fileName downloaded',
        await notificationDetails(),
      );

      MediaScanner.loadMedia(path: filePath);
      try {
        void setTagsFromMap() async {
          final path = "$filePath";
          final tags = <String, String>{
            "title": "Title of the song",
            "artist": "A fake artist",
            "album": "", //This field will be reset
            "genre": "", //This field will not be written
          };

          await tagger.writeTagsFromMap(path: path, tags: tags);
        }

        setTagsFromMap();
      } catch (e) {
        print(e.toString());
      }

      print('Video downloaded successfully. Saved at: $filePath');
    } catch (error) {
      print('Error downloading video: $error');
    }
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
    print('permission already granted');
  } else {
    checkPermission();
  }
}

checkpermissionnotif() async {
  var status = await Permission.notification.status;
  print('asking');

  if (!status.isGranted) {
    status = await Permission.notification.request();
  }
  if (status.isGranted) {
    print('permission already granted');
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
      try {
        OpenFile.open(currentfilepath);
      } catch (e) {
        print('here is err $e');
      }
      print('path is $currentfilepath');
    });
  }
}

class DownloadManager {
  Future<String> download(
      String videoId, void Function(double) updateProgress) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var info = manifest.audioOnly.withHighestBitrate();
    var stream = yt.videos.streamsClient.get(info);
    var file = File('/storage/emulated/0/Download/xyz19.mp3');
    var fileStream = file.openWrite();

    int downloadedBytes = 0;

    await for (List<int> chunk in stream) {
      fileStream.add(chunk);
      downloadedBytes += chunk.length;
      double progress = downloadedBytes / (1024 * 1024);
      updateProgress(progress);
    }

    await fileStream.flush();
    await fileStream.close();

    print('Downloaded');
    yt.close();

    return info.url.toString();
  }
}
