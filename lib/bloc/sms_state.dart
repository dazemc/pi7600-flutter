import '../models/sms.dart';
import 'package:equatable/equatable.dart';

abstract class SMSState extends Equatable {
  const SMSState();

  @override
  List<Object> get props => [];
}

class SMSInitial extends SMSState {}

class SMSLoading extends SMSState {}

class SMSLoaded extends SMSState {
  final List<SMS> smsList;
  final List<SMS> smsPreviewList;
  final List<String> smsPreviewMessages;
  final Map<String, List<SMS>> smsFinalGrouped;

  const SMSLoaded(this.smsList, this.smsPreviewList, this.smsPreviewMessages,
      this.smsFinalGrouped);

  @override
  List<Object> get props => [smsList];
}

class SMSFailed extends SMSState {
  final String message;
  const SMSFailed(this.message);

  @override
  List<Object> get props => [message];
}

class SMSSent extends SMSState {
  final SMS sentMessageVerified;
  const SMSSent(this.sentMessageVerified);

  @override
  List<Object> get props => [sentMessageVerified];
}

class SMSError extends SMSState {
  final String message;
  const SMSError(this.message);

  @override
  List<Object> get props => [message];
}

class SMSSending extends SMSState {}
