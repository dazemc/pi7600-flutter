import 'package:equatable/equatable.dart';
import '../../models/sms.dart';

abstract class SMSEvent extends Equatable {
  const SMSEvent();

  @override
  List<Object> get props => [];
}

class SMSLoad extends SMSEvent {}

class SMSSend extends SMSEvent {
  final SMS sms;
  const SMSSend(this.sms);

  @override
  List<Object> get props => [sms];
}
