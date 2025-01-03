import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final url = Uri.parse('http://192.168.0.186:8000/info');

  Future<void> fetchData() async {
    final response = await http.get(url);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
