import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_tuner/screens/auth_gate.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TripTunerApp());
}

class TripTunerApp extends StatelessWidget {
  const TripTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6B5A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}