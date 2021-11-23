import 'package:flutter/material.dart';

import 'dart:ffi';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'make_dict.dart';

const base = 'wordshk_tools';
final path = 'lib$base.dylib';
late final dylib = DynamicLibrary.open(path);
late final api = WordshkTools(dylib);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'words.hk macOS manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'words.hk macOS manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  await api.makeDict();
                },
                child: const Text('Install words.hk'),
              )
            ],
          ),
        ));
  }
}
