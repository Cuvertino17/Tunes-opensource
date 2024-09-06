import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:musichub/screens/downloaded.dart';
import 'package:musichub/screens/liked.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/screens/playlistpage.dart';
import 'package:musichub/screens/recents.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';

class homeAlbumsUI extends StatelessWidget {
  const homeAlbumsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const Padding(
        //   padding: EdgeInsets.all(8.0),
        //   child: Align(
        //       alignment: Alignment.centerLeft,
        //       child: Text(
        //         'Albums',
        //         style: TextStyle(fontSize: 18),
        //       )),
        // ),
        SizedBox(
          height: 130, // Adjust height as needed
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const already()));
                },
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      // height: 115,
                      // width: 80, // Adjust width as needed
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/2.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: green,
                        ),
                        Text('download'),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Liked()));
                },
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      // height: 115,
                      // width: 80, // Adjust width as needed
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/0.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: green,
                        ),
                        Text('liked'),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const recents()));
                },
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      // height: 115,
                      // width: 80, // Adjust width as needed
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: green,
                        ),
                        Text('recents'),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreatePlaylistPage()));
                },
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      // height: 115,
                      // width: 80, // Adjust width as needed
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/add.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        // Icon(
                        //   Icons.push_pin_rounded,
                        //   size: 16,
                        //   color: green,
                        // ),
                        Text('add new'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomePlaylistsUI extends StatelessWidget {
  const HomePlaylistsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('playlists').listenable(),
        builder: (_, playlists, __) {
          if (playlists.values.isEmpty) {
            return Container(height: 0.1);
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Playlists',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
              SizedBox(
                height: 190, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: playlists.values.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists.getAt(index);

                    return GestureDetector(
                      onTap: () {
                        // Retrieve the playlist songs and create the notifier
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          final playlist = playlists.getAt(index);

                          return PlaylistPage(
                            name: playlist['playlistName'],
                          );
                        }));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            margin: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.file(
                                File(playlist['playlistThumbnail']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Text(
                              playlist[
                                  'playlistName'], // Replace with actual playlist name
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }
}

class homeRecentlyPlayedUI extends StatelessWidget {
  const homeRecentlyPlayedUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recently played',
                style: TextStyle(fontSize: 18),
              )),
        ),
        ValueListenableBuilder(
            valueListenable: RecentBox.listenable(),
            builder: (_, recentList, __) {
              final newList = recentList.values.toList().reversed.toList();

              if (recentList.values.isEmpty) {
                // print(recentList.values.toList()[2]['title']);
                return const Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Icon(Icons.info_outline),
                    SizedBox(
                      height: 20,
                    ),
                    Text('no songs played yet'),
                  ],
                );
              } else {
                return ListView.builder(
                  // reverse: true,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling independently
                  itemCount: recentList.values.length >= 10
                      ? 10
                      : recentList.values.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () async {
                          await audioHandler.stop();
                          audioHandler.queue.value.clear();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const songinfo()));
                          String theurl =
                              await getlink(newList[index]['id'].toString());
                          audioHandler.addQueueItems([
                            MediaItem(
                              id: newList[index]['id'] as String,
                              title: newList[index]['title'] as String,
                              artist: newList[index]['artist'] as String,
                              extras: {'url': theurl},
                              artUri: Uri.parse(
                                  'https://img.youtube.com/vi/${newList[index]['id'].toString()}/maxresdefault.jpg'),
                            ),
                          ]);
                          await audioHandler.skipToQueueItem(0);
                          audioHandler.play();
                          getUpNextVideos(newList[index]['id'].toString());
                        },
                        minLeadingWidth: 50,
                        leading: SizedBox(
                          height: 50,
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/dummy.png',
                              image: newList[index]['thumb'],
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          newList[index]['title'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(newList[index]['artist'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12)),
                        trailing: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
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
                                          margin: const EdgeInsets.only(
                                              top: 16, bottom: 40),
                                          width: 50,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        // Container(
                                        //   margin: const EdgeInsets.only(
                                        //       top: 16, bottom: 40),
                                        //   // width: 50,
                                        //   // height: 5,
                                        //   child: Text(
                                        //     newList[index]['title'],
                                        //     overflow: TextOverflow.ellipsis,
                                        //     maxLines: 1,
                                        //     style:
                                        //         const TextStyle(fontSize: 14),
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreatePlaylistPage()));
                                            },
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              margin: const EdgeInsets.all(4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.asset(
                                                    'assets/add.png'),
                                              ),
                                            ),
                                            title: const Text(
                                                'Create New Playlist'),
                                          ),
                                        ),
                                        Expanded(
                                            child: ValueListenableBuilder(
                                                valueListenable:
                                                    playlistBox.listenable(),
                                                builder: (_, playlists, __) {
                                                  if (playlists
                                                      .values.isEmpty) {
                                                    return Container(
                                                        height: 0.1);
                                                  }
                                                  return ListView.builder(
                                                    itemCount: playlists.values
                                                        .length, // Assuming playlistBox contains your playlists
                                                    itemBuilder:
                                                        (context, idx) {
                                                      final playlist =
                                                          playlists.getAt(idx);

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8.0),
                                                        child: ListTile(
                                                          onTap: () {
                                                            checkIfSongExistInsidePlaylist(
                                                                    newList[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                                    playlist[
                                                                        'playlistName'])
                                                                ? removeSongFromPlaylist(
                                                                    playlist[
                                                                        'playlistName'],
                                                                    newList[index]
                                                                            [
                                                                            'id']
                                                                        .toString(),
                                                                  )
                                                                : addSongToPlaylist(
                                                                    playlist[
                                                                        'playlistName'],
                                                                    {
                                                                      "id": newList[index]
                                                                              [
                                                                              'id']
                                                                          .toString(),
                                                                      "title": newList[index]
                                                                              [
                                                                              'title']
                                                                          .toString(),
                                                                      "artist": newList[index]
                                                                              [
                                                                              'artist']
                                                                          .toString()
                                                                    },
                                                                  );
                                                          },
                                                          leading: Container(
                                                            width: 50,
                                                            height: 50,
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              child: Image.file(
                                                                File(playlist[
                                                                    'playlistThumbnail']),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            playlist[
                                                                'playlistName'],
                                                          ),
                                                          trailing: checkIfSongExistInsidePlaylist(
                                                                  newList[index]
                                                                          ['id']
                                                                      .toString(),
                                                                  playlist[
                                                                      'playlistName'])
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_outline_rounded,
                                                                  color: green,
                                                                )
                                                              : const Icon(
                                                                  FeatherIcons
                                                                      .plusCircle),
                                                        ),
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
                      ),
                    );
                  },
                );
              }
            })
      ],
    );
  }
}
