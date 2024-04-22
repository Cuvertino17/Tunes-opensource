import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/themes/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AboutPage(),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black, // Set background color as null
      appBar: AppBar(
        title: const Text(
          'About us',
          // style: TextStyle(color: Colors.pink), // Set app name color
        ),
        centerTitle: true,
        backgroundColor:
            Colors.transparent, // Set app bar background color as null
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your app logo image asset
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'About developer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink, // Set app name color
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hello, I\'m Raj (rA), an Android developer and backend engineer passionate about creating innovative solutions. This app is a testament to my love for technology and music.\n\n'
                'Musichub is a project close to my heart. It allows you to download any music you want from all over the internet for free. Enjoy a seamless experience of exploring and downloading your favorite music with ease.\n\n'
                'Please note: Our application strictly adheres to legal guidelines and operates solely within the framework of Saavn Music official API. We emphasize that our platform does not condone any form of piracy or illegal activity. Rest assured, our mission is to provide users with a seamless and lawful way to access music through authorized channels. Thank you for your understanding and support',
                style: TextStyle(fontSize: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
