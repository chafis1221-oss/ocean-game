// app.dart - Root widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import '../providers/game_provider.dart';

class OceanCommandApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocean Command',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[900],
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
