import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:musichub/main.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:musichub/screens/downloaded.dart';
import 'package:musichub/screens/liked.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/screens/recents.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';

var alreadyBox = Hive.box('already');
var RecentBox = Hive.box('recents');
var Audiosetting = Hive.box('setting');
var history = Hive.box('history');
var likedBox = Hive.box('liked');
var LoginBox = Hive.box('login');
var playlistBox = Hive.box('playlists');
final audioHandler = getIt<AudioHandler>();
final playlistUpdateNotifier = ValueNotifier<String>('');

class PlaylistUpdateNotifier extends ChangeNotifier {
  void notifyPlaylistUpdated() {
    print('updated');
    notifyListeners();
  }
}

Widget emptyscreen(String mssg, String logo) {
  return Center(
      child: Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mssg,
          style: const TextStyle(fontSize: 25),
        ),
        Text(
          ' $logo',
          style: const TextStyle(fontSize: 30, color: Color(0xff1DB954)),
        )
      ],
    ),
  ));
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        print('the title is $title');
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 40)),
        );
      },
    );
  }
}

class ThumbnailWidget extends StatefulWidget {
  final String imageUrl;

  ThumbnailWidget({required this.imageUrl});

  @override
  _ThumbnailWidgetState createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    fetchAndProcessImage();
  }

  @override
  void didUpdateWidget(covariant ThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      fetchAndProcessImage();
    }
  }

  Future<void> fetchAndProcessImage() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      final imageBytes = response.bodyBytes;
      final image = img.decodeImage(imageBytes);

      if (image != null) {
        // Crop to square if necessary
        final size = image.width < image.height ? image.width : image.height;
        final x = (image.width - size) ~/ 2;
        final y = (image.height - size) ~/ 2;

        final croppedImage = img.copyCrop(
          image,
          x: x,
          y: y,
          width: size,
          height: size,
        );

        // Resize to 300x300
        final resizedImage =
            img.copyResize(croppedImage, width: 300, height: 300);
        final pngBytes = img.encodePng(resizedImage);

        setState(() {
          imageData = Uint8List.fromList(pngBytes);
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        imageData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageData == null
        ? const Center(child: CircularProgressIndicator())
        : Image.memory(imageData!);
  }
}

class playlistaddoptions extends StatefulWidget {
  const playlistaddoptions(
      {super.key,
      required this.id,
      required this.song,
      required this.thecntxt});

  final id;
  final song;
  final BuildContext thecntxt;

  @override
  State<playlistaddoptions> createState() => _playlistaddoptionsState();
}

class _playlistaddoptionsState extends State<playlistaddoptions> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: widget.thecntxt,
            builder: (BuildContext context) {
              return Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: black3.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 40),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: playlistBox.listenable(),
                            builder: (_, playlists, __) {
                              if (playlists.values.isEmpty) {
                                print('its triggred');
                                return Container(height: 0.1);
                              }
                              return ListView.builder(
                                itemCount: playlists.values
                                    .length, // Assuming playlistBox contains your playlists
                                itemBuilder: (context, index) {
                                  final playlist = playlists.getAt(index);
                                  return ListTile(
                                    onTap: () {
                                      print('im here ${widget.song}');
                                      print(widget.song);
                                      checkIfSongExistInsidePlaylist(
                                          widget.id, playlist['playlistName']);
                                      // addSongToPlaylist(
                                      //     playlist['playlistName'],
                                      //     widget.song);
                                    },
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.all(4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.file(
                                          File(playlist['playlistThumbnail']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      playlist['playlistName'],
                                    ),
                                    trailing: checkIfSongExistInsidePlaylist(
                                            widget.id, playlist['playlistName'])
                                        ? const Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: green,
                                          )
                                        : const Icon(FeatherIcons.plusCircle),
                                  );
                                },
                              );
                            })),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.more_vert));
  }
}

checkliked() {
  final pageManager = getIt<PageManager>();
  final id = pageManager.currentSongIdNotifier.value;

  bool valueExists(list, String value) {
    return list.any((map) {
      return map['id'] == value;
    });
  }

  bool exists = valueExists(likedBox.values, id);
  if (exists) {
    return true;
  } else {
    return false;
  }
  // exists ? isliked = true : isliked = false;
  // exists ? return true : return false;
  // print("the song is $isliked");
}

addToLikedSongs() async {
  final pageManager = getIt<PageManager>();
  final metadata = pageManager.currentMedataMap.value;

  if (metadata.containsKey("id") &&
      metadata.containsKey("title") &&
      metadata.containsKey("artist") &&
      metadata.containsKey("thumb")) {
    final id = metadata["id"];
    final title = metadata["title"];
    final artist = metadata["artist"];

    if (id != null && title != null && artist != null) {
      await likedBox.add({
        "id": id,
        "title": title,
        "artist": artist,
      });
    }
  }
}

