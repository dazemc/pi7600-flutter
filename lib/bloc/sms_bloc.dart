import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/sms_event.dart';
import 'package:pi7600_flutter/bloc/sms_state.dart';
import '../services/sms_api_service.dart';

class SMSBloc extends Bloc<SMSEvent, SMSState> {
  final SmsApiService smsApiService;

  SMSBloc(this.smsApiService) : super(SMSInitial()) {
    on<SMSSend>((event, emit) async {
      emit(SMSLoading());
      try {
        await smsApiService.postNewSMS(event.sms);
        emit(SMSSent(event.sms));
      } catch (e) {
        emit(SMSFailed(e.toString()));
      }
      add(SMSLoad());
    });

    on<SMSLoad>((event, emit) async {
      emit(SMSLoading());
      try {
        final smsList = await smsApiService.fetchSMS();
        final smsPreviewList = smsApiService.latestsmsList;
        final smsPreviewMessages = smsApiService.smsPreviewMessages;
        final smsFinalGrouped = smsApiService.finalGroupedSMS;
        emit(SMSLoaded(
            smsList, smsPreviewList, smsPreviewMessages, smsFinalGrouped));
      } catch (e) {
        emit(SMSError(e.toString()));
      }
    });
  }
}
