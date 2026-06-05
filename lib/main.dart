import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/twist_provider.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TwistProvider(),
      child: MaterialApp(
        title: 'Twist Loyalty',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const LoginScreen(),
      ),
    );
  }
}
