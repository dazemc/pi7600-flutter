import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/sms.dart';
import 'services/sms_api_service.dart';

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
  List<SMS> smsList = [];
  List<SMS> latestsmsList = [];
  Map<String, List<SMS>> finalGroupedSMS = {};

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
                              subtitle: msg.type == "SENT"
                                  ? Text('You: ${msg.contents}')
                                  : Text(msg.contents),
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

class SMSThread extends StatefulWidget {
  final Map<String, List<SMS>> smsGrouped;
  final String originatingAddress;
  final void Function() callback;

  const SMSThread(
      {super.key,
      required this.smsGrouped,
      required this.originatingAddress,
      required this.callback});

  @override
  SMSThreadState createState() => SMSThreadState();
}

class SMSThreadState extends State<SMSThread> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              widget.originatingAddress,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    widget.callback();
                  });
                },
                child: widget.smsGrouped[widget.originatingAddress]!.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: widget
                            .smsGrouped[widget.originatingAddress]!.length,
                        itemBuilder: (context, index) {
                          SMS msg = widget
                              .smsGrouped[widget.originatingAddress]![index];
                          bool isSent = msg.type == "SENT";

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSent
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: SelectableText(
                                      msg.contents,
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: isSent
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${msg.date} ${msg.time}',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    textAlign: isSent
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(12.0, 2.0, 2.0, 4.0),
                  title: TextField(
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          final newMsg = SMS(
                            destinationAddress: widget.originatingAddress,
                            type: "SENT",
                            contents: _textController.text,
                            date:
                                "", // server handles this for now but will need for local db
                            time: "", // """"
                          );
                          postNewSMS(newMsg, widget.callback);
                          _textController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      icon: Icon(Icons.send)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
