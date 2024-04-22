import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

getlink(id) async {
  var yt = YoutubeExplode();

  var manifest = await yt.videos.streamsClient.getManifest(id);
  // var info = manifest.audioOnly.withHighestBitrate();/
  // var info2 = manifest.audioOnly;
  // print(info2[2].url);

  var info = manifest.audioOnly.withHighestBitrate();
  // print(info.url);

  // Pipe all the content of the stream into the file.

  // Close the file.

  return info.url.toString();
}

// import 'dart:io';
// import 'dart:async';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// getlink(id) async {
//   var yt = YoutubeExplode();

//   var manifest = await yt.videos.streamsClient.getManifest(id);
//   var info = manifest.audioOnly.withHighestBitrate();
//   var stream = yt.videos.streamsClient.get(info);
//   var file = File('/storage/emulated/0/Download/xyz19.mp3');
//   var fileStream = file.openWrite();

//   int downloadedBytes = 0;

//   // Corrected function to return Future<void>
//   Future<void> reportProgress(List<int> chunk) async {
//     downloadedBytes += chunk.length;
//     print(
//         'Download progress: ${(downloadedBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
//   }

//   // Pipe all the content of the stream into the file.
//   await for (List<int> chunk in stream) {
//     fileStream.add(chunk);
//     await reportProgress(chunk);
//   }

//   // Close the file.
//   await fileStream.flush();
//   await fileStream.close();

//   print('Downloaded');
//   // yt.close();

//   return info.url.toString();
// }

void launchInstagram() async {
  // Replace "USERNAME" with the Instagram username or "instagram://user?username=USERNAME"
  // with the appropriate Instagram profile URL scheme.
  Uri instagramUrl = Uri.parse('https://www.instagram.com/heil.ra/');

  // Check if the Instagram app is installed, if not, open in a browser.
  if (await canLaunchUrl(instagramUrl)) {
    await launchUrl(instagramUrl);
  } else {
    // If the app is not installed, open the Instagram profile in a browser.
    await launchUrl(instagramUrl, mode: LaunchMode.inAppBrowserView);
  }
}
