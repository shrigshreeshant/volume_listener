import 'package:flutter/material.dart';
import 'dart:async';

import 'package:volume_listener/volume_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VolumeKey? lastKey;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    VolumeListener.addListener((VolumeKey event) {
      setState(() {
        lastKey = event;
      });
    });
  }

  @override
  void dispose() {
    VolumeListener.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Last key:  $lastKey\n'),
        ),
      ),
    );
  }
}
