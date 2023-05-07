import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lyrics_reader_test/widget/audio_player/audio_player.dart';
import 'package:lyrics_reader_test/widget/video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("test"),
        ),
        body: const MyApp(),
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
  String? fileType;
  FilePickerResult? files;

  Future<void> getFile() async {
    files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["mp3", "mp4"],
    );

    setState(() {
      fileType = files?.files.single.extension;
    });
    log("音频文件的路径${files?.files.single.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(onPressed: getFile, child: const Text("选择MP3或MP4文件")),
          if (fileType == "mp3") MyAudioPlayer(files?.files.single.path ?? ""),
          if (fileType == "mp4")
            BuildVideoPlayer(files?.files.single.path ?? ""),
        ],
      ),
    );
  }
}
