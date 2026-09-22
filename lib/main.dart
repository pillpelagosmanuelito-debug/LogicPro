import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modules/home/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: LogicProApp()));
}

class LogicProApp extends StatelessWidget {
  const LogicProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogicPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema(),
      home: const HomeShell(),
    );
  }
}
