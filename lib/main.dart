// lib/main.dart (original)
import 'package:flutter/material.dart';
import 'package:studyflow/pages/login_page.dart';
import 'package:studyflow/pages/register_page.dart';
import 'package:studyflow/pages/home_page.dart';
import 'package:studyflow/models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (_) => HomePage(user: user),
          );
        }
        return null;
      },
    );
  }
}