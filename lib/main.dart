import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movies_app/firebase_options.dart';
import 'package:movies_app/logic/cubits/auth/auth_cubit.dart';
import 'package:movies_app/logic/cubits/language/language_cubit.dart';
import 'package:movies_app/logic/cubits/movies/movies_cubit.dart';
import 'package:movies_app/logic/cubits/watchlist/watchlist_cubit.dart';
import 'package:movies_app/presentation/screens/splash_screen.dart';

import 'core/constants/app_colors.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => MoviesCubit()),
        BlocProvider(create: (context) => WatchlistCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            locale: context.watch<LanguageCubit>().state,
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.black,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.yellow,
                brightness: Brightness.dark,
                surface: AppColors.black,
              ),
              useMaterial3: true,
            ),
            home: child,
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}
