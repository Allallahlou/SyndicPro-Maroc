import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SyndicProApp());

class SyndicProApp extends StatelessWidget {
  const SyndicProApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF247A62);
    return MaterialApp(
      title: 'SyndicPro Maroc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F6),
          foregroundColor: Color(0xFF18352D),
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const HomeScreen(),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
  }
}
