import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TlpElectionApp());
}

class TlpElectionApp extends StatelessWidget {
  const TlpElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLP Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const UserListScreen(),
    );
  }
}
