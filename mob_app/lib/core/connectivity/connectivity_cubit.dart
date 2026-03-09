import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/connectivity_service.dart';


class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._service) : super(true) {
    _init();
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {

    final connected = await _service.isConnected;
    emit(connected);


    _subscription = _service.onConnectivityChanged.listen(emit);
  }


  Future<bool> checkNow() async {
    final connected = await _service.isConnected;
    emit(connected);
    return connected;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
