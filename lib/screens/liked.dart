import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';

class Liked extends StatefulWidget {
  const Liked({super.key});

  @override
  State<Liked> createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  final upNextVideos = <MediaItem>[];
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  Future<void> removeMapById(String idToRemove) async {
    print('logging from removemap');
    try {
      for (var i = 0; i < likedBox.length; i++) {
        var map = likedBox.getAt(i);
        if (map is Map && map.containsKey('id') && map['id'] == idToRemove) {
          likedBox.deleteAt(i);
          print('Map with id $idToRemove removed from LikedBox');
          i--;
        }
      }
      setState(() {});
    } catch (e) {
      print('error is $e');
    }
  }

  geturl(String id) {
    return getlink(id).toString();
  }

  // Future<MediaItem> _songToMediaItem(Map<String, dynamic> song) async {
  //   String theurl = await getlink(song['id']).toString();
  //   print('the audio url is ${theurl.toString()}');
  //   return MediaItem(
  //     id: song['id'],
  //     title: song['title'],
  //     artist: song['artist'],
  //     extras: {'url': theurl},
  //   );
  // }

  // Future<void> addSongsToQueue(
  //     List<Map<String, dynamic>> songs, int index) async {
  //   print(songs);
  //   await audioHandler.stop();
  //   audioHandler.queue.value.clear();

  //   final mediaItems = songs.map(_songToMediaItem).toList();
  //   print('the mediaItems are $mediaItems');