bool checkIfSongExistInsidePlaylist(String songId, String playlistName) {
  final playlistBox = Hive.box('playlists');
  print("the recived song id is $songId");
  // Function to find the playlist by name and check if the song exists
  bool valueExists(List<dynamic> list, String playlistName) {
    return list.any((map) {
      // Check if the current map has the playlist name
      if (map['playlistName'] == playlistName) {
        // Check if the song ID exists in the playlistSongs list
        return (map['playlistSongs'] as List<dynamic>).any((song) {
          print(song['id'] == songId);
          print(songId);
          return song['id'] == songId;
        });
      }
      return false;
    });
  }

  // Convert playlistBox.values to a list and check if the song exists
  bool exists = valueExists(playlistBox.values.toList(), playlistName);

  print(
      exists ? 'Song exists in playlist.' : 'Song does not exist in playlist.');
  return exists;
}

// void addSongToPlaylist(String playlistName, Map<String, String> song) async {
//   // Access the Hive box
//   final playlistBox = Hive.box('playlists');

//   // Find the playlist with the given name
//   final int playlistIndex = playlistBox.values
//       .toList()
//       .indexWhere((playlist) => playlist['playlistName'] == playlistName);

//   if (playlistIndex != -1) {
//     // Retrieve the playlist
//     final playlist = playlistBox.getAt(playlistIndex);

//     // Directly add the song to the playlistSongs list
//     List<dynamic> playlistSongs = List.from(playlist['playlistSongs']);
//     playlistSongs.add(song);

//     // Update only the playlistSongs in the Hive entry
//     playlist['playlistSongs'] = playlistSongs;

//     // Save the updated playlist back to Hive
//     await playlistBox.putAt(playlistIndex, playlist);

//     print(playlist['playlistSongs']);
//     playlistUpdateNotifier.value = '';
//     // playlistUpdateNotifier.notifyPlaylistUpdated();
//     print('Song added to playlist successfully.');
//   } else {
//     print('Playlist not found.');
//   }
// }

// void removeSongFromPlaylist(String playlistName, String songId) async {
//   // Access the Hive box
//   final playlistBox = Hive.box('playlists');

//   // Find the playlist with the given name
//   final int playlistIndex = playlistBox.values
//       .toList()
//       .indexWhere((playlist) => playlist['playlistName'] == playlistName);

//   if (playlistIndex != -1) {
//     // Retrieve the playlist
//     final playlist = playlistBox.getAt(playlistIndex);

//     // Remove the song from the playlistSongs list
//     List<dynamic> playlistSongs = List.from(playlist['playlistSongs']);
//     playlistSongs.removeWhere((song) => song['id'] == songId);

//     // Update only the playlistSongs in the Hive entry
//     playlist['playlistSongs'] = playlistSongs;

//     // Save the updated playlist back to Hive
//     await playlistBox.putAt(playlistIndex, playlist);

//     print(playlist['playlistSongs']);
//     playlistUpdateNotifier.value = '';

//     // playlistUpdateNotifier.notifyPlaylistUpdated();
//     print('Song removed from playlist successfully.');
//   } else {
//     print('Playlist not found.');
//   }
// }

void addSongToPlaylist(String playlistName, Map<String, String> song) async {
  // Access the Hive box
  final playlistBox = Hive.box('playlists');

  // Find the playlist with the given name
  final int playlistIndex = playlistBox.values
      .toList()
      .indexWhere((playlist) => playlist['playlistName'] == playlistName);

  if (playlistIndex != -1) {
    // Retrieve the playlist
    final playlist =
        Map<String, dynamic>.from(playlistBox.getAt(playlistIndex));

    // Add the song to the playlistSongs list
    List<Map<String, String>> playlistSongs =
        List<Map<String, String>>.from(playlist['playlistSongs']);
    playlistSongs.add(song);

    // Update the playlist map
    playlist['playlistSongs'] = playlistSongs;

    // Save the updated playlist back to Hive
    await playlistBox.putAt(playlistIndex, playlist);

    // Notify listeners about the update
    playlistUpdateNotifier.value = '';

    print('Song added to playlist successfully.');
  } else {
    print('Playlist not found.');
  }
}

