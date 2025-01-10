import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sms_event.dart';
import 'sms_state.dart';
import '../models/sms.dart';

final Uri urlSMS = Uri.parse('https://pi.daazed.dev/sms?msg_query=ALL');
final Uri urlSendSMS = Uri.parse('https://pi.daazed.dev/sms');

class SMSBloc extends Bloc<SMSEvent, SMSState> {
  SMSBloc() : super(SMSInital()) {
    @override
    Stream<SMSState> mapEventToState(SMSEvent event) async* {
      if (event is LoadSMS) {
        yield SMSLoading();
        try {
          final smsList = await _fetchSMS();
          yield SMSLoaded(smsList);
        } catch (e) {
          yield SMSError(e.toString());
          if (kDebugMode) {
            throw Exception("/sms GET Error ${e.toString()}");
          }
        }
      }
    }
  }
}

Future<List<SMS>> _fetchSMS() async {
  final response = await http.get(urlSMS);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => SMS.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load SMS');
  }
}
