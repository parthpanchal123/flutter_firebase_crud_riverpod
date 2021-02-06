import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_firebase/pages/HomeScreen.dart';

void main() async {
  // don't mess up the order of the steps here
  WidgetsFlutterBinding
      .ensureInitialized(); // Very Important to do (Reason below)
  await Firebase.initializeApp(); // this connects our app with Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      //
      child: MaterialApp(
        title: 'Firebase CRUD Demo',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
