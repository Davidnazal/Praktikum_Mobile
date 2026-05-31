import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String _apiKey = '42b44f227c9fff54946ccc5fa97ad067';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<GenreModel>> fetchGenres() async {
    final uri = Uri.parse(
      '$_baseUrl/genre/movie/list?api_key=$_apiKey&language=id-ID',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> genresJson = data['genres'];
      return genresJson.map((json) => GenreModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  Future<List<MovieModel>> fetchMovies({
    int? genreId,
    String searchQuery = '',
  }) async {
    String url = '$_baseUrl/movie/popular?api_key=$_apiKey&language=id-ID';

    if (searchQuery.isNotEmpty) {
      url =
          '$_baseUrl/search/movie?api_key=$_apiKey&query=$searchQuery&language=id-ID';
    } else if (genreId != null && genreId != 0) {
      url =
          '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&language=id-ID';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> moviesJson = data['results'];
      return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat film');
    }
  }

  Future<List<CastModel>> fetchMovieCredits(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> castJson = data['cast'];
      return castJson.take(10).map((json) => CastModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat pemeran');
    }
  }

  Future<String?> fetchMovieTrailer(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> videosJson = data['results'];

      for (var video in videosJson) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          return video['key'];
        }
      }
      return null;
    } else {
      return null;
    }
  }
}
