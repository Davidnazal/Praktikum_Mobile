import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_services.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieService _movieService = MovieService();

  List<GenreModel> _genres = [];
  List<MovieModel> _movies = [];

  bool _isLoadingMovies = true;
  int _selectedGenreId = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      final genres = await _movieService.fetchGenres();
      genres.insert(0, GenreModel(id: 0, name: 'Semua'));

      if (mounted) {
        setState(() {
          _genres = genres;
        });
      }

      _loadMovies();
    } catch (e) {
      debugPrint("Error loading genres: $e");
    }
  }

  void _loadMovies() async {
    if (mounted) {
      setState(() => _isLoadingMovies = true);
    }

    try {
      final movies = await _movieService.fetchMovies(
        genreId: _selectedGenreId,
        searchQuery: _searchController.text,
      );

      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMovies = false);
      }
      debugPrint("Error loading movies: $e");
    }
  }

  Widget _buildRatingCircle(double voteAverage) {
    int percentage = (voteAverage * 10).round();

    Color progressColor;
    if (percentage >= 70) {
      progressColor = Colors.greenAccent;
    } else if (percentage >= 40) {
      progressColor = Colors.yellow;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFF081C22),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            color: progressColor,
            backgroundColor: progressColor.withValues(alpha: 0.3),
            strokeWidth: 3,
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),

      body: CustomScrollView(
        slivers: [
          // 1. SLIVER APP BAR (Judul & Search Bar)
          SliverAppBar(
            pinned: true,
            floating: true,
            // Pakai warna yang SAMA PERSIS dengan background agar menyatu tanpa garis/blok
            backgroundColor: const Color(0xFF151515),
            surfaceTintColor: Colors.transparent,
            elevation: 0,

            // KEMBALIKAN JUDUL APLIKASI
            title: const Text(
              '🎬 MovieDex',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari film...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) => _loadMovies(),
                ),
              ),
            ),
          ),

          // 2. KATEGORI SCROLL SAMPING
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = genre.id == _selectedGenreId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        genre.name,
                        style: TextStyle(
                          // WARNA TEKS DIPERBAIKI: Putih jika dipilih, abu terang jika tidak
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.blueAccent,
                      // WARNA BACKGROUND DIPERBAIKI: Mengikuti standar Dark Mode
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade700,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenreId = genre.id;
                          _searchController.clear();
                        });
                        _loadMovies();
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 3. GRID DAFTAR FILM
          _isLoadingMovies
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _movies.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Tidak ada film ditemukan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final movie = _movies[index];
                      final imageUrl = movie.posterPath != null
                          ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                          : 'https://via.placeholder.com/500x750?text=No+Image';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: _buildRatingCircle(
                                      movie.voteAverage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }, childCount: _movies.length),
                  ),
                ),
        ],
      ),
    );
  }
}