void removeSongFromPlaylist(String playlistName, String songId) async {
  // Access the Hive box
  final playlistBox = Hive.box('playlists');

  // Find the playlist with the given name
  final int playlistIndex = playlistBox.values
      .toList()
      .indexWhere((playlist) => playlist['playlistName'] == playlistName);

  if (playlistIndex != -1) {
    // Retrieve the playlist
    final playlist =
        Map<String, dynamic>.from(playlistBox.getAt(playlistIndex));

    // Remove the song from the playlistSongs list
    List<Map<dynamic, dynamic>> playlistSongs =
        List<Map<dynamic, dynamic>>.from(playlist['playlistSongs']);
    playlistSongs.removeWhere((song) => song['id'] == songId);

    // Update the playlist map
    playlist['playlistSongs'] = playlistSongs;

    // Save the updated playlist back to Hive
    await playlistBox.putAt(playlistIndex, playlist);

    // Notify listeners about the update
    playlistUpdateNotifier.value = '';

    print('Song removed from playlist successfully.');
  } else {
    print('Playlist not found.');
  }
}

MediaItem _songToMediaItem(Map<String, dynamic> song, String url) {
  print('the song url is ${song['url']}');
  return MediaItem(
    id: song['id'] as String,
    title: song['title'] as String,
    artist: song['artist'] as String,
    extras: {'url': url},
    artUri:
        Uri.parse('https://img.youtube.com/vi/${song['id']}/maxresdefault.jpg'),
    // Ensure 'url' key is used correctly
  );
}

// Function to add list of SongModel to queue
// Future<void> addSongsToQueue(
//     List<Map<String, dynamic>> songs, int index, BuildContext context) async {
//   // print(songs);

//   // Stop the current playback and clear the queue
//   await audioHandler.stop();
//   audioHandler.queue.value.clear();
//   Navigator.of(context)
//       .push(MaterialPageRoute(builder: (context) => const songinfo()));
//   // Resolve URLs asynchronously
//   final List<Future<MediaItem>> mediaItemFutures = songs.map((song) async {
//     final url = await getlink(song['id']);
//     return _songToMediaItem(song, url);
//   }).toList();

//   // Wait for all futures to complete and collect the MediaItems
//   final mediaItems = await Future.wait(mediaItemFutures);

//   // Add MediaItem list to the queue
//   await audioHandler.addQueueItems(mediaItems);
//   await audioHandler.skipToQueueItem(index);
//   await audioHandler.play();
// }

Future<void> addSongsToQueue(
    List<Map<String, dynamic>> songs, int index, BuildContext context) async {
  // print('Received so');
  // print('Received songs list: ${songs.isEmpty} items2');
  try {
    // print('Received songs list: ${songs} items');

    // Iterate through the list and check each element
    // for (var i = 0; i < songs.length; i++) {
    //   print('Item at index $i: ${songs[i]} (type: ${songs[i].runtimeType})');
    // }

    // Ensure songs list is of the correct type
    final List<Map<String, dynamic>> typedSongs = songs
        .where((item) {
          if (item == null) {
            // print('Found null item in the songs list');
            return false;
          } else if (item is! Map<String, dynamic>) {
            // print('Found an item that is not a Map<String, dynamic>: $item');
            return false;
          } else {
            return true;
          }
        })
        .map((item) => Map<String, dynamic>.from(item!)) // Ensure correct type
        .toList();

    // print('All valid songs: $typedSongs');

    // Stop the current playback and clear the queue
    await audioHandler.stop();
    audioHandler.queue.value.clear();

    // Navigate to song info page
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const songinfo()));

    // Resolve URLs asynchronously
    final List<Future<MediaItem?>> mediaItemFutures =
        typedSongs.map((song) async {
      try {
        final url = await getlink(song['id']);
        print('Fetched URL for ${song['id']}: $url');
        return _songToMediaItem(song, url);
      } catch (e) {
        print('Error fetching URL for ${song['id']}: $e');
        return null;
      }
    }).toList();

    // Wait for all futures to complete and collect the MediaItems
    final List<MediaItem?> mediaItems = await Future.wait(mediaItemFutures);

    // Filter out any null MediaItems
    final List<MediaItem> nonNullMediaItems =
        mediaItems.whereType<MediaItem>().toList();

    // Add MediaItem list to the queue
    await audioHandler.addQueueItems(nonNullMediaItems);
    await audioHandler.skipToQueueItem(index);
    await audioHandler.play();
  } catch (e, stacktrace) {
    print('Error in addSongsToQueue: $e');
    print('Stacktrace: $stacktrace');
  }
}

Widget buyMeACoffeePopUp(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
    ),
    contentPadding: const EdgeInsets.all(16.0),
    content: SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "hello! users",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'If you love the app and want to support the creator, consider donating or buying me a coffee!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  // fontSize: 16.0,
                  ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/unnamed.png', // Replace with your image asset path
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await launchBuyMeACoffee();
              },
              icon: const Icon(Icons.coffee),
              label: const Text('Support Creator'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
