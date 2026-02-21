import 'album.dart';
import 'media.dart';

class AlbumDetailModel {
  final AlbumModel album;
  final List<MediaModel> media;

  AlbumDetailModel({
    required this.album,
    required this.media,
  });

  factory AlbumDetailModel.fromJson(Map<String, dynamic> json) {
    return AlbumDetailModel(
      album: AlbumModel.fromJson(json['album']),
      media: (json['media'] as List)
          .map((m) => MediaModel.fromJson(m))
          .toList(),
    );
  }
}
