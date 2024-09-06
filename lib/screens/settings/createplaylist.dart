import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'dart:io';
// import 'package:fluttertoast/fluttertoast.dart'; // Import for toast

import 'package:musichub/helpers/models.dart';

class CreatePlaylistPage extends StatefulWidget {
  @override
  _CreatePlaylistPageState createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final _formKey = GlobalKey<FormState>();
  final _playlistNameController = TextEditingController();
  File? _playlistImage;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _playlistImage = File(pickedFile.path);
      });
    }
  }

  void _savePlaylist() async {
    if (_formKey.currentState!.validate()) {
      if (_playlistImage == null) {
        // Show a toast message when no image is selected
        // Fluttertoast.showToast(
        //   msg: "Please select a thumbnail image",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        // );
        return;
      }

      final playlistBox = Hive.box('playlists');
      final newPlaylist = Playlist(
        playlistName: _playlistNameController.text,
        playlistThumbnail: _playlistImage!.path, // Ensure image path is saved
        playlistSongs: [], // Start with an empty list of songs
      );

      playlistBox.add(newPlaylist.toMap());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 70),
                  const Text(
                    'Give your playlist a name',
                    style: TextStyle(
                      fontSize: 24, // Increased title size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _playlistNameController,
                    cursorColor: Colors.white, // Set cursor color to white
                    style: const TextStyle(
                        color: Colors.white), // Set text color to white
                    decoration: const InputDecoration(
                      labelText: 'Playlist Name',
                      labelStyle:
                          TextStyle(color: Colors.white70), // Label text color
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white70), // Underline color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.white), // Underline color when focused
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Give your playlist a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: _playlistImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8.0), // Rounded corners for the image
                            child: Image.file(
                              _playlistImage!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners for the container
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 50,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _savePlaylist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
