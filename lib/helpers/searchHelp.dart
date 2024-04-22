import 'package:musichub/helpers/formet.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

searchSongs(String query) async {
  var ytExplode = YoutubeExplode();
  var searchList = await ytExplode.search.search(query);
  return formetVideolist(searchList);
}
