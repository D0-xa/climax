import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:climax/screens/loading_screen.dart';
import 'package:climax/services/conversions.dart'
    show darkMode, deviceWidth, fontScale;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    darkMode = MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    fontScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1.0;
    deviceWidth = MediaQuery.sizeOf(context).width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Climax',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: const Color(0xff0457c5),
        ),
        textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
          bodySmall: GoogleFonts.roboto(
            textStyle: textTheme.bodySmall!.copyWith(fontSize: 16.0),
          ),
          titleSmall: GoogleFonts.roboto(
            textStyle: textTheme.titleSmall!.copyWith(fontSize: 14.0),
          ),
          titleMedium: GoogleFonts.roboto(
            textStyle: textTheme.titleMedium!.copyWith(
              fontSize: 32.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          labelSmall: GoogleFonts.roboto(
            textStyle: textTheme.labelSmall!.copyWith(
              fontSize: 11.0,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData().copyWith(
          contentTextStyle: TextStyle(fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
          actionTextColor: const Color(0xff9cc7fb),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: const Color(0xffdde8f3),
        ),
        textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
          bodySmall: GoogleFonts.roboto(
            textStyle: textTheme.bodySmall!.copyWith(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          bodyMedium: GoogleFonts.roboto(
            textStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
          titleSmall: GoogleFonts.roboto(
            textStyle: textTheme.titleSmall!.copyWith(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
          titleMedium: GoogleFonts.roboto(
            textStyle: textTheme.titleMedium!.copyWith(
              fontSize: 32.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          labelSmall: GoogleFonts.roboto(
            textStyle: textTheme.labelSmall!.copyWith(
              fontSize: 11.0,
              color: const Color(0xffb9c9d9),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData().copyWith(
          contentTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
          behavior: SnackBarBehavior.floating,
          actionTextColor: const Color(0xff407bab),
        ),
      ),
      home: LoadingScreen(),
    );
  }
}
