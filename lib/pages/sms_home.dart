import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/sms/sms_bloc.dart';
import 'package:pi7600_flutter/bloc/sms/sms_state.dart';
import 'package:pi7600_flutter/bloc/sms/sms_event.dart';
import 'sms_thread.dart';
import '../models/sms.dart';

class SMSHome extends StatelessWidget {
  const SMSHome({super.key});

  @override
  Widget build(BuildContext context) {
    // print("Loading SMS");
    context.read<SMSBloc>().add(SMSLoad());
    // print("SMS Loaded");
    return Scaffold(
      body: BlocBuilder<SMSBloc, SMSState>(
        builder: (context, state) {
          if (state is SMSInitial) {
            // print("SMSInitial");
            return Center(child: Text('No SMS loaded.'));
          } else if (state is SMSLoading) {
            // print("SMSLoading");
            return Center(child: CircularProgressIndicator());
          } else if (state is SMSLoaded) {
            // print("SMSLoaded");
            if (state.smsList.isEmpty) {
              // print("smsList empty");
              return Center(
                child: Text('No SMS found.'),
              );
            } else {
              // print("Buidling home page list");
              // print("itemCount: ${state.smsPreviewList.length}");
              return ListView.builder(
                itemCount: state.smsPreviewList.length,
                itemBuilder: (context, index) {
                  SMS msg = state.smsPreviewList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 24.0),
                        child: ListTile(
                          subtitle: Text(
                            state.smsPreviewMessages[index],
                          ),
                          title: Text(
                            msg.originatingAddress!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          leading: Icon(
                            Icons.contacts,
                            color: Colors.grey,
                          ), // Icon
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SMSThread(
                                smsGrouped: state.smsFinalGrouped,
                                originatingAddress: msg.originatingAddress!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            context.read<SMSBloc>().add(
                  SMSLoad(),
                );
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
