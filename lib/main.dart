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
                List<SMS> smsList = snapshot.data!;

                Map<String, List<SMS>> groupedSMS = {};
                for (var sms in smsList) {
                  if (!groupedSMS.containsKey(sms.originatingAddress)) {
                    groupedSMS[sms.originatingAddress!] = [];
                  }
                  groupedSMS[sms.originatingAddress]!.add(sms);
                }

                List<String> groupedAddresses = groupedSMS.keys.toList();
                return ListView.builder(
                  itemCount: groupedAddresses.length,
                  itemBuilder: (context, index) {
                    String address = groupedAddresses[index];
                    List<SMS> groupSMS = groupedSMS[address]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            address,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        ...groupSMS.map((msg) => ListTile(
                              title: Text(msg.contents),
                              subtitle: Text('${msg.date} ${msg.time}'),
                              leading: Text(msg.originatingAddress!),
                            ))
                      ],
                    );
                    // SMS msg = smsList[index];
                  },
                );
              } else {
                return Center(
                  child: Text("No SMS data."),
                );
              }
            }),
      ),
    );
  }
}
