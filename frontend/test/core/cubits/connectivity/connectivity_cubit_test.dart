import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/cubits/connectivity/connectivity_cubit_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> controller;

  setUp(() {
    connectivity = MockConnectivity();
    controller = StreamController<List<ConnectivityResult>>.broadcast();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);
  });

  tearDown(() => controller.close());

  test('first event with connection stays silent; without emits Disconnected',
      () async {
    final cubit = ConnectivityCubit(connectivity);
    controller.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, isA<ConnectivityCubitInitial>());
    await cubit.close();

    final offlineCubit = ConnectivityCubit(connectivity);
    controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(offlineCubit.state, isA<ConnectivityDisconnected>());
    await offlineCubit.close();
  });

  test('subsequent transitions emit Connected/Disconnected', () async {
    final cubit = ConnectivityCubit(connectivity);
    controller.add([ConnectivityResult.wifi]); // init
    await Future<void>.delayed(const Duration(milliseconds: 10));

    controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, isA<ConnectivityDisconnected>());

    controller.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, isA<ConnectivityConnected>());
    await cubit.close();
  });
}
