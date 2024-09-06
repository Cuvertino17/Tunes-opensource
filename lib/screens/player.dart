import 'package:flutter/material.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/page_manager.dart';

import 'package:musichub/helpers/playerUIHelper.dart';
import 'package:musichub/main.dart';

class songinfo extends StatefulWidget {
  const songinfo({
    super.key,
  });

  @override
  State<songinfo> createState() => _songinfoState();
}

class _songinfoState extends State<songinfo> {
  List<Color> _currentColors = []; // Initial colors

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('playing now'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
          valueListenable: pageManager.currentColorsNotifier,
          builder: (_, colors, __) {
            _currentColors = colors;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 500), // Animation duration
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // colors: [black, black2],
                  colors: _currentColors,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  currentThumbnail(),
                  currentPlayingTitle(),
                  currentplayingsubtitle(),
                  SizedBox(
                    height: 20,
                  ),
                  progressbar(),
                  SizedBox(
                    height: 20,
                  ),
                  buttonControls(),
                  Spacer(),
                ],
              ),
            );
          }),
    );
  }
}
