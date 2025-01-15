import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final url = Uri.parse('https://pi.daazed.dev/token');
final _storage = const FlutterSecureStorage();
String? token;

Future<bool> login(String username, String password) async {
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  final Map<String, String> body = {
    'grant_type': 'password',
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['access_token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      } else {
        print('Access token is null');
        return false;
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Request failed: $e');
    return false;
  }
}

Future<String?> getToken() async {
  return await _storage.read(key: 'jwt_token');
}

Future<void> attemptLogin() async {
  final bool attempt =
      await login(dotenv.env['USERNAME'] ?? '', dotenv.env['PASSWORD'] ?? '');
  if (attempt) token = await getToken();
}
