import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'movie_model.dart';
import 'movie_services.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  late Future<List<CastModel>> _castFuture;

  YoutubePlayerController? _youtubeController;
  bool _isLoadingTrailer = true;

  @override
  void initState() {
    super.initState();
    _castFuture = _movieService.fetchMovieCredits(widget.movie.id);
    _loadTrailer();
  }

  void _loadTrailer() async {
    String? youtubeKey = await _movieService.fetchMovieTrailer(widget.movie.id);

    if (youtubeKey != null && mounted) {
      setState(() {
   
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: youtubeKey,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            mute: false,
            showFullscreenButton: true,
            loop: false,
          ),
        );
        _isLoadingTrailer = false;
      });
    } else {
      setState(() {
        _isLoadingTrailer = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.movie.backdropPath ?? widget.movie.posterPath;
    final fallbackImageUrl = imagePath != null
        ? 'https://image.tmdb.org/t/p/original$imagePath'
        : 'https://via.placeholder.com/500x300?text=No+Image';

    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: _isLoadingTrailer
                  ? const Center(child: CircularProgressIndicator())
                  : (_youtubeController != null
                        ? YoutubePlayer(controller: _youtubeController!)
                        : Image.network(fallbackImageUrl, fit: BoxFit.cover)),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sinopsis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pemeran:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  FutureBuilder<List<CastModel>>(
                    future: _castFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Gagal memuat pemeran');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Tidak ada data pemeran');
                      }

                      final castList = snapshot.data!;
                      return SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: castList.length,
                          itemBuilder: (context, index) {
                            final cast = castList[index];
                            final castImageUrl = cast.profilePath != null
                                ? 'https://image.tmdb.org/t/p/w200${cast.profilePath}'
                                : 'https://via.placeholder.com/150?text=No+Photo';

                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(castImageUrl),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cast.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
