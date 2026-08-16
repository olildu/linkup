import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:linkup/core/di/injection_container.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/onboarding/presentation/bloc/post_login_bloc.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:linkup/features/settings/presentation/app_lock_cubit.dart';
import 'package:linkup/features/messaging/presentation/bloc/chat_sockets_bloc.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_socket_bloc.dart';
import 'package:linkup/features/messaging/presentation/bloc/web_socket_bloc.dart';
import 'package:linkup/core/cubits/connectivity/connectivity_cubit_cubit.dart';
import 'package:linkup/core/cubits/theme/theme_cubit.dart';
import 'package:linkup/shared_ui/theme/app_theme.dart';
import 'package:linkup/features/onboarding/presentation/screens/loading_screen_post_login_page.dart';
import 'package:linkup/core/utils/data_validator_provider.dart';
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
