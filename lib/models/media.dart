class MediaModel {
  final int id;
  final String imageUrl;
  final int albumId;

  MediaModel({
    required this.id,
    required this.imageUrl,
    required this.albumId,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      imageUrl: json['url'],
      albumId: json['albumId']
    );
  }
}
