import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'user.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tuccgbpwhtcmyrzjwbak.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1Y2NnYnB3aHRjbXlyemp3YmFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTQ2ODIsImV4cCI6MjA1NDI5MDY4Mn0.mxIHhJcI_PaD9juARV0-7CiD3mEbDV9KOLKk63yddG4',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Panggil halaman login
    );
  }
}