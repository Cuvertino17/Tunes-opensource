import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:musichub/helpers/admanager.dart';
import 'package:musichub/helpers/download.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/helpers/player.dart';

class songinfo extends StatefulWidget {
  const songinfo(
      {super.key,
      required this.Title,
      required this.id,
      required this.author,
      required this.thumb});
  final String Title;
  final String id;
  final String author;
  final String thumb;

  @override
  State<songinfo> createState() => _songinfoState();
}

class _songinfoState extends State<songinfo> {
  double downloadProgress = 0.0;
  bool isdownloading = false;
  final admanager ad = admanager();

  bool isSongLoading = false;
  bool isloading = false;

  bool _isplaying = false;

  void startDownload(videoUrl, title, author) async {
    VideoDownloader downloader = VideoDownloader();
    // myContr2.interstitialAd!.show();
    ad.showInterstitialAd();
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

            downloadProgress = 0.0;
          });
          // myContr2.loadAd();
        }
      });
    });
    ad.createInterstitialAd();
  }

  @override
  void initState() {
    super.initState();
    ad.createInterstitialAd();

    ad.showInterstitialAd();
    ad.createInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('info'),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: () {}, icon: Icon(Icons.bookmark_outline_rounded))
        // ],
      ),
      body: Center(
        child: Container(
          // color: Colors.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 60, bottom: 20, left: 40, right: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/dummy2.png',
                      image:
                          'https://img.youtube.com/vi/${widget.id}/sddefault.jpg',
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.7,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.Title,
                              style: TextStyle(fontSize: 20),
                              // overflow: TextOverflow.ellipsis,
                              // maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      '- ${widget.author}',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(119, 255, 255, 255)),
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(FeatherIcons.repeat),
                  //   iconSize: 27,
                  // ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(FeatherIcons.skipBack),
                  //   iconSize: 25,
                  // ),
                  isSongLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 241, 100, 12),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        )
                      : widget.id == Singleton().currentid
                          ? IconButton(
                              color: (const Color.fromARGB(249, 250, 117, 8)),
                              iconSize: 35,
                              onPressed: () async {
                                Singleton().stop();
                                // player.stop;

                                setState(() {
                                  _isplaying = false;
                                });

                                // print(link);
                              },
                              icon: const Icon(FeatherIcons.pauseCircle))
                          : IconButton(
                              iconSize: 35,
                              onPressed: () async {
                                isSongLoading = true;
                                setState(() {});
                                print(isSongLoading);
                                String link = await getlink(widget.id);
                                // await getlink(
                                //     vidList[index]
                                //         ['id']);
                                Singleton().play(link, widget.id);

                                setState(() {
                                  isSongLoading = false;
                                  _isplaying = true;
                                });
                              },
                              icon: const Icon(FeatherIcons.playCircle)),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(FeatherIcons.skipForward),
                  //   iconSize: 25,
                  // ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  isdownloading
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    value: downloadProgress,
                                    color:
                                        const Color.fromARGB(255, 241, 100, 12),
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${(downloadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ],
                        )
                      : IconButton(
                          iconSize: 35,
                          onPressed: () async {
                            setState(() {
                              isdownloading = true;
                            });

                            startDownload(
                                widget.id, widget.Title, widget.author);
                          },
                          icon: const Icon(FeatherIcons.arrowDownCircle)),
                ],
              ),
              SizedBox(
                height: 70,
              ),
              IconButton(
                onPressed: () async {
                  launchInstagram();
                },
                icon: Icon(FeatherIcons.instagram),
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
            ],
          ),
        ),
      ),
    );
  }
}
