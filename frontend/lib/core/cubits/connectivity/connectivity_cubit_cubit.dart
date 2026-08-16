import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

part 'connectivity_cubit_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityCubitState> {
  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool isInit = false;

  ConnectivityCubit(this._connectivity) : super(ConnectivityCubitInitial()) {
    _subscription = _connectivity.onConnectivityChanged.listen(_onChangedList);
  }

  void _onChangedList(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (!isInit) {
      isInit = true;
      if (!hasConnection) {
        emit(ConnectivityDisconnected());
      }
      return;
    }

    emit(hasConnection ? ConnectivityConnected() : ConnectivityDisconnected());
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
