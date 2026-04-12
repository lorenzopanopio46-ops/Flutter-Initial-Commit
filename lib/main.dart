import 'package:flutter/material.dart';
import 'login_page.dart'; // Ini-import ang ginawa mong login page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen App',
      debugShowCheckedModeBanner: false, // Tinatanggal ang "debug" banner sa taas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Dito natin binago para LoginPage na ang default screen
      home: LoginPage(), 
    );
  }
}