import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/download.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/main.dart';
import 'package:musichub/notifiers/play_button_notifier.dart';
import 'package:musichub/notifiers/progress_notifier.dart';
import 'package:musichub/notifiers/repeat_button_notifier.dart';
import 'package:musichub/screens/settings/createplaylist.dart';
import 'package:musichub/themes/colors.dart';
import 'package:on_audio_query/on_audio_query.dart';

class currentThumbnail extends StatelessWidget {
  const currentThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    final OnAudioQuery _audioQuery = OnAudioQuery();

    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 40, right: 40),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: ValueListenableBuilder<String>(
            valueListenable: pageManager.currentSongThumbnailNotifier,
            builder: (_, thumbnail, __) {
              return AspectRatio(
                aspectRatio: 1 / 1,
                child: thumbnail.contains('img.youtube.com')
                    // ? ThumbnailWidget(imageUrl: thumbnail)
                    ? FadeInImage.assetNetwork(
                        placeholder: 'assets/dummy.png',
                        image: thumbnail,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/dummy.png');
                        },
                        fadeInDuration: const Duration(milliseconds: 500),
                        fadeOutDuration: const Duration(milliseconds: 500),
                      )
                    : ValueListenableBuilder<String>(
                        valueListenable: pageManager.currentSongIdNotifier,
                        builder: (_, id, __) {
                          int? parsedId;
                          try {
                            parsedId = int.parse(id);
                          } catch (e) {
                            print('Invalid ID: $id');
                          }

                          if (parsedId == null) {
                            return Image.asset('assets/dummy.png');
                          }

                          return QueryArtworkWidget(
                            artworkBorder: BorderRadius.circular(7),
                            controller: _audioQuery,
                            id: parsedId,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 320,
                            artworkWidth: 320,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Image.asset('assets/dummy.png'),
                          );
                        },
                      ),
              );
            },
          )),
    );
  }
}

class currentPlayingTitle extends StatefulWidget {
  const currentPlayingTitle({super.key});

  @override
  State<currentPlayingTitle> createState() => _currentPlayingTitleState();
}

class _currentPlayingTitleState extends State<currentPlayingTitle> {
  void initState() {
    checkliked();
    // checkliked1();
    // print("the song is check liked");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            width: 250,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: ValueListenableBuilder<String>(
                        valueListenable: pageManager.currentSongTitleNotifier,
                        builder: (_, title, __) {
                          return Text(
                            title,
                            style: const TextStyle(fontSize: 16),
                            // overflow: TextOverflow.ellipsis,
                            // maxLines: 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Spacer(),
          ValueListenableBuilder(
              valueListenable: pageManager.currentSongIdNotifier,
              builder: (_, id, __) {
                checkliked();
                return RegExp(r'^\d+$').hasMatch(id.toString())
                    ? const SizedBox(
                        height: 1,
                        width: 1,
                      )
                    : IconButton(
                        onPressed: () {
                          // checkliked1();
                          checkliked() ? null : addToLikedSongs();

                          setState(() {});

                          // print('liked list is $LikedList');
                        },
                        icon: checkliked()
                            ? const Icon(
                                Icons.check_circle_outline_rounded,
                                color: green,
                              )
                            : const Icon(FeatherIcons.plusCircle));
              }),

          GestureDetector(
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
                            margin: const EdgeInsets.only(top: 16, bottom: 40),
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CreatePlaylistPage()));
                              },
                              leading: Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset('assets/add.png'),
                                ),
                              ),
                              title: const Text('Create New Playlist'),
                            ),
                          ),
                          Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: playlistBox.listenable(),
                                  builder: (_, playlists, __) {
                                    if (playlists.values.isEmpty) {
                                      return Container(height: 0.1);
                                    }
                                    return ListView.builder(
                                      itemCount: playlists.values
                                          .length, // Assuming playlistBox contains your playlists
                                      itemBuilder: (context, idx) {
                                        final playlist = playlists.getAt(idx);

                                        return ListTile(
                                          onTap: () {
                                            checkIfSongExistInsidePlaylist(
                                                    pageManager
                                                        .currentSongIdNotifier
                                                        .value,
                                                    playlist['playlistName'])
                                                ? removeSongFromPlaylist(
                                                    playlist['playlistName'],
                                                    pageManager
                                                        .currentSongIdNotifier
                                                        .value,
                                                  )
                                                : addSongToPlaylist(
                                                    playlist['playlistName'],
                                                    {
                                                      "id": pageManager
                                                          .currentSongIdNotifier
                                                          .value,
                                                      "title": pageManager
                                                          .currentSongTitleNotifier
                                                          .value,
                                                      "artist": pageManager
                                                          .currentSongArtistNotifier
                                                          .value
                                                    },
                                                  );
                                          },
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            margin: const EdgeInsets.all(4),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.file(
                                                File(playlist[
                                                    'playlistThumbnail']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            playlist['playlistName'],
                                          ),
                                          trailing:
                                              checkIfSongExistInsidePlaylist(
                                                      pageManager
                                                          .currentSongIdNotifier
                                                          .value,
                                                      playlist['playlistName'])
                                                  ? const Icon(
                                                      Icons
                                                          .check_circle_outline_rounded,
                                                      color: green,
                                                    )
                                                  : const Icon(
                                                      FeatherIcons.plusCircle),
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

          const Spacer()
        ],
      ),
    );
  }
}

