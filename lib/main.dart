import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Make sure this import is correct
import 'package:happy_school/admin/adminHome.dart';
import 'package:happy_school/user/MainHome.dart';
import 'package:happy_school/user/coursenames.dart';
import 'package:happy_school/user/userHome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Ensure Firebase is initialized properly
// InAppWebViewPlatform.instance = WebUiPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const Userhome(),
    );
  }
}
