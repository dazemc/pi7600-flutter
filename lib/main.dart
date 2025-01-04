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

  Future<Info> fetchInfo() async {
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return Info.fromJson(json);
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

  Future<void> printInfo() async {
    Info response = await fetchInfo();
    print('${response.hostname}\n${response.uname}\n${response.date}\n${response.arch}');
  }

  @override
  Widget build(BuildContext context) {
    printInfo();
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
