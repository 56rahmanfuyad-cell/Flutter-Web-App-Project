import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_project/home_page.dart';
import 'package:my_project/login_page.dart';
import 'package:my_project/services/supabase_service.dart';

Future<void> main() async {
  // Ensures Flutter engine is fully initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Connects our app to the Supabase cloud backend
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Skill Share',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      // Supabase restores a saved session during initialization.
      home: SupabaseService.isAuthenticated
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
