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
String appDirPath = "";

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
                              installDict();
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
  final appDir = await getApplicationDocumentsDirectory();
  appDirPath = appDir.path;
  return await api.makeDict(outputDir: appDirPath);
}

Future<void> installDict() async {
  final dictDevKitDir = appDirPath + '/dict_dev_kit/';
  // Needs to download Dictionary Development Kit first
  if (!await Directory(dictDevKitDir).exists()) {
    const dictDevKitUrl =
        'https://sourceforge.net/projects/wordshk-apple/files/dict_dev_kit.tar.gz/download';
    var req = await http.Client().get(Uri.parse(dictDevKitUrl));
    final dictDevKit =
        TarDecoder().decodeBytes(GZipDecoder().decodeBytes(req.bodyBytes));
    for (final file in dictDevKit) {
      final filename = file.name;
      if (file.isFile) {
        print('Decompressing to ' + filename + '...');
        final data = file.content as List<int>;
        File(dictDevKitDir + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        print('Decompressing to ' + filename + '/ ...');
        Directory(dictDevKitDir + filename).create(recursive: true);
      }
    }
  }
  print('Loaded Dictionary Development Kit');
  await Process.run('make', [], workingDirectory: appDirPath);
  await Process.run('make', ['install'], workingDirectory: appDirPath);
  print('Installed dictionary to ~/Library/Dictionaries');
}
