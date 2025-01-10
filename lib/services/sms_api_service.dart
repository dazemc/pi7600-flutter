import 'package:flutter/foundation.dart';
import '../models/sms.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SmsApiService {
  final Uri urlSMS = Uri.parse('https://pi.daazed.dev/sms?msg_query=ALL');
  final Uri urlSendSMS = Uri.parse('https://pi.daazed.dev/sms');
  List<SMS> smsList = [];
  List<SMS> latestsmsList = [];
  List<String> smsPreviewMessages = [];
  Map<String, List<SMS>> finalGroupedSMS = {};

  Future<List<SMS>> fetchSMS() async {
    final response = await http.get(urlSMS);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      smsList = jsonList.map((json) => SMS.fromJson(json)).toList();
      getSMS();
      return smsList;
    } else {
      throw Exception('Failed to load SMS');
    }
  }

  Future<SMS?> postNewSMS(SMS newMessage) async {
    final Map<String, dynamic> newMsgJson = {
      "number": newMessage.destinationAddress,
      "msg": newMessage.contents,
    };
    var response = await http.post(
      urlSendSMS,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(newMsgJson),
    );
    if (response.statusCode == 301 || response.statusCode == 302) {
      if (kDebugMode) {
        print("/sms Redirect: ${response.headers['location']}");
      }
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print("Sent new message successfully");
      }
      final finalResponse = jsonDecode(response.body);
      return SMS.fromJson(finalResponse);
    }
    if (kDebugMode) {
      print(
          "Error sending message:\nstatus code: ${response.statusCode}\nbody: ${response.body}");
    }
    return null;
  }

  Future<void> getSMS() async {
    Map<String, SMS> latestMessage = {};
    Map<String, List<SMS>> groupedSMS = {};
    // List<SMS> smsResponse = await fetchSMS();
    // smsList.clear();
    // smsList.addAll(smsResponse);
    // latestsmsList.clear();
    // finalGroupedSMS.clear();
    // smsPreviewMessages.clear();

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
          final previousTime =
              DateTime.parse('${previousMessage.date} ${previousMessage.time}');
          final currentTime = DateTime.parse('${sms.date} ${sms.time}');
          final timeDifference = currentTime.difference(previousTime).inSeconds;
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
    smsPreviewMessages = _getMessagePreviews(latestsmsList);
  }

  List<String> _getMessagePreviews(List<SMS> messages) {
    List<String> finalMessage = [];
    print("PREVIEW $messages");
    for (SMS msg in messages) {
      String parsedMessage = '';
      if (msg.type == "SENT") {
        print(msg.contents);
        parsedMessage = "You: ";
      }
      if (msg.contents.length > 75) {
        finalMessage.add('$parsedMessage${msg.contents.substring(0, 75)}...');
      } else {
        finalMessage.add('$parsedMessage${msg.contents}');
      }
    }
    return finalMessage;
  }
}
