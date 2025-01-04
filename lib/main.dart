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

  Future<List<SMS>> getSMS() async {
    List<SMS> smsResponse = await fetchSMS();
    return smsResponse;
  }

  Future<Info> getInfo() async {
    Info response = await fetchInfo();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<SMS>> smsResponse = getSMS();
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<SMS>>(
          future: smsResponse,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var sms = snapshot.data![0];
              return Center(
                child: Text(sms.contents),
              );
            }
            else {
              return Center(
                child: Text("No SMS data."),
              );
            }
            
          }
        ),
      ),
    );
  }
}
