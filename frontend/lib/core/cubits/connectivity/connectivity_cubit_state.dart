part of 'connectivity_cubit_cubit.dart';

@immutable
sealed class ConnectivityCubitState {}

final class ConnectivityCubitInitial extends ConnectivityCubitState {}

final class ConnectivityConnected extends ConnectivityCubitState {}

final class ConnectivityDisconnected extends ConnectivityCubitState {}
