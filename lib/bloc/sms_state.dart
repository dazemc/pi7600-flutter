import '../models/sms.dart';
import 'package:equatable/equatable.dart';

abstract class SMSState extends Equatable {
  const SMSState();

  @override
  List<Object> get props => [];
}

class SMSInital extends SMSState {}

class SMSLoading extends SMSState {}

class SMSLoaded extends SMSState {
  final List<SMS> smsList;
  const SMSLoaded(this.smsList);

  @override
  List<Object> get props => [smsList];
}

class SMSError extends SMSState {
  final String message;
  const SMSError(this.message);

  @override
  List<Object> get props => [message];
}
