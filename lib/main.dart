// main.dart - Entry point

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: OceanCommandApp(),
    ),
  );
}
