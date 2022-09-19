import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/search_places_screen.dart';
import 'package:users_app/mainScreens/select_active_driver_screen.dart';
import 'package:users_app/splashScreen/splash_screen.dart';

import 'authentication/login_screen.dart';
import 'authentication/register_screen.dart';
import 'mainScreens/main_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
    create: (context) => AppInfo(),
    child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/' : (context) => MySplashScreen(),
          '/main_screen': (context) => MainScreen(),
         '/login_screen' : (context) => Login(),
         '/register_screen': (context) => Register(),
         '/search_places_screen': (context) => SearchPlaces(),
         '/select_active_driver_screen' : (context) => SelectActiveDriverScreen(),
         '/rate_driver_screen' : (context) => RateDriverScreen(),
        },
        //home: Home(),
        debugShowCheckedModeBanner: false
    ),
  ));
}






