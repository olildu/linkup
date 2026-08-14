import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/logic/bloc/connections/connections_bloc.dart';
import 'package:linkup/logic/bloc/likes/likes_bloc.dart';
import 'package:linkup/logic/bloc/matches/matches_bloc.dart';
import 'package:linkup/logic/bloc/post_login/post_login_bloc.dart';
import 'package:linkup/logic/bloc/profile/own/profile_bloc.dart';
import 'package:linkup/logic/cubit/app_lock/app_lock_cubit.dart';
import 'package:linkup/logic/bloc/web_socket/chat_sockets/chat_sockets_bloc.dart';
import 'package:linkup/logic/bloc/web_socket/connection_sockets/connections_socket_bloc.dart';
import 'package:linkup/logic/bloc/web_socket/web_socket_bloc.dart';
import 'package:linkup/logic/cubit/connectivity_cubit/cubit/connectivity_cubit_cubit.dart';
import 'package:linkup/logic/cubit/theme/theme_cubit.dart';
import 'package:linkup/presentation/theme/app_theme.dart';
import 'package:linkup/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/logic/provider/data_validator_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataValidatorProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<MatchesBloc>()),
          BlocProvider(create: (_) => sl<ConnectionsBloc>()),
          BlocProvider(create: (_) => sl<LikesBloc>()),
          BlocProvider(create: (_) => sl<ProfileBloc>()),
          BlocProvider(create: (_) => WebSocketBloc()),
          BlocProvider(create: (_) => sl<ChatSocketsBloc>()),
          BlocProvider(create: (_) => ConnectionsSocketBloc()),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AppLockCubit()),
          BlocProvider(create: (_) => ConnectivityCubit(Connectivity())),
          BlocProvider(
            create: (context) => PostLoginBloc(
              matchesBloc: context.read<MatchesBloc>(),
              webSocketBloc: context.read<WebSocketBloc>(),
              chatSocketsBloc: context.read<ChatSocketsBloc>(),
              profileBloc: context.read<ProfileBloc>(),
              connectionsBloc: context.read<ConnectionsBloc>(),
              connectionsSocketBloc: context.read<ConnectionsSocketBloc>(),
              likesBloc: context.read<LikesBloc>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.43, 866.28),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'linkup',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: BlocListener<ConnectivityCubit, ConnectivityCubitState>(
              listener: (context, state) {},
              child: const LoadingScreenPostLogin(),
            ),
          );
        },
      ),
    );
  }
}
