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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final url = Uri.parse('http://192.168.0.186:8000/info');
  final urlSMS = Uri.parse('http://192.168.0.186:8000/sms?msg_query=ALL');

  List<SMS> smsList = [];
  List<SMS> latestsmsList = [];
  Map<String, List<SMS>> finalGroupedSMS = {};

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

  Future<void> getSMS() async {
    List<SMS> smsResponse = await fetchSMS();
    setState(() {
      smsList.clear();
      smsList.addAll(smsResponse);
      latestsmsList.clear();
      finalGroupedSMS.clear();

      Map<String, SMS> latestMessage = {};
      Map<String, List<SMS>> groupedSMS = {};

      for (var sms in smsList) {
        final originatingAddress = sms.originatingAddress ?? 'Unknown';
        if (!groupedSMS.containsKey(originatingAddress)) {
          groupedSMS[originatingAddress] = [];
        }
        groupedSMS[originatingAddress]!.add(sms);
      }

      groupedSMS.forEach((address, smsGroup) {
        smsGroup.sort((a, b) => a.time.compareTo(b.time));
        List<SMS> mergedMessages = [];
        SMS? previousMessage;

        for (var sms in smsGroup) {
          latestMessage[address] = sms;
          if (previousMessage != null) {
            if (previousMessage.date != sms.date) {
              mergedMessages.add(previousMessage);
              previousMessage = sms;
              continue;
            }
            final previousTime = DateTime.parse(
                '${previousMessage.date} ${previousMessage.time}');
            final currentTime = DateTime.parse('${sms.date} ${sms.time}');
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
            } else {
              mergedMessages.add(previousMessage);
              previousMessage = sms;
            }
          } else {
            previousMessage = sms;
          }
        }
        if (previousMessage != null) {
          mergedMessages.add(previousMessage);
        }
        finalGroupedSMS[address] = mergedMessages;
      });
      finalGroupedSMS.forEach((address, smsGroup) {
        smsGroup.sort(
          (a, b) {
            DateTime aTime = DateTime.parse('${a.date} ${a.time}');
            DateTime bTime = DateTime.parse('${b.date} ${b.time}');
            return aTime.compareTo(bTime);
          },
        );
      });
      smsList = finalGroupedSMS.values.expand((x) => x).toList();
      latestsmsList = latestMessage.values.toList();
    });
  }

  Future<Info> getInfo() async {
    Info response = await fetchInfo();
    return response;
  }

  @override
  void initState() {
    super.initState();
    getSMS();
  }

  @override
  Widget build(BuildContext context) {
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
          child: latestsmsList.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: latestsmsList.length,
                  itemBuilder: (context, index) {
                    SMS msg = latestsmsList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            subtitle: Text(msg.contents),
                            title: Text(
                              msg.originatingAddress!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            leading: Icon(
                              Icons.contacts,
                              color: Colors.grey,
                            ), // Icon
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SMSThread(
                                  smsGrouped: finalGroupedSMS,
                                  originatingAddress: msg.originatingAddress!,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class SMSThread extends StatefulWidget {
  final Map<String, List<SMS>> smsGrouped;
  final String originatingAddress;
  const SMSThread(
      {super.key, required this.smsGrouped, required this.originatingAddress});

  @override
  SMSThreadState createState() => SMSThreadState();
}

class SMSThreadState extends State<SMSThread> {
  @override
  Widget build(BuildContext context) {
    print(widget.smsGrouped[widget.originatingAddress]!);
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: widget.smsGrouped[widget.originatingAddress]!.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount:
                      widget.smsGrouped[widget.originatingAddress]!.length,
                  itemBuilder: (context, index) {
                    SMS msg =
                        widget.smsGrouped[widget.originatingAddress]![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(msg.contents),
                            subtitle: Text('${msg.date} ${msg.time}'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
