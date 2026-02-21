class AlbumModel {
  final int id;
  final String name;
  final String description;
  final String coverImageUrl;
  final DateTime dateCreated;

  AlbumModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.dateCreated,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }
}
