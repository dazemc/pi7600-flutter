import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi7600_flutter/bloc/home/home_event.dart';
import 'package:pi7600_flutter/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    print('HomeBloc loaded');
  }
  
}