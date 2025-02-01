import '../models/info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_api_service.dart';

final url = Uri.parse('https://pi.daazed.dev/info');
Future<Info?> fetchInfo() async {
  final token = await getToken();
  if (token != null) {
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return Info.fromJson(json);
  } else {
    print('ERROR: Token invalid');
  }
  return null;
}

Future<Info?> getInfo() async {
  Info? response = await fetchInfo();
  if (response != null) {
  return response;
  }
  return null; 
}
