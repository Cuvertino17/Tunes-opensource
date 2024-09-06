import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/themes/colors.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key, required this.name});
  final String name;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.name),
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
                  valueListenable: playlistBox.listenable(),
                  builder: (_, playlists, __) {
                    final newList = playlists.values.toList();
                    final int playlistIndex = playlists.values
                        .toList()
                        .indexWhere((playlist) =>
                            playlist['playlistName'] == widget.name);

                    if (newList[playlistIndex]['playlistSongs'].length <= 0) {
                      return const Center(
                          child: Text('No songs in this playlist.'));
                    }

                    return ListView.builder(
                      itemCount: newList[playlistIndex]['playlistSongs'].length,
                      itemBuilder: (cntxt, index) {
                        // print(' ${newList[playlistIndex]['playlistSongs'][index]}');

                        return ListTile(
                          onTap: () {
                            // Convert each song in the playlist to the desired format
                            final List<Map<String, dynamic>> updatedSongsList =
                                (newList[playlistIndex]['playlistSongs']
                                        as List<dynamic>)
                                    .map((song) {
                              return {
                                'id': song['id'],
                                'title': song['title'],
                                'artist': song['artist'],
                                'url': song[
                                    'id'], // Assuming the 'id' is used as the URL here
                              };
                            }).toList();

                            print('Updated songs list: $updatedSongsList');

                            // Call addSongsToQueue with the updated songs list
                            addSongsToQueue(
                              updatedSongsList,
                              index,
                              context,
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/dummy.png',
                              image:
                                  'https://img.youtube.com/vi/${newList[playlistIndex]['playlistSongs'][index]['id']}/maxresdefault.jpg',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            newList[playlistIndex]['playlistSongs'][index]
                                ['title'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            newList[playlistIndex]['playlistSongs'][index]
                                ['title'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              removeSongFromPlaylist(
                                widget.name,
                                newList[playlistIndex]['playlistSongs'][index]
                                        ['id'] ??
                                    '',
                              );
                            },
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






// class PlaylistPage extends StatefulWidget {
//   const PlaylistPage({super.key, required this.name, required this.songs});
//   final String name;
//   final List<Map> songs;

//   @override
//   State<PlaylistPage> createState() => _PlaylistPageState();
// }

// class _PlaylistPageState extends State<PlaylistPage> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print(widget.songs);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.name),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: playlistBox.listenable(),
//         builder: (_, playlists, __) {
//           final newList = playlists.values.toList();
//           final int playlistIndex = playlists.values.toList().indexWhere(
//               (playlist) => playlist['playlistName'] == widget.name);
//           print('its triggred yo,${newList[playlistIndex]['playlistSongs']}');
//           if (widget.songs.isEmpty) {
//             return const Center(child: Text('No songs in this playlist.'));
//           }

//           return ListView.builder(
//             itemCount: newList[playlistIndex]['playlistSongs'].length,
//             itemBuilder: (cntxt, index) {
//               // print(' ${newList[playlistIndex]['playlistSongs'][index]}');
//               final updatedlist =
//                   (newList[playlistIndex]['playlistSongs'] as List<dynamic>)
//                       .cast<Map<String, dynamic>>();
//               return ListTile(
//                 // onTap: () {
//                 //   addSongsToQueue(
//                 //     updatedlist,
//                 //     index,
//                 //     context,
//                 //   );
//                 // },
//                 onTap: () {
//                   // Convert each song in the playlist to the desired format
//                   final List<Map<String, dynamic>> updatedSongsList =
//                       (newList[playlistIndex]['playlistSongs'] as List<dynamic>)
//                           .map((song) {
//                     return {
//                       'id': song['id'],
//                       'title': song['title'],
//                       'artist': song['artist'],
//                       'url': song[
//                           'id'], // Assuming the 'id' is used as the URL here
//                     };
//                   }).toList();

//                   print('Updated songs list: $updatedSongsList');

//                   // Call addSongsToQueue with the updated songs list
//                   addSongsToQueue(
//                     updatedSongsList,
//                     index,
//                     context,
//                   );
//                 },

//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(7),
//                   child: FadeInImage.assetNetwork(
//                     placeholder: 'assets/dummy.png',
//                     image:
//                         'https://img.youtube.com/vi/${newList[playlistIndex]['playlistSongs'][index]['id']}/maxresdefault.jpg',
//                     height: 50,
//                     width: 50,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 title: Text(
//                   newList[playlistIndex]['playlistSongs'][index]['title'],
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 subtitle: Text(
//                   newList[playlistIndex]['playlistSongs'][index]['title'],
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 trailing: IconButton(
//                   icon: const Icon(
//                     Icons.remove_circle_outline_rounded,
//                     color: Colors.green,
//                   ),
//                   onPressed: () {
//                     removeSongFromPlaylist(
//                       widget.name,
//                       newList[playlistIndex]['playlistSongs'][index]['id'] ??
//                           '',
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: MiniPlayer(),
//     );
//   }
// }
