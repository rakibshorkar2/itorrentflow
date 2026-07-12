import 'package:flutter/material.dart';
import 'torrent_service.dart';
import 'screens/home_screen.dart';

final TorrentService torrentService = TorrentService();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TorrentApp());
}

class TorrentApp extends StatelessWidget {
  const TorrentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DirXplore Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: HomeScreen(service: torrentService),
    );
  }
}
