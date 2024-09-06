import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:musichub/helpers/constants.dart';
import 'package:musichub/helpers/getlink.dart';
import 'package:musichub/main.dart';
import 'package:musichub/notifiers/play_button_notifier.dart';
import 'package:musichub/notifiers/progress_notifier.dart';
import 'package:musichub/notifiers/repeat_button_notifier.dart';
import 'package:musichub/themes/colors.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentMedataMap = ValueNotifier<Map<String, dynamic>>({});
  final MusicStarted = ValueNotifier<bool>(false);
  final currentSongThumbnailNotifier = ValueNotifier<String>('');
  final currentSongArtistNotifier = ValueNotifier<String>('');
  final currentSongIdNotifier = ValueNotifier<String>('');
  final currentSongURLNotifier = ValueNotifier<String>('');
  final currentColorsNotifier = ValueNotifier<List<Color>>([black, black]);
  final playlistNotifier = ValueNotifier<List<Map<String, String?>>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  // final audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    // MusicStarted.addListener(() {
    //   print('MusicStarted changed: ${MusicStarted.value}');
    // });
  }

  void _listenToChangesInPlaylist() {
    audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist
            .map((item) => {
                  'id': item.id,
                  'title': item.title,
                  'artist': item.artist,
                })
            .toList();
        playlistNotifier.value = newList;
        print(newList);
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        audioHandler.seek(Duration.zero);
        audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    audioHandler.mediaItem.listen((mediaItem) async {
      currentColorsNotifier.value =
          await getMainColorsFromImageUrl(mediaItem!.artUri.toString());
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongArtistNotifier.value = mediaItem?.artist ?? '';
      currentSongIdNotifier.value = mediaItem?.id ?? '';
      currentSongThumbnailNotifier.value = mediaItem?.artUri.toString() ?? '';

      // print(
      //     'the current thumbnail is ${await getMainColorsFromImageUrl(mediaItem!.artUri.toString())}');

      // currentColorsNotifier.value =
      //     await getMainColorsFromImageUrl(mediaItem!.artUri.toString());
      // final link = mediaItem?.extras;
      print('im running once');
      RegExp(r'^\d+$').hasMatch(mediaItem.id.toString())
          ? null
          : addToRecentSongs(mediaItem.id.toString(),
              mediaItem.title.toString(), mediaItem.artist.toString());
      _updateSkipButtons();
    });
  }

  addToRecentSongs(
    id,
    title,
    artist,
  ) async {
    print('im running once');
    bool idExists = false;
    for (var item in RecentBox.values) {
      if (item['id'] == id) {
        idExists = true;
        break;
      }
    }
    print('the it ex $idExists');
    // If the ID does not exist, add the new item
    if (!idExists) {
      print('adding $id & $title inside the recentbox');
      await RecentBox.add({
        "id": id,
        "title": title,
        "artist": artist,
        "thumb": 'https://img.youtube.com/vi/$id/maxresdefault.jpg',
        "url": "dummy"
      });
    } else {}

    currentMedataMap.value = {
      "id": id,
      "title": title,
      "artist": artist,
      "thumb": 'https://img.youtube.com/vi/$id/maxresdefault.jpg',
    };
  }

  void _updateSkipButtons() {
    final mediaItem = audioHandler.mediaItem.value;
    final playlist = audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => audioHandler.play();
  void pause() => audioHandler.pause();

  void seek(Duration position) => audioHandler.seek(position);

  void previous() => audioHandler.skipToPrevious();
  void next() => audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  // Future<void> add() async {
  //   final songRepository = getIt<PlaylistRepository>();
  //   final song = await songRepository.fetchAnotherSong();
  //   final mediaItem = MediaItem(
  //     id: song['id'] ?? '',
  //     album: song['album'] ?? '',
  //     title: song['title'] ?? '',
  //     extras: {'url': song['url']},
  //   );
  //   audioHandler.addQueueItem(mediaItem);
  // }

  void remove() {
    final lastIndex = audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    audioHandler.customAction('dispose');
  }

  void stop() {
    audioHandler.stop();
  }
}
