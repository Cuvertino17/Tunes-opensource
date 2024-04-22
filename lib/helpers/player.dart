// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();
  final player = AudioPlayer();
  var currentid = '';

  factory Singleton() {
    return _singleton;
  }
//  jammu ka asad thinks its screenshot
  Singleton._internal();

  play(link, id) async {
    currentid = id.toString();
    await player.setAudioSource(AudioSource.uri(Uri.parse(link)));
    await player.play();
  }

  stop() async {
    print('i came here');
    currentid = '';
    player.stop();
  }
}
