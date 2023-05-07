import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

class AudioModel extends ChangeNotifier {
  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 当前播放位置
  int currentPlayedPos = 0;

  /// 音频持续时间
  int audioDuration = 1;

  /// 是否在播放中
  bool isPlaying = false;

  /// 当前歌词的是否暂停的定时器
  Timer? timer;

  /// 歌词阅读器
  LyricsReaderModel? lyricsReaderModel;

  /// 歌词UI
  var lyricUI = UINetease();

  /// GET
  int get currentLyricLine =>
      lyricsReaderModel?.getCurrentLine(currentPlayedPos) ?? 0;

  /// 音频名称
  String? audioName;

  /// 初始化
  void init(String audioPath) {
    _audioPlayer
      ..setReleaseMode(ReleaseMode.loop)
      ..onDurationChanged.listen((event) {
        audioDuration = event.inMilliseconds;
        notifyListeners();
      })
      ..onPositionChanged.listen((event) {
        currentPlayedPos = event.inMilliseconds;
        notifyListeners();
      })
      ..onPlayerStateChanged.listen((state) {
        isPlaying = state == PlayerState.playing;
        notifyListeners();
      });
    _getAudio(audioPath);
    _getLyric();
  }

  /// 获取音频路径
  Future<void> _getAudio(String audioPath) async {
    audioName = audioPath.split("/").last;
    await _audioPlayer.setSourceDeviceFile(audioPath);
    var duration = await _audioPlayer.getDuration();
    audioDuration = duration?.inMilliseconds ?? 1;
    notifyListeners();
  }

  /// 获取歌词
  Future<void> _getLyric() async {
    var files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["lrc"],
    );
    File file = File(files?.files.single.path ?? "");

    // File file = File(
    //     "/data/user/0/com.example.lyrics_reader_test/cache/file_picker/last_night.lrc");

    log("歌词文件的路径$file");

    var str = file.readAsStringSync();
    LyricsModelBuilder lyricsModelBuilder = LyricsModelBuilder.create()
      ..bindLyricToMain(str);
    lyricsReaderModel = lyricsModelBuilder.getModel();
    lyricUI = UINetease.clone(lyricUI);
    notifyListeners();
  }

  /// 播放音频
  Future<void> play({int? line}) async {
    timer?.cancel();

    var lyric = lyricsReaderModel?.lyrics[line ?? currentLyricLine];
    int startTime = lyric?.startTime ?? 0;
    int endTime = lyric?.endTime ?? 0;

    seek(Duration(milliseconds: startTime));
    await _audioPlayer.resume();
    timer = Timer(Duration(milliseconds: endTime - startTime), () async {
      await _audioPlayer.pause();
    });
  }

  /// 暂停音频
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 根据歌词控制音频上一句下一句
  void controlLyric({required ControlPlayedLine control}) {
    int line = currentLyricLine;
    var lyricLength = lyricsReaderModel?.lyrics.length ?? 0;
    switch (control) {
      case ControlPlayedLine.pre:
        line--;
        break;
      case ControlPlayedLine.current:
        line;
        break;
      case ControlPlayedLine.next:
        line++;
        break;
    }

    if (line < 0 || line > lyricLength) {
      log("不能超出歌词长度");
      return;
    }

    play(line: line);
  }

  /// 设置播放速度
  Future<void> setPlaybackRate(double playbackRate) async {
    await _audioPlayer.setPlaybackRate(playbackRate);
  }
}

enum ControlPlayedLine {
  pre,
  current,
  next,
}
