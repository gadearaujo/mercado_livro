import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mercado_livro/ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado Livro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Kanit-Regular',
      ),
      home: const HomeScreen(),
    );
  }
}