class currentplayingsubtitle extends StatelessWidget {
  const currentplayingsubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return SizedBox(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ValueListenableBuilder<String>(
            valueListenable: pageManager.currentSongArtistNotifier,
            builder: (_, artist, __) {
              // currentArtist = artist;
              return Text(
                '- ${artist}',
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(119, 255, 255, 255)),
                overflow: TextOverflow.clip,
                maxLines: 2,
              );
            },
          ),
        ),
      ),
    );
  }
}

class progressbar extends StatelessWidget {
  const progressbar({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ValueListenableBuilder<ProgressBarState>(
        valueListenable: pageManager.progressNotifier,
        builder: (_, value, __) {
          return ProgressBar(
            // timeLabelTextStyle:
            //     TextStyle(color: Colors.white),
            progressBarColor: Colors.white,
            thumbColor: Colors.white,
            barHeight: 2,
            thumbRadius: 5,
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: pageManager.seek,
          );
        },
      ),
    );
  }
}

class buttonControls extends StatefulWidget {
  const buttonControls({super.key});

  @override
  State<buttonControls> createState() => _buttonControlsState();
}

class _buttonControlsState extends State<buttonControls> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  double downloadProgress = 0.0;
  bool isdownloading = false;
  void startDownload() async {
    final pageManager = getIt<PageManager>();

    AudioDownloader downloader = AudioDownloader();
    // myContr2.interstitial ad.showInterstitialAd();

    await downloader.downloadVideo(
        pageManager.currentSongTitleNotifier.value,
        pageManager.currentSongIdNotifier.value,
        pageManager.currentSongArtistNotifier.value, (progress, totalsize) {
      downloadProgress = 0.0;
      setState(() {
        downloadProgress = ((progress / totalsize) * 100) / 100;
        // print(progress);
        // print(totalsize);
        print((progress / totalsize) * 100);
        if (progress == totalsize) {
          // data.clear();
          setState(() {
            isdownloading = false;

            downloadProgress = 0.0;
          });
          // myContr2.loadAd();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return Row(
      // this is row 1
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            ValueListenableBuilder<RepeatState>(
              valueListenable: pageManager.repeatButtonNotifier,
              builder: (context, value, child) {
                Icon icon;
                switch (value) {
                  case RepeatState.off:
                    icon = const Icon(
                      Icons.repeat_rounded,
                      size: 30,
                      color: Colors.white,
                    );
                    break;
                  case RepeatState.repeatSong:
                    icon = const Icon(
                      Icons.repeat_one_rounded,
                      color: green,
                      size: 30,
                    );
                    break;
                  case RepeatState.repeatPlaylist:
                    icon = const Icon(
                      Icons.repeat_rounded,
                      color: green,
                      size: 30,
                    );
                    break;
                }
                return IconButton(
                  icon: icon,
                  onPressed: pageManager.repeat,
                );
              },
            ),
            Column(
              children: [
                isdownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  value: downloadProgress,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${(downloadProgress * 100).toInt()}%',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ],
                      )
                    : IconButton(
                        color: Colors.white,
                        iconSize: 28,
                        onPressed: () async {
                          // ad.showInterstitialAd();
                          if (RegExp(r'^\d+$').hasMatch(
                              pageManager.currentSongIdNotifier.value)) {
                            // Fluttertoast.showToast(
                            //   msg: "this cant be downloaded",
                            //   toastLength: Toast.LENGTH_SHORT,
                            //   gravity: ToastGravity.BOTTOM,
                            //   backgroundColor: Colors.green,
                            //   textColor: Colors.white,
                            //   fontSize: 16.0,
                            // );
                          } else {
                            setState(() {
                              isdownloading = true;
                            });

                            startDownload();
                          }
                        },
                        icon: const Icon(
                            color: Colors.white, FeatherIcons.arrowDownCircle)),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 9,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      'watch ads',
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
        const SizedBox(
          width: 30,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: pageManager.isFirstSongNotifier,
          builder: (_, isFirst, __) {
            return IconButton(
              icon: const Icon(
                Icons.skip_previous_rounded,
                size: 35,
                color: Colors.white,
              ),
              onPressed: (isFirst) ? null : pageManager.previous,
            );
          },
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white,
          child: ValueListenableBuilder<ButtonState>(
            valueListenable: pageManager.playButtonNotifier,
            builder: (_, value, __) {
              switch (value) {
                case ButtonState.loading:
                  return const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: black,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                  );
                case ButtonState.paused:
                  return CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: GestureDetector(
                        onTap: pageManager.play,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: black,
                          size: 30,
                        )),
                  );

                case ButtonState.playing:
                  return CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: GestureDetector(
                        onTap: pageManager.pause,
                        child: const Icon(
                          Icons.pause_rounded,
                          color: black,
                          size: 30,
                        )),
                  );
              }
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: pageManager.isLastSongNotifier,
          builder: (_, isLast, __) {
            return IconButton(
              icon: const Icon(
                Icons.skip_next_rounded,
                size: 35,
                color: Colors.white,
              ),
              onPressed: (isLast) ? null : pageManager.next,
            );
          },
        ),
        const SizedBox(
          width: 30,
        ),
        Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: pageManager.isShuffleModeEnabledNotifier,
              builder: (context, isEnabled, child) {
                return IconButton(
                  icon: (isEnabled)
                      ? const Icon(
                          Icons.shuffle_rounded,
                          color: green,
                          size: 30,
                        )
                      : const Icon(
                          Icons.shuffle_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                  onPressed: pageManager.shuffle,
                );
              },
            ),
            IconButton(
                color: Colors.white,
                iconSize: 32,
                onPressed: () {
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
                              margin: const EdgeInsets.only(top: 16),
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder<
                                  List<Map<String, String?>>>(
                                valueListenable: pageManager.playlistNotifier,
                                builder: (_, list, __) {
                                  return ListView.builder(
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () async {
                                          await audioHandler
                                              .skipToQueueItem(index);
                                        },
                                        leading: RegExp(r'^\d+$').hasMatch(
                                                list[index]['id'].toString())
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: QueryArtworkWidget(
                                                  artworkBorder:
                                                      BorderRadius.circular(7),
                                                  controller: _audioQuery,
                                                  id: int.parse(list[index]
                                                          ["id"]
                                                      .toString()),
                                                  type: ArtworkType.AUDIO,
                                                  artworkHeight: 50,
                                                  artworkWidth: 50,
                                                  artworkFit: BoxFit.cover,
                                                  nullArtworkWidget:
                                                      Image.asset(
                                                          'assets/dummy.png'),
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      'assets/dummy.png',
                                                  image:
                                                      'https://img.youtube.com/vi/${list[index]['id'].toString()}/maxresdefault.jpg',
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                        title: Text(
                                          list[index]['title'].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: pageManager
                                                        .currentSongTitleNotifier
                                                        .value ==
                                                    list[index]['title']
                                                        .toString()
                                                ? green
                                                : Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          list[index]['artist'].toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.queue_music_rounded)),
          ],
        ),
      ],
    );
  }
}
