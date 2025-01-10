import 'package:flutter/material.dart';
import 'sms_thread.dart';
import '../models/sms.dart';
import '../services/sms_api_service.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  List<SMS> smsList = [];
  List<SMS> latestsmsList = [];
  Map<String, List<SMS>> finalGroupedSMS = {};

  String getMessagePreview(SMS msg) {
    String finalMessage = "";
    if (msg.type == "SENT") {
      finalMessage = "You: ";
    }
    if (msg.contents.length > 100) {
      finalMessage = '$finalMessage${msg.contents.substring(0, 100)}...';
    } else {
      finalMessage += msg.contents;
    }
    return finalMessage;
  }

  Future<void> getSMS() async {
    Map<String, SMS> latestMessage = {};
    Map<String, List<SMS>> groupedSMS = {};
    List<SMS> smsResponse = await fetchSMS();
    setState(() {
      smsList.clear();
      smsList.addAll(smsResponse);
      latestsmsList.clear();
      finalGroupedSMS.clear();

      for (var sms in smsList) {
        final originatingAddress = sms.originatingAddress!;
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
            if (timeDifference <= 1 && sms.type != "SENT") {
              previousMessage = SMS(
                idx: previousMessage.idx,
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
        final SMS mostRecentMessage = smsGroup[smsGroup.length - 1];
        latestMessage[address] = mostRecentMessage;
      });
      smsList = finalGroupedSMS.values.expand((x) => x).toList();
      latestsmsList = latestMessage.values.toList();
    });
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
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
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
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 24.0),
                            child: ListTile(
                              subtitle: Text(
                                getMessagePreview(msg),
                              ),
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
                                    callback: getSMS,
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
      ),
    );
  }
}
