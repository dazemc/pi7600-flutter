import '../models/info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final url = Uri.parse('https://pi.daazed.dev/info');
Future<Info> fetchInfo() async {
  final response = await http.get(url);
  final json = jsonDecode(response.body);
  return Info.fromJson(json);
}

Future<Info> getInfo() async {
  Info response = await fetchInfo();
  return response;
}
