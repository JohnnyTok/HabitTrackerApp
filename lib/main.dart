import 'package:flutter/material.dart';
import 'SignInPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal, // Updated theme to teal for consistency
        scaffoldBackgroundColor: Colors.grey[50], // A light background for all scaffolds
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[800],
          foregroundColor: Colors.white,
          elevation: 5,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal[800],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const SignInPage(),
    );
  }
}
