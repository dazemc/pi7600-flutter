import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/pages/pi_home.dart';

abstract class HomeEvent extends Equatable {
const HomeEvent();

@override
List<Object> get props => [];

}

class HomeButtonClick extends HomeEvent {

}


