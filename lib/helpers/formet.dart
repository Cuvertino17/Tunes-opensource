import 'package:youtube_explode_dart/youtube_explode_dart.dart';

formetVideolist(videolist) {
  print(videolist);
  var vids = [];
  for (var video in videolist) {
    print(video.author);
    vids.add({
      'id': video.id,
      'title': video.title,
      'artist': video.author,
      'thumb': 'https://img.youtube.com/vi/${video.id}/mqdefault.jpg'
    });
  }

  return vids;
}

String processString(String input) {
  try {
    // Remove special characters
    String withoutSpecialChars = input.replaceAll(RegExp(r'[^\w\s]'), '');

    // Trim and limit length to 20 characters
    String processedString = withoutSpecialChars
        .trim()
        .substring(0, withoutSpecialChars.length.clamp(0, 20));

    return processedString;
  } catch (e) {
    return input;
  }
}
