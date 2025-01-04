import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi7600_flutter/models.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final url = Uri.parse('http://192.168.0.186:8000/info');
  final urlSMS = Uri.parse('http://192.168.0.186:8000/sms?msg_query=ALL');

  Future<void> fetchData() async {
    final response = await http.get(url);
    print(response.body);
  }

  Future<List<SMS>> fetchSMS() async {
    final response = await http.get(urlSMS);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => SMS.fromJson(json)).toList();
  }

  Future<void> testSMS() async {
    List<SMS> smsResponse = await fetchSMS();
    print(smsResponse[0].contents);
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    testSMS();
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
