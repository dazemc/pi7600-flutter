import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pi7600_flutter/models.dart';

void main() {
  if (kDebugMode) {
    print("DEBUG BUILD");
  }
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
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: getSMS,
          child: FutureBuilder<List<SMS>>(
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

                  Map<String, List<SMS>> finalGroupedSMS = {};
                  groupedSMS.forEach((address, smsGroup) {
                    smsGroup.sort((a, b) => a.time.compareTo(b.time));
                    List<SMS> mergedMessages = [];
                    SMS? previousMessage;

                    for (var sms in smsGroup) {
                      if (previousMessage != null) {
                        final previousTime = DateTime.parse(
                            '${previousMessage.date} ${previousMessage.time}');
                        final currentTime =
                            DateTime.parse('${sms.date} ${sms.time}');
                        final timeDifference =
                            currentTime.difference(previousTime).inSeconds;
                        if (timeDifference <= 10) {
                          previousMessage = SMS(
                            idx: previousMessage.contents,
                            contents: previousMessage.contents + sms.contents,
                            originatingAddress: sms.originatingAddress,
                            destinationAddress: sms.destinationAddress,
                            time: previousMessage.time,
                            date: previousMessage.date,
                            type: sms.type,
                          );
                        }
                      } else {
                        if (previousMessage != null) {
                          mergedMessages.add(previousMessage);
                        }
                        previousMessage = sms;
                      }
                    }

                    if (previousMessage != null) {
                      mergedMessages.add(previousMessage);
                    }
                    finalGroupedSMS[address] = mergedMessages;
                  });

                  List<String> groupedAddresses = finalGroupedSMS.keys.toList();
                  return ListView.builder(
                    itemCount: groupedAddresses.length,
                    itemBuilder: (context, index) {
                      String address = groupedAddresses[index];
                      List<SMS> groupSMS = finalGroupedSMS[address]!;

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
                                // leading: Text(msg.originatingAddress!),
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
      ),
    );
  }
}
