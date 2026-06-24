import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/twist_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TwistApp());
}

class TwistApp extends StatelessWidget {
  const TwistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TwistProvider(),
      child: MaterialApp(
        title: 'Twist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
