import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';

class recents extends StatefulWidget {
  const recents({super.key});

  @override
  State<recents> createState() => _recentsState();
}

class _recentsState extends State<recents> {
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
      for (var i = 0; i < RecentBox.length; i++) {
        var map = RecentBox.getAt(i);
        if (map is Map && map.containsKey('id') && map['id'] == idToRemove) {
          RecentBox.deleteAt(i);
          print('Map with id $idToRemove removed from LikedBox');
          i--;
        }
      }
      setState(() {});
    } catch (e) {
      print('error is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('recents'),
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
              builder: (_, query, __) {
                return ValueListenableBuilder(
                  valueListenable: RecentBox.listenable(),
                  builder: (context, Box<dynamic> value, child) {
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
                              // audioHandler.stop();
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
                              // MediaItem(
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
                              // );
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
                              // audioHandler.play();
                              // getUpNextVideos(
                              //     filteredValues[index]['id'].toString());
                              // await addSongsToQueue(filteredValues, index);
                              addSongsToQueue(filteredValues, index, context);
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/dummy.png',
                                image:
                                    'https://img.youtube.com/vi/${filteredValues[index]['id']}/mqdefault.jpg',
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
