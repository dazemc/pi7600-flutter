import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/sms/sms_bloc.dart';
import 'package:pi7600_flutter/pages/pi_home.dart';
import 'package:pi7600_flutter/services/sms_api_service.dart';
import 'package:pi7600_flutter/bloc/home/home_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<SMSBloc>(
            create: (BuildContext context) => SMSBloc(SmsApiService())),
        BlocProvider<HomeBloc>(create: (BuildContext context) => HomeBloc())
      ],
      child: MaterialApp(
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
          home: SafeArea(child: const Home()))));
}
