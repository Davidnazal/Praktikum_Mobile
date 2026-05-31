import 'package:flutter/material.dart';
import 'movie_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Film Mobile',
      debugShowCheckedModeBanner: false,
      // MENGUBAH TEMA MENJADI DARK MODE
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(
          0xFF151515,
        ), // Hitam yang nggak terlalu gelap
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      home: const MovieListScreen(),
    );
  }
}
