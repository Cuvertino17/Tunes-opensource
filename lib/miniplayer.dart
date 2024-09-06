import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/page_manager.dart';
import 'package:musichub/main.dart';
import 'package:musichub/notifiers/play_button_notifier.dart';
import 'package:musichub/screens/player.dart';
import 'package:musichub/themes/colors.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const songinfo()));
        },
        child: ValueListenableBuilder(
            valueListenable: pageManager.currentColorsNotifier,
            builder: (_, colors, __) {
              return ValueListenableBuilder<List<Map<String, String?>>>(
                valueListenable: pageManager.playlistNotifier,
                builder: (_, playlist, __) {
                  if (playlist.isEmpty) {
                    return Container(
                      // color: black5,
                      height: 0,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                          // gradient: LinearGradient(colors: colors),
                          color: Color.lerp(colors[0], Colors.black, 0.3),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      // color: black2,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ListTile(
                          leading: ValueListenableBuilder<String>(
                            valueListenable:
                                pageManager.currentSongThumbnailNotifier,
                            builder: (_, thumbnail, __) {
                              return AspectRatio(
                                aspectRatio: 1 / 1,
                                child: thumbnail.contains('img.youtube.com')
                                    // ? ThumbnailWidget(imageUrl: thumbnail)
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/dummy.png',
                                        image: thumbnail,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                              'assets/dummy.png');
                                        },
                                        fadeInDuration:
                                            const Duration(milliseconds: 500),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 500),
                                      )
                                    : ValueListenableBuilder<String>(
                                        valueListenable:
                                            pageManager.currentSongIdNotifier,
                                        builder: (_, id, __) {
                                          int? parsedId;
                                          try {
                                            parsedId = int.parse(id);
                                          } catch (e) {}

                                          if (parsedId == null) {
                                            return Image.asset(
                                                'assets/dummy.png');
                                          }

                                          return QueryArtworkWidget(
                                            artworkBorder:
                                                BorderRadius.circular(7),
                                            controller: _audioQuery,
                                            id: parsedId,
                                            type: ArtworkType.AUDIO,
                                            artworkHeight: 50,
                                            artworkWidth: 50,
                                            artworkFit: BoxFit.cover,
                                            nullArtworkWidget:
                                                Image.asset('assets/dummy.png'),
                                          );
                                        },
                                      ),
                              );
                            },
                          ),
                          title: ValueListenableBuilder<String>(
                            valueListenable:
                                pageManager.currentSongTitleNotifier,
                            builder: (_, title, __) {
                              return Text(
                                title,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              );
                            },
                          ),
                          subtitle: ValueListenableBuilder<String>(
                            valueListenable:
                                pageManager.currentSongArtistNotifier,
                            builder: (_, artist, __) {
                              return Text(
                                '- ${artist}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(119, 255, 255, 255)),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              );
                            },
                          ),
                          trailing: ValueListenableBuilder<ButtonState>(
                            valueListenable: pageManager.playButtonNotifier,
                            builder: (_, value, __) {
                              switch (value) {
                                case ButtonState.loading:
                                  return const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  );
                                case ButtonState.paused:
                                  return GestureDetector(
                                      onTap: pageManager.play,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ));

                                case ButtonState.playing:
                                  return GestureDetector(
                                      onTap: pageManager.pause,
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ));
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  }

                  // if (title == '') {
                  //   return Container(
                  //     child: const CircularProgressIndicator(),
                  //   );
                  // } else {
                  //   print('im here bro');
                  //   return Container(
                  //     color: black3,
                  //     height: 70,
                  //     width: MediaQuery.of(context).size.width,
                  //     alignment: Alignment.topCenter,
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: ListTile(
                  //             leading: ClipRRect(
                  //               borderRadius: BorderRadius.circular(1),
                  //               child: FadeInImage.assetNetwork(
                  //                 placeholder: 'assets/dummy.png',
                  //                 image:
                  //                     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwv7_tRaEXV7TEYJQTWytjC1nmltJV0fbYfw&s",
                  //                 height: 50,
                  //                 width: 50,
                  //                 fit: BoxFit.cover,
                  //               ),
                  //             ),
                  //             title: const Padding(
                  //               padding: EdgeInsets.only(bottom: 8.0),
                  //               child: Text(
                  //                 "Test Title",
                  //                 overflow: TextOverflow.ellipsis,
                  //                 maxLines: 1,
                  //                 style: TextStyle(
                  //                   color: Color(0xff1DB954),
                  //                 ),
                  //               ),
                  //             ),
                  //             subtitle: const Text(
                  //               "artist name",
                  //               overflow: TextOverflow.ellipsis,
                  //               maxLines: 1,
                  //             ),
                  //             trailing: IconButton(
                  //               onPressed: () {},
                  //               icon: const Icon(FeatherIcons.play),
                  //             ),
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   );
                  // }
                },
              );
            }));
  }
}
