import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musichub/helpers/admanager.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/download.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/player.dart';
import 'package:musichub/helpers/searchHelp.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musichub/screens/about.dart';
import 'package:musichub/screens/downloaded.dart';
import 'package:musichub/screens/liked.dart';
import 'package:musichub/screens/settings.dart';
import 'package:musichub/screens/songInfo.dart';
import 'package:musichub/themes/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final admanager ad = admanager();
  List idList = [];
  List vidList = [];
  double downloadProgress = 0.0;
  bool isdownloading = false;

  final List<String> _hintTexts = [
    '"Search music"',
    '"Download unlimited"',
    '"For free"'
  ];
  bool isSongLoading = false;
  bool isloading = false;
  int _currentHintIndex = 0;
  int _currentSongIndex = -1;
  int _currentDownloadIndex = -1;

  // final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startHintTextAnimation();

    _requestPermissionsAndExecuteLogic();
    ad.createInterstitialAd();

    ad.showInterstitialAd();
    ad.createInterstitialAd();
    fetchliked();

    // ad.showInterstitialAd();

    // openHiveBox();
  }

  // openHiveBox() async {
  //   await Hive.openBox('history').then((value) => print('box opened'));
  // }
  fetchliked() {
    idList.clear();
    // print('im inside');
    // Iterate through all maps in the LikedBox and extract IDs
    // try
    // print(' the box values are ${likedBox.values}');
    try {
      for (var map in likedBox.values) {
        print(map['id']);
        // if (map.containsKey('id')) {
        //   print(map['id']);

        idList.add('${map['id']}');
        // }
      }
      print('ids here $idList');
    } catch (e) {
      print('error is $e');
    }
  }

  Future<void> removeMapById(String idToRemove) async {
    // Fetch the LikedBox
    // Box likedBox = Hive.box('LikedBox');
    print('logging from removemap');
    try {
      // for (var map in likedBox.values) {
      //   print(map['id']);
      //   // if (map.containsKey('id')) {
      //   //   print(map['id']);
      //   if (map['id'] == idToRemove) {
      //     likedBox.delete(map.key);
      //   }

      //   idList.add('${map['id']}');
      //   // }
      // }
      for (var i = 0; i < likedBox.length; i++) {
        var map = likedBox.getAt(i);
        if (map is Map && map.containsKey('id') && map['id'] == idToRemove) {
          likedBox.deleteAt(i);
          print('Map with id $idToRemove removed from LikedBox');
          // Since we have deleted a map, decrement i to check the next map
          i--;
        }
      }
      print('ids here $idList');
    } catch (e) {
      print('error is $e');
    }
    // Find and remove the map with the specified id
    // likedBox.values.forEach((map) {
    //   if (map is Map && map.containsKey('id') && map['id'] == idToRemove) {
    //     likedBox.delete(map);
    //     print('Map with id $idToRemove removed from LikedBox');
    //     setState(() {
    //       // fetchliked();
    //     });
    //   }
    // });
  }

  Future<void> _requestPermissionsAndExecuteLogic() async {
    print('requesting permission');
    // Request notification permission
    var notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }

    // Request storage permission (assuming WRITE_EXTERNAL_STORAGE)
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isDenied) {
      await Permission.storage.request();
    }

    // Check if both permissions are granted
    if (await Permission.notification.isGranted &&
        await Permission.storage.isGranted) {
      // Execute your logic here
      // print('im here');

      print('Notification and storage permissions granted');
    } else {
      var statuses = await [
        Permission.storage,
        Permission.notification,
      ].request();
      // Handle if either permission is not granted
      print('Notification or storage permission not granted');
    }
  }

  void startDownload(videoUrl, title, author) async {
    VideoDownloader downloader = VideoDownloader();
    // myContr2.interstitialAd!.show();

    await downloader.downloadVideo(title, videoUrl, author,
        (progress, totalsize) {
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
            _currentSongIndex = -1;
            downloadProgress = 0.0;
          });
          // myContr2.loadAd();
        }
      });
    });
  }

  Widget buildTextContainer(String Txt) {
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 180,
        ),
        // height: 35,
        // width: 150, // Set a finite width for the container
        decoration: BoxDecoration(
          color: const Color.fromARGB(34, 255, 255, 255),
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _textEditingController.text = Txt;
              });
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
      appBar: AppBar(
        titleSpacing: 4.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Image(
            image: AssetImage('assets/logo.png'),
            height: 90,
            width: 90,
            fit: BoxFit.fill,
          ),
        ),
        // actions: [IconButton(onPressed: (){}, icon: icon)],
        // title: RichText(
        //     text: const TextSpan(
        //   style: TextStyle(fontSize: 19),
        //   children: <TextSpan>[
        //     TextSpan(text: 'Music'),
        //     TextSpan(text: ' Hub', style: TextStyle(color: Colors.amber)),
        //   ],
        // )),
        actions: [
          IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
              icon: const Icon(Icons.align_horizontal_right_rounded))
        ],
      ),
      endDrawer: Drawer(
        surfaceTintColor: Colors.blue,
        backgroundColor: black,
        child: ListView(
          children: [
            // ListTile(
            //   onTap: () {},
            //   // splashColor: Colors.pink,
            //   leading: Icon(
            //     FeatherIcons.bookmark,
            //   ),
            //   title: Text('Saved Music'),
            // ),
            // ListTile(
            //   onTap: () {
            //     // print(likedBox.values);
            //     // likedBox.clear();
            //     // fetchliked();
            //     Navigator.of(context)
            //         .push(MaterialPageRoute(builder: (context) => liked()));
            //   },

            //   // splashColor: Colors.pink,
            //   leading: const Icon(
            //     FeatherIcons.heart,
            //   ),
            //   title: const Text('Liked Tracks'),
            // ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const already()));
                // print(alreadyBox.values);
              },
              // splashColor: Colors.pink,
              leading: const Icon(
                FeatherIcons.download,
              ),
              title: const Text('Downloaded'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const settings()));
              },
              // splashColor: Colors.pink,
              leading: const Icon(
                FeatherIcons.settings,
              ),
              title: const Text('Download Settings'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AboutPage()));
              },
              // splashColor: Colors.pink,
              leading: const Icon(
                FeatherIcons.user,
              ),
              title: const Text('About'),
            ),
            const SizedBox(
              height: 100,
            ),
            IconButton(
              onPressed: () async {
                launchInstagram();
              },
              icon: const Icon(FeatherIcons.instagram),
              color: Colors.pink,
            ),
            Center(
              child: RichText(
                  text: const TextSpan(
                style: TextStyle(fontSize: 15, fontFamily: 'circular'),
                children: <TextSpan>[
                  TextSpan(text: 'by'),
                  TextSpan(text: ' rA', style: TextStyle(color: Colors.pink)),
                ],
              )),
            ),
            // Center(child: Text('by rA'))
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color
              borderRadius: BorderRadius.circular(7.0), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 101, 100, 100),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) async {
                        setState(() {
                          isloading = true;
                          _currentSongIndex = -1;
                        });
                        history.add(value);

                        try {
                          vidList.clear();
                          ad.showInterstitialAd();

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
                        ad.createInterstitialAd();
                      },
                      style: const TextStyle(
                          color: Color.fromARGB(255, 24, 23, 23)),
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          hintText: _hintTexts[_currentHintIndex],
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 83, 83, 83)),
                          suffixIcon: SizedBox(
                            width: 97,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // IconButton(
                                //   iconSize: 20,
                                //   icon: const Icon(
                                //     Icons.clear_rounded,
                                //     color: black2,
                                //   ),
                                //   onPressed: () {
                                //     setState(() {
                                //       _textEditingController.clear();
                                //       // Additional logic if needed
                                //     });
                                //   },
                                // ),
                                _textEditingController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _textEditingController.clear();
                                        },
                                        child: Icon(
                                          Icons.clear_rounded,
                                          color: black,
                                          size: 19,
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    // var yt = YoutubeExplode();

                                    // var manifest =
                                    //     await yt.videos.get('7iNjZMf-Pq4');
                                    // print(manifest);
                                    setState(() {
                                      isloading = true;
                                      _currentSongIndex = -1;
                                    });
                                    history.add(_textEditingController.text);

                                    try {
                                      vidList.clear();
                                      ad.showInterstitialAd();

                                      var lis = await searchSongs(
                                          _textEditingController.text);

                                      vidList.addAll(lis);
                                      setState(() {
                                        isloading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isloading = false;
                                      });
                                    }
                                    ad.createInterstitialAd();
                                  },
                                  child: Icon(
                                    FeatherIcons.arrowUpCircle,
                                    color: black,
                                  ),
                                ),

                                // IconButton(
                                //   iconSize: 20,
                                //   icon: const Icon(
                                //     FeatherIcons.arrowUpCircle,
                                //     color: black2,
                                //   ),
                                //   onPressed: () {
                                //     setState(() {
                                //       _textEditingController.clear();
                                //       // Additional logic if needed
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          )
                          // : null,
                          ),
                    ),
                  ),
                ],
              ),
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
                        color: Colors.white,
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
                            const SizedBox(
                              height: 50,
                            ),
                            Container(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Search'),
                                    TextSpan(
                                        text: ' Your Music :)',
                                        style: TextStyle(
                                            color: Color(0xff1DB954))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
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
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: vidList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => songinfo(
                                                  Title: vidList[index]['title']
                                                      .toString(),
                                                  id: vidList[index]['id']
                                                      .toString(),
                                                  author: vidList[index]
                                                          ['artist']
                                                      .toString(),
                                                  thumb: vidList[index]['thumb']
                                                      .toString(),
                                                )));
                                  },
                                  // splashColor: Colors.pink,
                                  // shape: RoundedRectangleBorder(
                                  //   side: const BorderSide(
                                  //       color: Color.fromARGB(255, 68, 68, 68), width: 1),
                                  //   borderRadius: BorderRadius.circular(5),
                                  // ),

                                  // titleAlignment: ListTileTitleAlignment.bottom,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/dummy.png',
                                      image: vidList[index]['thumb'],
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    vidList[index]['title'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color:
                                            vidList[index]['id'].toString() ==
                                                    Singleton().currentid
                                                ? Color(0xff1DB954)
                                                : null),
                                  ),
                                  subtitle: Text(
                                    vidList[index]['artist'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color:
                                            vidList[index]['id'].toString() ==
                                                    Singleton().currentid
                                                ? Color(0xff1DB954)
                                                : null),
                                    // style: const TextStyle(fontSize: 14)
                                  ),
                                  trailing: SizedBox(
                                      width: 100,
                                      child: Row(
                                        children: [
                                          isdownloading &&
                                                  _currentDownloadIndex == index
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Center(
                                                        child: SizedBox(
                                                          height: 25,
                                                          width: 25,
                                                          child:
                                                              CircularProgressIndicator(
                                                            value:
                                                                downloadProgress,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                -241, 100, 12),
                                                            strokeWidth: 3,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(downloadProgress * 100).toInt()}%',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                )
                                              : IconButton(
                                                  iconSize: 26,
                                                  onPressed: () async {
                                                    ad.showInterstitialAd();

                                                    setState(() {
                                                      _currentDownloadIndex =
                                                          index;
                                                      isdownloading = true;
                                                    });

                                                    // var link =
                                                    //     'https://rr4---sn-cvh76nl6.googlevideo.com/videoplayback?expire=1704564799&ei=30OZZdrXH9KPjuMPzqKy4AY&ip=2405%3A201%3A3002%3A80a3%3Ad31%3Ade3e%3Adb00%3Ad8fd&id=o-AI1GQYklJMPKMRqYqli6w84U-c812xFxl7dFHz90FhF5&itag=140&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&spc=UWF9f7d-Zd32k6HpiUQF7D__dRliV8sMDDJaJwVQnQ&vprv=1&svpuc=1&mime=audio%2Fmp4&ns=QufHMlfjedukgW7t5xoBkA8Q&gir=yes&clen=2514368&dur=155.318&lmt=1688526862474117&keepalive=yes&fexp=24007246&c=WEB&txp=5318224&n=ud--8NXoVvf5kQ&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cns%2Cgir%2Cclen%2Cdur%2Clmt&sig=AJfQdSswRAIga9JW182HYmgKyvGPm5tXqswidhPznmCGBn95E90eKDACICL7hQ5-mmnATBjh3Otb1InmRdifZZAAEZx_xcMC0bAj&cm2rm=sn-gwpa-cives7s,sn-gwpa-pmhd7e&req_id=860166e61485a3ee&redirect_counter=2&cms_redirect=yes&cmsv=e&ipbypass=yes&mh=fl&mm=30&mn=sn-cvh76nl6&ms=nxu&mt=1704542906&mv=m&mvi=4&pl=49&lsparams=ipbypass,mh,mm,mn,ms,mv,mvi,pl&lsig=AAO5W4owRQIgQOHrt_J4mvYnRwd-AYpYcE3VnviVQcAENaKJ6dgZap8CIQCAinZHTJbBusJ2f_1yGez4069PhpUU7S6DcxW97wF5wg%3D%3D';
                                                    // getlink(
                                                    //     vidList[index]['id']);
                                                    startDownload(
                                                        vidList[index]['id']
                                                            .toString(),
                                                        vidList[index]['title']
                                                            .toString(),
                                                        vidList[index]['artist']
                                                            .toString());
                                                    print(isdownloading);
                                                    ad.createInterstitialAd();
                                                    // setState(() {
                                                    //           isSongLoading = false;

                                                    //         });
                                                  },
                                                  icon: const Icon(FeatherIcons
                                                      .arrowDownCircle)),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          // IconButton(
                                          //     iconSize: 26,
                                          //     onPressed: () async {
                                          //       // idList.contains(vidList[index]
                                          //       //             ['id']
                                          //       //         .toString())
                                          //       //     ? print('true')
                                          //       //     : print('false');
                                          //       idList.contains(vidList[index]
                                          //                   ['id']
                                          //               .toString())
                                          //           ? removeMapById(
                                          //               vidList[index]['id']
                                          //                   .toString())
                                          //           : await likedBox.add({
                                          //               'id': vidList[index]
                                          //                       ['id']
                                          //                   .toString(),
                                          //               'title': vidList[index]
                                          //                       ['title']
                                          //                   .toString(),
                                          //               'thumb':
                                          //                   'https://img.youtube.com/vi/${vidList[index]['id'].toString()}/mqdefault.jpg',
                                          //               'artist': vidList[index]
                                          //                       ['artist']
                                          //                   .toString(),
                                          //             });
                                          //       // removeMapById(vidList[index]
                                          //       //         ['id']
                                          //       //     .toString());
                                          //       // likedBox.clear();
                                          //       setState(() {
                                          //         fetchliked();
                                          //       });
                                          //     },
                                          //     icon: idList.contains(
                                          //             vidList[index]['id']
                                          //                 .toString())
                                          //         ? Icon(
                                          //             CupertinoIcons
                                          //                 .suit_heart_fill,
                                          //             color: Color(0xff1DB954))
                                          //         : Icon(CupertinoIcons
                                          //             .suit_heart))
                                          // audio playing service inside home is here you can uncomment but here we are testing liked songs so we commented
                                          vidList[index]['id'].toString() ==
                                                  Singleton().currentid
                                              ? isSongLoading == true
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Center(
                                                        child: SizedBox(
                                                          height: 25,
                                                          width: 25,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    241,
                                                                    100,
                                                                    12),
                                                            strokeWidth: 3,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : IconButton(
                                                      color:
                                                          (const Color.fromARGB(
                                                              249,
                                                              250,
                                                              117,
                                                              8)),
                                                      iconSize: 26,
                                                      onPressed: () async {
                                                        Singleton().stop();
                                                        // player.stop;

                                                        setState(() {
                                                          _currentSongIndex =
                                                              -1;
                                                        });

                                                        // print(link);
                                                      },
                                                      icon: const Icon(
                                                          FeatherIcons
                                                              .pauseCircle))
                                              : IconButton(
                                                  iconSize: 26,
                                                  onPressed: () async {
                                                    Singleton().currentid = '';
                                                    setState(() {
                                                      Singleton().currentid =
                                                          vidList[index]['id']
                                                              .toString();
                                                      _currentSongIndex = index;
                                                      isSongLoading = true;
                                                    });
                                                    print(index);

                                                    String link = await getlink(
                                                        vidList[index]['id']);
                                                    // await getlink(
                                                    //     vidList[index]
                                                    //         ['id']);
                                                    Singleton().play(link,
                                                        vidList[index]['id']);

                                                    setState(() {
                                                      isSongLoading = false;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      FeatherIcons.playCircle)),
                                        ],
                                      )),
                                ),
                              );
                            }),
                      ],
                    )
        ],
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  void _startHintTextAnimation() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _hintTexts.length;
        });
        _startHintTextAnimation();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

// Widget buildTextContainer(String text) {
//   return IntrinsicWidth(
//     child: Container(
//       constraints: BoxConstraints(
//         maxWidth: 180,
//       ),
//       // height: 35,
//       // width: 150, // Set a finite width for the container
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(34, 255, 255, 255),
//         borderRadius: BorderRadius.circular(100),
//       ),
//       padding: EdgeInsets.all(8),
//       child: Center(
//         child: GestureDetector(
//           onTap: () {

//           },
//           child: Row(
//             // crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Flexible(
//                 child: Container(
//                   // color: Colors.amber,
//                   child: Text(
//                     text,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//               GestureDetector(
//                 onTap: () {

//                 },
//                 child: Icon(
//                   Icons.close,
//                   size: 18,
//                 ),
//               ),

//               // Handle the cross icon press if needed
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
