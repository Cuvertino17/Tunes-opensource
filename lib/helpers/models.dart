class Playlist {
  final String playlistName;
  final String playlistThumbnail;
  final List<String> playlistSongs;

  Playlist({
    required this.playlistName,
    required this.playlistThumbnail,
    required this.playlistSongs,
  });

  Map<String, dynamic> toMap() {
    return {
      'playlistName': playlistName,
      'playlistThumbnail': playlistThumbnail,
      'playlistSongs': playlistSongs,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      playlistName: map['playlistName'],
      playlistThumbnail: map['playlistThumbnail'],
      playlistSongs: List<String>.from(map['playlistSongs']),
    );
  }
}
