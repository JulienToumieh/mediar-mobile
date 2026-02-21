import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'pages/album_list.dart';
import 'theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Mediar',
      theme: buildTheme(
        seedColor: themeProvider.seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: buildTheme(
        seedColor: themeProvider.seedColor,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AlbumListPage(),
    );
  }
}
