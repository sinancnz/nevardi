import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nevardi',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Nevardi'),
        ),
        body: Center(
          child: Text('Hello Nevardi!'),
        ),
      ),
    );
  }
}
