import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/sms.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final client = HttpClient();
final urlSMS = Uri.parse('https://pi.daazed.dev/sms?msg_query=ALL');
final urlSendSMS = Uri.parse('https://pi.daazed.dev/sms');



Future<List<SMS>> fetchSMS() async {
  final response = await http.get(urlSMS);
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((json) => SMS.fromJson(json)).toList();
}

Future<SMS?> postNewSMS(SMS newMessage, Function() callback) async {
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
    callback();
    return SMS.fromJson(finalResponse);   
  } 
  if (kDebugMode) {
    print("Error sending message:\nstatus code: ${response.statusCode}\nbody: ${response.body}");
  }
  return null;
}