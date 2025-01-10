import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/sms_bloc.dart';
import 'package:pi7600_flutter/services/sms_api_service.dart';
import 'pages/sms_home.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => SMSBloc(
        SmsApiService(),
      ),
      child: const MainApp(),
    ),
  );
}
