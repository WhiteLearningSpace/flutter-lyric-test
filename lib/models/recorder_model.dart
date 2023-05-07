import 'dart:developer';
import 'dart:io';

import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class RecorderModel extends ChangeNotifier {
  /// 录音机
  AnotherAudioRecorder? _audioRecorder;

  /// 录音状态
  Recording? recording;

  /// 录音文件路径
  String? recordFilePath;

  Future<void> setRecordFilePath(String audioName, int currentLyricLine) async {
    Directory appStorageDir;
    if (Platform.isIOS) {
      appStorageDir = await getApplicationDocumentsDirectory();
    } else {
      appStorageDir = (await getExternalStorageDirectory())!;
    }

    recordFilePath = "${appStorageDir.path}/${audioName}_$currentLyricLine.wav";
  }

  Future<void> _initRecorder(String audioName, int currentLyricLine) async {
    // 申请和判断权限
    if (await AnotherAudioRecorder.hasPermissions) {
      await setRecordFilePath(audioName, currentLyricLine);

      var file = File(recordFilePath ?? "");
      if (file.existsSync()) file.deleteSync();

      log("录音文件保存在$recordFilePath");

      _audioRecorder = AnotherAudioRecorder(recordFilePath ?? "",
          audioFormat: AudioFormat.WAV);

      await _audioRecorder?.initialized;
    } else {
      log("没有录音权限");
    }
  }

  /// 开始录音
  Future<void> start(String audioName, int currentLyricLine) async {
    await _initRecorder(audioName, currentLyricLine);
    await _audioRecorder?.start();

    var current = await _audioRecorder?.current();
    recording = current;
    notifyListeners();
  }

  /// 停止录音
  Future<void> stop() async {
    var current = await _audioRecorder?.stop();

    recording = current;
    notifyListeners();
  }
}
