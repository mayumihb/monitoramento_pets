import 'package:flutter/material.dart';
import 'package:monitoramento_pets/screens/homescreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAr8eC7H0UlWIQxFQJN1pnnN598grrZ90k",
      appId: "1:1096921371208:android:24996946b05b56369f7e7d",
      messagingSenderId: "1096921371208",
      projectId: "monitoramento-pets",
      databaseURL: "https://monitoramento-pets-default-rtdb.firebaseio.com",
    ),
  );
  runApp(PetMonitorApp());
}

class PetMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}