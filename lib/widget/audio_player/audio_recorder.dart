import 'dart:io';

import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lyrics_reader_test/models/audio_model.dart';
import 'package:lyrics_reader_test/models/recorder_model.dart';
import 'package:provider/provider.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  @override
  Widget build(BuildContext context) {
    var audio = Provider.of<AudioModel>(context);
    return Consumer<RecorderModel>(
      builder: (_, recorder, __) {
        recorder.setRecordFilePath(
            audio.audioName ?? "", audio.currentLyricLine);
        return Column(
          children: [
            Text(recorder.recording?.status.toString() ?? ""),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    recorder.recording?.status == RecordingStatus.Recording
                        ? recorder.stop()
                        : recorder.start(
                            audio.audioName ?? "unknown",
                            audio.currentLyricLine,
                          );
                  },
                  icon: Icon(
                    Icons.mic,
                    size: 36,
                    color:
                        recorder.recording?.status == RecordingStatus.Recording
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
                if (File(recorder.recordFilePath ?? "").existsSync())
                  IconButton(
                    onPressed: () {
                      AudioPlayer().play(
                          DeviceFileSource(recorder.recordFilePath ?? ""));
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
