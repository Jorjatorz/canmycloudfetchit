import 'package:cloud_api_fetcher/design/constants.dart';
import 'package:cloud_api_fetcher/pages/main_page.dart';
import 'package:cloud_api_fetcher/states/searchState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchStateNotifier(),
      child: MaterialApp(
        title: 'Can my Cloud fetch it?',
        themeMode: ThemeMode.dark,
        darkTheme: cDarkThemeData,
        home: const MainPage(),
      ),
    );
  }
}
