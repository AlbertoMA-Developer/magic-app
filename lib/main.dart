import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_app_1/screens/game_setup_screen.dart';
import 'package:magic_app_1/screens/history_screen.dart';
import 'package:magic_app_1/screens/home_screen.dart';
import 'package:magic_app_1/screens/life_counter_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTG Life Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE94560),
          surface: Color(0xFF16213E),
          background: Color(0xFF1A1A2E),
          onPrimary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(), // Using Home as initial for now, splash logic can be added later
        '/home': (context) => const HomeScreen(),
        '/setup': (context) => const GameSetupScreen(),
        '/game': (context) => const LifeCounterScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
