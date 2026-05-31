class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage; 

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'Tidak ada deskripsi',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0)
          .toDouble(), 
    );
  }
}

class GenreModel {
  final int id;
  final String name;

  GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(id: json['id'] ?? 0, name: json['name'] ?? 'Unknown');
  }
}

class CastModel {
  final String name;
  final String character;
  final String? profilePath;

  CastModel({required this.name, required this.character, this.profilePath});

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] ?? 'Unknown',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}
