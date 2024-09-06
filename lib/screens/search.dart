import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/download.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:musichub/main.dart';
import 'package:musichub/miniplayer.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

// wake up lad

class _homeState extends State<home> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List idList = [];
  List vidList = [];
  double downloadProgress = 0.0;
  bool isdownloading = false;
  bool isSongLoading = false;
  bool isloading = false;
  int _currentSongIndex = -1;
  int _currentDownloadIndex = -1;
  late FocusNode _focusNode;
  List<String> _suggestions = []; // List to hold suggestions

  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _textEditingController.addListener(() {
      // Clear suggestions when the text field is empty
      if (_textEditingController.text.isEmpty) {
        setState(() {
          _suggestions.clear();
        });
      }
    });
  }

  void startDownload(videoUrl, title, author) async {
    AudioDownloader downloader = AudioDownloader();
    // myContr2.interstitialAd!.show();

    await downloader.downloadVideo(title, videoUrl, author,
        (progress, totalsize) {
      downloadProgress = 0.0;
      setState(() {
        downloadProgress = ((progress / totalsize) * 100) / 100;
        if (progress == totalsize) {
          // data.clear();
          setState(() {
            isdownloading = false;
            _currentSongIndex = -1;
            downloadProgress = 0.0;
          });
        }
      });
    });
  }

  void _getSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        final suggestions = await fetchSuggestions(query);
        if (mounted) {
          setState(() {
            _suggestions = suggestions;
          });
        }
      } catch (e) {
        print("Error fetching suggestions: $e");
      }
    } else {
      if (mounted) {
        setState(() {
          _suggestions.clear();
        });
      }
    }
  }

  Widget buildTextContainer(String Txt) {
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 180,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(34, 255, 255, 255),
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: GestureDetector(
            onTap: () async {
              // setState(() {
              //   _textEditingController.text = Txt;

              // });
              _textEditingController.text = Txt;

              _focusNode.unfocus();
              setState(() {
                _suggestions.clear();
                isloading = true;
              });
              try {
                vidList.clear();

                var lis = await searchSongs(_textEditingController.text);

                vidList.addAll(lis);
                setState(() {
                  isloading = false;
                });
              } catch (e) {
                setState(() {
                  isloading = false;
                });
              }
            },
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    // color: Colors.amber,
                    child: Text(
                      Txt,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  // onTap: () {},
                  child: const Icon(
                    FeatherIcons.clock,
                    size: 15,
                  ),
                ),

                // Handle the cross icon press if needed
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          titleSpacing: 4.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("search"),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 40, // Reduced height for a thinner TextField
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color
              borderRadius: BorderRadius.circular(7.0), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0), // Adjusted padding
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    onChanged:
                        _getSuggestions, // Fetch suggestions on input change
                    focusNode: _focusNode,
                    onSubmitted: (value) async {
                      setState(() {
                        isloading = true;
                        // _currentSongIndex = -1;
                        _suggestions.clear();
                      });

                      List recentHistory =
                          history.values.toList().reversed.take(6).toList();

                      if (!recentHistory.contains(value)) {
                        await history.add(value);
                      }

                      try {
                        vidList.clear();

                        var lis = await searchSongs(value);

                        vidList.addAll(lis);
                        setState(() {
                          isloading = false;
                        });
                      } catch (e) {
                        setState(() {
                          isloading = false;
                        });
                      }
                    },
                    style: const TextStyle(
                      color: Color.fromARGB(255, 24, 23, 23),
                    ),
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical:
                              11.8), // Adjust vertical padding to align text centrally
                      hintText: 'What do you want to listen',
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 83, 83, 83),
                        fontSize: 14,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                12.0), // Adjust padding to align icon vertically
                        child: Icon(
                          CupertinoIcons.search,
                          color: Color.fromARGB(255, 101, 100, 100),
                        ),
                      ),
                      suffixIcon: SizedBox(
                        width: 80, // Adjust width to fit icons
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _textEditingController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _textEditingController.clear();
                                        _suggestions.clear();
                                      });
                                    },
                                    child: const Icon(
                                      Icons.clear_rounded,
                                      color: Colors.black,
                                      size: 19,
                                    ),
                                  )
                                : Container(),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isloading = true;
                                  _currentSongIndex = -1;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        8.0), // Adjust padding to align icon vertically
                                child: Icon(
                                  FeatherIcons.arrowUpCircle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () async {
                      _textEditingController.text = _suggestions[index];
                      history.add(_textEditingController.text);
                      _focusNode.unfocus();
                      setState(() {
                        _suggestions.clear();
                        isloading = true;
                      });
                      try {
                        vidList.clear();

                        var lis =
                            await searchSongs(_textEditingController.text);

                        vidList.addAll(lis);
                        setState(() {
                          isloading = false;
                        });
                      } catch (e) {
                        setState(() {
                          isloading = false;
                        });
                      }

                      // Remove focus after selection
                    },
                  );
                },
              ),
            ),
          isloading
              ? const Padding(
                  padding: EdgeInsets.only(top: 190.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: green,
                      ),
                    ),
                  ),
                )
              : vidList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: history.listenable(),
                              builder: (context, value, Widget) {
                                var Rvdvalues =
                                    value.values.toList().reversed.toList();

                                if (value.isEmpty) {
                                  return Container();
                                }
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: (Rvdvalues.length / 2).ceil(),
                                  itemBuilder: (context, index) {
                                    final int startIndex = index * 2;
                                    final int endIndex = startIndex + 1;

                                    if (index < 3) {
                                      final int startIndex = index * 2;
                                      final int endIndex = startIndex + 1;

                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: [
                                            buildTextContainer(
                                                Rvdvalues[startIndex]),
                                            if (endIndex < Rvdvalues.length)
                                              buildTextContainer(
                                                  Rvdvalues[endIndex]),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                const TextSpan(text: 'search'),
                                const TextSpan(
                                    text: ' result : ',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 244, 144, 3))),
                                TextSpan(
                                    text: '${vidList.length}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 244, 144, 3))),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: vidList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: ListTile(
                                  onTap: () async {
                                    await audioHandler.stop();
                                    audioHandler.queue.value.clear();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const songinfo()));

                                    String theurl = await getlink(
                                        vidList[index]['id'].toString());

                                    audioHandler.addQueueItems([
                                      MediaItem(
                                        id: vidList[index]['id'].toString(),
                                        title:
                                            vidList[index]['title'].toString(),
                                        artist:
                                            vidList[index]['artist'].toString(),
                                        extras: {'url': theurl},
                                        artUri: Uri.parse(
                                            'https://img.youtube.com/vi/${vidList[index]['id'].toString()}/maxresdefault.jpg'),
                                      ),
                                    ]);
                                    await audioHandler.skipToQueueItem(0);

                                    audioHandler.play();

                                    getUpNextVideos(
                                        vidList[index]['id'].toString());
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/dummy.png', // The image that shows while loading
                                      image: vidList[index]
                                          ['thumb'], // The network image URL
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        // This widget will be displayed if the image fails to load
                                        return Image.asset(
                                          'assets/dummy.png', // Your fallback image asset
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    vidList[index]['title'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    vidList[index]['artist'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: GestureDetector(
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
                                                                        checkIfSongExistInsidePlaylist(vidList[index]['id'].toString(),
                                                                                playlist['playlistName'])
                                                                            ? removeSongFromPlaylist(playlist['playlistName'], vidList[index]['id'].toString())
                                                                            : addSongToPlaylist(
                                                                                playlist['playlistName'],
                                                                                {
                                                                                  "id": vidList[index]['id'].toString(),
                                                                                  "title": vidList[index]['title'].toString(),
                                                                                  "artist": vidList[index]['artist'].toString()
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
                                                                              vidList[index]['id'].toString(),
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
                                ),
                              );
                            }),
                      ],
                    )
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
