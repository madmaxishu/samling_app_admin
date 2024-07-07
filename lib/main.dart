import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:samling_app_web/views/main_scree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAbCfPTjvHiT49cWHC5zh2u19CXlprKnGQ",
      appId: "1:68457817959:web:3583671e066e24420371c2",
      messagingSenderId: "68457817959",
      projectId: "samling-app",
      storageBucket: "samling-app.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
