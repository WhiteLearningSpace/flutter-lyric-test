import 'dart:io';

import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AnotherAudioRecorder? _audioRecorder;
  Recording? _recording;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTapDown: (e) {
                _start();
              },
              onTapCancel: () {
                _stop();
              },
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic),
                color: _recording?.status == RecordingStatus.Recording
                    ? Colors.blue
                    : Colors.grey,
                iconSize: 64,
              ),
            ),
            Text("status: ${_recording?.status}"),
          ],
        ),
      ),
    );
  }

  void _init() async {
    // 申请和判断权限
    if (await AnotherAudioRecorder.hasPermissions) {
      // 自定义文件保存路径
      String customPath;

      //
      Directory appStorageDir;
      if (Platform.isIOS) {
        appStorageDir = await getApplicationDocumentsDirectory();
      } else {
        appStorageDir = (await getExternalStorageDirectory())!;
      }

      customPath =
          "${appStorageDir.path}/${DateTime.now().millisecondsSinceEpoch}";

      _audioRecorder =
          AnotherAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

      await _audioRecorder?.initialized;

      var current = await _audioRecorder?.current();

      setState(() {
        _recording = current;
      });
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("无录音权限"),
          ),
        );
      }
    }
  }

  void _start() async {
    await _audioRecorder?.start();

    var current = await _audioRecorder?.current();
    setState(() {
      _recording = current;
    });
  }

  void _stop() async {
    var current = await _audioRecorder?.stop();

    setState(() {
      _recording = current;
    });

    _init();
  }
}
