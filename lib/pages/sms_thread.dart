import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/sms/sms_bloc.dart';
import 'package:pi7600_flutter/bloc/sms/sms_state.dart';
import 'package:pi7600_flutter/widgets/sms_thread_widget.dart';
import '../models/sms.dart';

class SMSThread extends StatelessWidget {
  final Map<String, List<SMS>> smsGrouped;
  final String originatingAddress;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SMSThread({
    super.key,
    required this.smsGrouped,
    required this.originatingAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              originatingAddress,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: Colors.grey,
            ),
          ),
        ),
        body: BlocBuilder<SMSBloc, SMSState>(builder: (context, state) {
          if (state is SMSInitial) {
            return Center(child: Text('No SMS loaded.'));
          } else if (state is SMSLoading) {
            // TODO: add a param to SMSThreadWidget so that it doesn't clear the screen while loading, a little circular in the corner should do.
            return Center(child: CircularProgressIndicator());
          } else if (state is SMSLoaded) {
            if (state.smsList.isEmpty) {
              return Center(
                child: Text('No SMS found.'),
              );
            } else {
              return SMSThreadWidget(smsGrouped: smsGrouped, originatingAddress: originatingAddress, scrollController: _scrollController, textController: _textController);
            }
          } else {
            // TODO: get a copy of these parameters to fallback on if in SMSFailed
            return SMSThreadWidget(smsGrouped: smsGrouped, originatingAddress: originatingAddress, scrollController: _scrollController, textController: _textController);
          }
        }),
      ),
    );
  }
}


