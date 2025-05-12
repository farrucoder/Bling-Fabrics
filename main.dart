import 'package:blingfabrics/Provider/Productdata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/HomePage.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  //await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);


  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Productdata()),
      ],child :MyApp(),
      ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bling Fabrics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: InteractiveViewer(
          panEnabled: true, // Can move the widget
          scaleEnabled: true, // Can zoom in/out
          minScale: 1.0,
          maxScale: 3.0,
          child: RefreshIndicator(
            onRefresh: () async{
              setState(() {});
              await Future.delayed(Duration(seconds: 2));
            },
              child: Homepage())),
    );
  }
}
