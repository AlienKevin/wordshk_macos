import 'package:flutter/material.dart';

import 'dart:ffi';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:sum_types/sum_types.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'dart:typed_data';

import 'make_dict.dart';

const base = 'wordshk_tools';
const path = 'lib$base.dylib';
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

enum InstallStatus {
  notInstalled,
  installing,
  installed,
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InstallStatus _installStatus = InstallStatus.notInstalled;

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
              () {
                switch (_installStatus) {
                  case InstallStatus.notInstalled:
                    return TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _installStatus = InstallStatus.installing;
                        });
                        createDict().then((_) => setState(() {
                              _installStatus = InstallStatus.installed;
                            }));
                      },
                      child: const Text('🚀 Install words.hk'),
                    );
                  case InstallStatus.installing:
                    return const Text(
                      '🛠 Installing words.hk ...',
                      textAlign: TextAlign.center,
                    );
                  case InstallStatus.installed:
                    return const Text(
                      '✅ Installed words.hk',
                      textAlign: TextAlign.center,
                    );
                }
              }()
            ],
          ),
        ));
  }
}

Future<int> createDict() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  return await api.makeDict(outputDir: appDocPath);
}

