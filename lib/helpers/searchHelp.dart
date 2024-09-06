import 'package:audio_service/audio_service.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/formet.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

searchSongs(String query) async {
  print("here");
  try {
    var ytExplode = YoutubeExplode();
    var searchList = await ytExplode.search.search(query);
    print("logging $searchList");
    return formetVideolist(searchList);
  } catch (e) {
    print("error is $e");
  }
}

getUpNextVideos(String videoId) async {
  final url = 'https://www.youtube.com/watch?v=$videoId';
  final response = await http.get(Uri.parse(url));
  String initialDataScript = '';
  if (response.statusCode != 200) {
    throw Exception('Failed to load YouTube page');
  }

  final document = parse(response.body);
  final scripts = document.getElementsByTagName('script');

  // Find the script tag containing the initial data
  // String initialDataScript;
  for (var script in scripts) {
    if (script.text.contains('var ytInitialData')) {
      initialDataScript = script.text;
      break;
    }
  }

  if (initialDataScript == null) {
    throw Exception('Failed to find initial data script');
  }

  // Extract JSON data from the script
  final jsonData = initialDataScript.substring(
      initialDataScript.indexOf('{'), initialDataScript.lastIndexOf('}') + 1);
  final data = jsonDecode(jsonData);

  // Navigate through the JSON data to find the "up next" videos
  final upNextVideos = <MediaItem>[];
  final contents = data['contents']['twoColumnWatchNextResults']
      ['secondaryResults']['secondaryResults']['results'];

  for (var content in contents) {
    if (content.containsKey('compactVideoRenderer')) {
      final video = content['compactVideoRenderer'];
      final videoId = video['videoId'];
      final title = video['title']['simpleText'];
      final artist = video['shortBylineText']['runs'][0]['text'];

      upNextVideos.add(
        MediaItem(
          id: videoId.toString(),
          title: title.toString(),
          artist: artist.toString(),
          extras: {'url': await getlink(videoId.toString())},
          artUri: Uri.parse(
              'https://img.youtube.com/vi/${videoId.toString()}/maxresdefault.jpg'),
        ),
      );
    }
  }

  // audioHandler.addQueueItems([
  // MediaItem(
  //   id: '1',
  //   title: vidList[index]['title'].toString(),
  //   artist: vidList[index]['artist'].toString(),
  //   extras: {'url': theurl},
  //   artUri: Uri.parse(
  //       'https://img.youtube.com/vi/${vidList[index]['id'].toString()}/sddefault.jpg'),
  // ),
  // ]);
  audioHandler.addQueueItems(upNextVideos);
  print(upNextVideos);
}

// void main() async {
//   final videoId = 'YOUR_VIDEO_ID_HERE';
//   final upNextVideos = await getUpNextVideos(videoId);

//   for (var video in upNextVideos) {
//     print('Video ID: ${video['videoId']}');
//     print('Title: ${video['title']}');
//     print('Channel Name: ${video['channelName']}');
//     print('---');
//   }
// }

Future<void> fetchThumbnail(id) async {
  var youtube = YoutubeExplode();
  var video = await youtube.videos.get(id);
  var thumbnails = video.thumbnails;

  print('the thumbnail is ${[
    thumbnails.highResUrl,
    thumbnails.lowResUrl,
    thumbnails.maxResUrl,
    thumbnails.mediumResUrl,
    thumbnails.standardResUrl
  ]}');

  // Close the YoutubeExplode client
  youtube.close();
}

// lib/youtube_suggestions.dart

Future<List<String>> fetchSuggestions(String query) async {
  final url =
      'http://suggestqueries.google.com/complete/search?client=youtube&ds=yt&q=$query';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data =
        jsonDecode(response.body.substring(19, response.body.length - 1));

    // Cast the dynamic list to a List<String>
    print(List<String>.from(data[1].map((item) => item[0].toString())));
    return List<String>.from(data[1].map((item) => item[0].toString()));
  } else {
    return [];
  }
}
