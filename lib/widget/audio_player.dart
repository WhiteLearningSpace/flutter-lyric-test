import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

class BuildAudioPlayer extends StatefulWidget {
  const BuildAudioPlayer(this.audioPath, {Key? key}) : super(key: key);

  final String audioPath;

  @override
  State<BuildAudioPlayer> createState() => _BuildAudioPlayerState();
}

class _BuildAudioPlayerState extends State<BuildAudioPlayer> {
  AudioPlayer audioPlayer = AudioPlayer();
  double sliderCurrentPos = 0;
  double maxValue = 1;

  bool isPlaying = false;
  bool isTap = false;

  // AnotherAudioRecorder? _recorder;
  // Recording? _current;
  // RecordingStatus _currentStatus = RecordingStatus.Unset;

  final LyricsModelBuilder lyricsModelBuilder = LyricsModelBuilder.create();
  LyricsReaderModel? lyricsReaderModel;
  var lyricUI = UINetease();

  // 刷新歌词UI
  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }

  // 控制歌词的上一句下一句
  void controlLyric(bool isNext) {
    int line = lyricsReaderModel?.getCurrentLine(sliderCurrentPos.toInt());
    isNext ? line++ : line--;
    var startTime = lyricsReaderModel?.lyrics[line].startTime;
    if (startTime is int) {
      audioPlayer.seek(Duration(milliseconds: startTime));
    }
  }

  void setAudioSource() async {
    await audioPlayer.setSourceDeviceFile(widget.audioPath);
    var duration = await audioPlayer.getDuration();
    setState(() {
      maxValue = duration?.inMilliseconds.toDouble() ?? 1;
    });
  }

  // 获取歌词
  Future<void> getLyric() async {
    var files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["lrc"],
    );
    File file = File(files?.files.single.path ?? "");
    var str = file.readAsStringSync();
    lyricsModelBuilder.bindLyricToMain(str);

    setState(() {
      lyricsReaderModel = lyricsModelBuilder.getModel();
    });
    refreshLyric();
  }

  // 初始化音频播放器
  void initAudioPlayer() {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        maxValue = event.inMilliseconds.toDouble();
      });
    });
    audioPlayer.onPositionChanged.listen((event) {
      if (isTap) return;
      setState(() {
        sliderCurrentPos = event.inMilliseconds.toDouble();
      });
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  void initRecorder() async {}

  @override
  void initState() {
    super.initState();
    setAudioSource();
    getLyric();
    initAudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildLyricReader(),
        Text(
          "${Duration(milliseconds: sliderCurrentPos.toInt())}"
          "/${Duration(milliseconds: maxValue.toInt())}",
        ),
        buildRecorder(),
        ...buildPlayerControl(),
      ],
    );
  }

  // 歌词阅读器
  Widget buildLyricReader() {
    return Container(
      decoration: const BoxDecoration(color: Colors.black45),
      child: LyricsReader(
        model: lyricsReaderModel,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        position: sliderCurrentPos.toInt(),
        lyricUi: lyricUI,
        playing: isPlaying,
        size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
        emptyBuilder: () => Center(
          child: Text(
            "No lyrics",
            style: lyricUI.getOtherMainTextStyle(),
          ),
        ),
        selectLineBuilder: (progress, confirm) {
          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    confirm.call();
                    setState(() {
                      audioPlayer.seek(Duration(milliseconds: progress));
                    });
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.green)),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(color: Colors.green),
                  height: 1,
                  width: double.infinity,
                ),
              ),
              Text(
                progress.toString(),
                style: const TextStyle(color: Colors.green),
              )
            ],
          );
        },
      ),
    );
  }

  // 音频控制器
  List<Widget> buildPlayerControl() {
    return [
      if (sliderCurrentPos < maxValue)
        Slider(
          min: 0,
          max: maxValue,
          value: sliderCurrentPos,
          onChanged: (value) {
            setState(() {
              sliderCurrentPos = value;
            });
          },
          onChangeStart: (value) {
            isTap = true;
          },
          onChangeEnd: (value) {
            isTap = false;
            setState(() {
              sliderCurrentPos = value;
            });
            audioPlayer.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => controlLyric(false),
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          IconButton(
            onPressed: () {
              isPlaying ? audioPlayer.pause() : audioPlayer.resume();
              setState(() {
                isPlaying = !isPlaying;
              });
            },
            icon: !isPlaying
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
          ),
          IconButton(
            onPressed: () => controlLyric(true),
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(0.5);
            },
            child: const Text("0.5x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(1.0);
            },
            child: const Text("1x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(2.0);
            },
            child: const Text("2.0x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(2.5);
            },
            child: const Text("2.5x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer.setPlaybackRate(3.0);
            },
            child: const Text("3.0x"),
          ),
        ],
      ),
    ];
  }

  // 录音功能
  Widget buildRecorder() {
    return IconButton(onPressed: () {}, icon: const Icon(Icons.mic));
  }
}
