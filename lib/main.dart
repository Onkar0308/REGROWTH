import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:regrowth_mobile/app/app.dart';
import 'package:regrowth_mobile/provider/refresh_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RefreshStateNotifier(),
      child: const MyApp(),
    ),
  );
}
