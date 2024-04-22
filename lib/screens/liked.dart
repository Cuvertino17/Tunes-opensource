import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/themes/colors.dart';

class liked extends StatefulWidget {
  const liked({super.key});

  @override
  State<liked> createState() => _likedState();
}

class _likedState extends State<liked> {
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
      setState(() {});
      // print('ids here $idList');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('favourites'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
          valueListenable: likedBox.listenable(),
          builder: (context, value, child) {
            var Rvdvalues = value.values.toList().reversed.toList();
            if (value.isEmpty) {
              return emptyscreen('no added tracks', ':)');
            }
            return ListView.builder(
                itemCount: Rvdvalues.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: ListTile(
                      onTap: () {},
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/music.png',
                          image: Rvdvalues[index]['thumb'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        Rvdvalues[index]['title'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 17),
                      ),
                      subtitle: Text(Rvdvalues[index]['artist'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                          iconSize: 26,
                          onPressed: () async {
                            setState(() {
                              // print(Rvdvalues[index]['id']);
                              removeMapById(Rvdvalues[index]['id']);
                            });

                            // await getlink(
                            //     vidList[index]
                            //         ['id']);
                          },
                          icon: const Icon(
                            CupertinoIcons.suit_heart_fill,
                            color: Colors.green,
                          )),
                    ),
                  );
                });
          }),
    );
  }
}
