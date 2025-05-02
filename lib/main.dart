import 'package:facial/provider/blue_classic_provider.dart';
import 'package:facial/screen/logain_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleScanProviderTypeCLASSIC()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facial Recognition',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}
