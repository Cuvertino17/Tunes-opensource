import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/themes/colors.dart';
import 'package:on_audio_query/on_audio_query.dart';

class already extends StatefulWidget {
  const already({super.key});

  @override
  State<already> createState() => _alreadyState();
}

class _alreadyState extends State<already> {
  // Main method.
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Indicate if application has permission to the library.
  bool _hasPermission = false;
  @override
  void initState() {
    checkAndRequestPermissions();
    super.initState();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    // The param 'retryRequest' is false, by default.
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // Only call update the UI if application has all required permissions.
    _hasPermission ? setState(() {}) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('downloaded'),
        centerTitle: true,
      ),
      body: Center(
        child: !_hasPermission
            ? noAccessToLibraryWidget()
            : FutureBuilder<List<SongModel>>(
                // Default values:
                future: _audioQuery.querySongs(
                  sortType: SongSortType.DATE_ADDED,
                  orderType: OrderType.DESC_OR_GREATER,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, item) {
                  // Display error, if any.
                  if (item.hasError) {
                    return Text(item.error.toString());
                  }

                  // Waiting content.
                  if (item.data == null) {
                    return const CircularProgressIndicator();
                  }

                  // 'Library' is empty.
                  if (item.data!.isEmpty) return const Text("Nothing found!");

                  // You can use [item.data!] direct or you can create a:
                  // List<SongModel> songs = item.data!;
                  return ListView.builder(
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(item.data![index].title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 17)),
                        subtitle: Text(item.data![index].artist ?? "No Artist",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14)),
                        trailing: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green,
                        ),
                        // This Widget will query/load image.
                        // You can use/create your own widget/method using [queryArtwork].
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: QueryArtworkWidget(
                            artworkBorder: BorderRadius.circular(7),
                            controller: _audioQuery,
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Image.asset('assets/dummy2.png'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      // body: ValueListenableBuilder(
      //     valueListenable: alreadyBox.listenable(),
      //     builder: (context, value, child) {
      //       var Rvdvalues = value.values.toList().reversed.toList();
      //       if (value.isEmpty) {
      //         return emptyscreen('no downloaded tracks', ':)');
      //       }
      //       return ListView.builder(
      //           itemCount: Rvdvalues.length,
      //           itemBuilder: (context, index) {
      //             return Padding(
      //               padding: const EdgeInsets.symmetric(
      //                   horizontal: 10, vertical: 10),
      //               child: ListTile(
      //                 onTap: () {},
      //                 leading: ClipRRect(
      //                   borderRadius: BorderRadius.circular(7),
      //                   child: FadeInImage.assetNetwork(
      //                     placeholder: 'assets/music.png',
      //                     image: Rvdvalues[index]['thumb'],
      //                     height: 50,
      //                     width: 50,
      //                     fit: BoxFit.cover,
      //                   ),
      //                 ),
      //                 title: Text(
      //                   Rvdvalues[index]['title'],
      //                   overflow: TextOverflow.ellipsis,
      //                   maxLines: 1,
      //                   style: const TextStyle(fontSize: 17),
      //                 ),
      //                 subtitle: Text(Rvdvalues[index]['artist'],
      //                     overflow: TextOverflow.ellipsis,
      //                     maxLines: 1,
      //                     style: const TextStyle(fontSize: 14)),
      //                 trailing: IconButton(
      //                     iconSize: 26,
      //                     onPressed: () async {
      //                       setState(() {});

      //                       // await getlink(
      //                       //     vidList[index]
      //                       //         ['id']);
      //                     },
      //                     icon: const Icon(
      //                       Icons.check_circle_outline_rounded,
      //                       color: Colors.green,
      //                     )),
      //               ),
      //             );
      //           });
      //     }),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => checkAndRequestPermissions(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
// }
}