  //   // await audioHandler.addQueueItems(mediaItems);
  //   // await audioHandler.skipToQueueItem(index);
  //   // await audioHandler.play();
  // }
//   MediaItem _songToMediaItem(Map<String, dynamic> song, String url) {
//     print('the song url is ${song['url']}');
//     return MediaItem(
//       id: song['id'],
//       title: song['title'],
//       artist: song['artist'],
//       extras: {'url': url}, // Ensure 'url' key is used correctly
//     );
//   }

// // Function to add list of SongModel to queue
//   Future<void> addSongsToQueue(
//       List<Map<String, dynamic>> songs, int index) async {
//     print(songs);

//     // Stop the current playback and clear the queue
//     await audioHandler.stop();
//     audioHandler.queue.value.clear();

//     // Resolve URLs asynchronously
//     final List<Future<MediaItem>> mediaItemFutures = songs.map((song) async {
//       final url = await getlink(song['id']);
//       return _songToMediaItem(song, url);
//     }).toList();

//     // Wait for all futures to complete and collect the MediaItems
//     final mediaItems = await Future.wait(mediaItemFutures);

//     // Add MediaItem list to the queue
//     await audioHandler.addQueueItems(mediaItems);
//     await audioHandler.skipToQueueItem(index);
//     await audioHandler.play();
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('liked'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchQuery.value = value;
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white24,
                    contentPadding: EdgeInsets.symmetric(vertical: 0)),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, child) {
                return ValueListenableBuilder(
                  valueListenable: likedBox.listenable(),
                  builder: (_, Box<dynamic> value, __) {
                    var allValues = value.values.toList();
                    var filteredValues = allValues
                        .where((item) => item is Map<dynamic, dynamic>)
                        .map((item) => Map<String, dynamic>.from(item as Map))
                        .where((item) =>
                            item['title']
                                .toLowerCase()
                                .contains(query.toLowerCase()) ||
                            item['artist']
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                        .toList()
                        .reversed
                        .toList();

                    if (filteredValues.isEmpty) {
                      return emptyscreen('no added tracks', ':)');
                    }
                    return ListView.builder(
                      itemCount: filteredValues.length,
                      itemBuilder: (cntxt, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: ListTile(
                            onTap: () async {
                              // await audioHandler.stop();
                              // audioHandler.queue.value.clear();
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => const songinfo()));
                              // for (var content in filteredValues) {
                              //   upNextVideos.add(
                              //     MediaItem(
                              //       id: content['id'].toString(),
                              //       title: content['title'].toString(),
                              //       artist: content['artist'].toString(),
                              //       extras: {
                              //         'url': await getlink(
                              //             content['id'].toString())
                              //       },
                              //       artUri: Uri.parse(
                              //           'https://img.youtube.com/vi/${content['id'].toString()}/sddefault.jpg'),
                              //     ),
                              //   );
                              // }
                              // audioHandler.addQueueItems(upNextVideos);

                              // await audioHandler.skipToQueueItem(index);
                              // await audioHandler.play();
                              // audioHandler.stop();
                              // audioHandler.queue.value.clear();
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => const songinfo()));

                              // await audioHandler.addQueueItem(MediaItem(
                              //   id: filteredValues[index]['id'].toString(),
                              //   title:
                              //       filteredValues[index]['title'].toString(),
                              //   artist:
                              //       filteredValues[index]['artist'].toString(),
                              //   extras: {
                              //     'url': filteredValues[index]['url'].toString()
                              //   },
                              //   artUri: Uri.parse(
                              //       'https://img.youtube.com/vi/${filteredValues[index]['id'].toString()}/maxresdefault.jpg'),
                              // ));

                              // **old method**
                              // audioHandler.addQueueItem(MediaItem(
                              //   id: filteredValues[index]['id'].toString(),
                              //   title:
                              //       filteredValues[index]['title'].toString(),
                              //   artist:
                              //       filteredValues[index]['artist'].toString(),
                              //   extras: {
                              //     'url': await getlink(
                              //         filteredValues[index]['id'].toString())
                              //   },
                              //   artUri: Uri.parse(
                              //       'https://img.youtube.com/vi/${filteredValues[index]['id'].toString()}/maxresdefault.jpg'),
                              // ));

                              // audioHandler.skipToQueueItem(0);

                              // await audioHandler.skipToQueueItem(index);
                              // audioHandler.play();
                              // getUpNextVideos(
                              //     filteredValues[index]['id'].toString());
                              print('the liked songs are $filteredValues');
                              addSongsToQueue(filteredValues, index, context);
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/dummy.png',
                                image:
                                    'https://img.youtube.com/vi/${filteredValues[index]['id']}/maxresdefault.jpg',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              filteredValues[index]['title'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              filteredValues[index]['artist'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await removeMapById(
                                          filteredValues[index]['id']);
                                    },
                                    child: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: Colors.green,
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              alignment: Alignment.topCenter,
                                              decoration: BoxDecoration(
                                                color: black3.withOpacity(0.7),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  topRight: Radius.circular(25),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 16,
                                                            bottom: 40),
                                                    width: 50,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 16.0),
                                                    child: ListTile(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CreatePlaylistPage()));
                                                      },
                                                      leading: Container(
                                                        width: 50,
                                                        height: 50,
                                                        margin: const EdgeInsets
                                                            .all(4),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          child: Image.asset(
                                                              'assets/add.png'),
                                                        ),
                                                      ),
                                                      title: const Text(
                                                          'Create New Playlist'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child:
                                                          ValueListenableBuilder(
                                                              valueListenable:
                                                                  playlistBox
                                                                      .listenable(),
                                                              builder: (_,
                                                                  playlists,
                                                                  __) {
                                                                if (playlists
                                                                    .values
                                                                    .isEmpty) {
                                                                  return Container(
                                                                      height:
                                                                          0.1);
                                                                }
                                                                return ListView
                                                                    .builder(
                                                                  itemCount:
                                                                      playlists
                                                                          .values
                                                                          .length, // Assuming playlistBox contains your playlists
                                                                  itemBuilder:
                                                                      (context,
                                                                          idx) {
                                                                    final playlist =
                                                                        playlists
                                                                            .getAt(idx);

                                                                    return ListTile(
                                                                      onTap:
                                                                          () {
                                                                        checkIfSongExistInsidePlaylist(filteredValues[index]['id'].toString(),
                                                                                playlist['playlistName'])
                                                                            ? removeSongFromPlaylist(
                                                                                playlist['playlistName'],
                                                                                filteredValues[index]['id'].toString(),
                                                                              )
                                                                            : addSongToPlaylist(
                                                                                playlist['playlistName'],
                                                                                {
                                                                                  "id": filteredValues[index]['id'].toString(),
                                                                                  "title": filteredValues[index]['title'].toString(),
                                                                                  "artist": filteredValues[index]['artist'].toString()
                                                                                },
                                                                              );
                                                                      },
                                                                      leading:
                                                                          Container(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        margin: const EdgeInsets
                                                                            .all(
                                                                            4),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(4),
                                                                          child:
                                                                              Image.file(
                                                                            File(playlist['playlistThumbnail']),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      title:
                                                                          Text(
                                                                        playlist[
                                                                            'playlistName'],
                                                                      ),
                                                                      trailing: checkIfSongExistInsidePlaylist(
                                                                              filteredValues[index]['id'].toString(),
                                                                              playlist['playlistName'])
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
                                      child: const Icon(Icons.more_vert)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MiniPlayer(),
    );
  }
}
