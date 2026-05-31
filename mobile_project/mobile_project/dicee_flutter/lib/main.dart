import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp (
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        appBar: AppBar(
          title: Text(
            "Dicee",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
        body: MyApp(),
      ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int leftDiceNumber = 1;
  int rightDiceNumber = 1;

void changeDiceFace(){
  setState(() {
    leftDiceNumber = Random().nextInt(6) + 1;
    rightDiceNumber = Random().nextInt(6) + 1;
  });
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              changeDiceFace();
            },
          child: Image.asset('images/dice$leftDiceNumber.png'),
          )
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              changeDiceFace();
            },
          child: Image.asset('images/dice$rightDiceNumber.png'),
          )
        ),
        ],
      )
    );
  }
}

