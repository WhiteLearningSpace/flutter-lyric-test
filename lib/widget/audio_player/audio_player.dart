
import 'package:flutter/material.dart';
import 'package:lyrics_reader_test/models/recorder_model.dart';
import 'package:lyrics_reader_test/widget/audio_player/audio_lyric.dart';
import 'package:lyrics_reader_test/widget/audio_player/audio_player_controller.dart';
import 'package:lyrics_reader_test/widget/audio_player/audio_recorder.dart';
import 'package:provider/provider.dart';

import 'package:lyrics_reader_test/models/audio_model.dart';
import 'package:provider/single_child_widget.dart';

class MyAudioPlayer extends StatefulWidget {
  const MyAudioPlayer(this.audioPath, {Key? key}) : super(key: key);
  final String audioPath;

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider(
            create: (_) => AudioModel()..init(widget.audioPath)),
        ChangeNotifierProvider(create: (_) => RecorderModel()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          // 歌词阅读器
          AudioLyric(),
          // 录音器
          AudioRecorder(),
          // 播放控制器
          AudioPlayerController(),
        ],
      ),
    );
  }
}
