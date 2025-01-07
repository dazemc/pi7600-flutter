import 'package:flutter/foundation.dart';

import '../models/sms.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final urlSMS = Uri.parse('http://192.168.0.186:8000/sms?msg_query=ALL');
final urlSendSMS = Uri.parse('http://192.168.0.186:8000/sms');

Future<List<SMS>> fetchSMS() async {
  final response = await http.get(urlSMS);
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((json) => SMS.fromJson(json)).toList();
}

Future<SMS> postNewSMS(SMS newMessage, Function() callback) async {
  final Map<String, dynamic> newMsgJson = {
    "number": newMessage.destinationAddress,
    "msg": newMessage.contents,
  };
  final response = await http.post(
    urlSendSMS,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(newMsgJson) 
  );
  if (response.statusCode == 200) {
    if (kDebugMode) {
      print("Sent new message successfully");
    }
    
  }
  final finalResponse = jsonDecode(response.body);
  callback();
  return SMS.fromJson(finalResponse);
}