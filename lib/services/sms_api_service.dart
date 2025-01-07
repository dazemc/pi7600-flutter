import '../models/sms.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final urlSMS = Uri.parse('http://192.168.0.186:8000/sms?msg_query=ALL');

Future<List<SMS>> fetchSMS() async {
  final response = await http.get(urlSMS);
  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList.map((json) => SMS.fromJson(json)).toList();
}
