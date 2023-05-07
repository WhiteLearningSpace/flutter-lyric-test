import 'package:flutter/material.dart';
import 'package:lyrics_reader_test/models/audio_model.dart';
import 'package:provider/provider.dart';

class AudioPlayerController extends StatefulWidget {
  const AudioPlayerController({Key? key}) : super(key: key);

  @override
  State<AudioPlayerController> createState() => _AudioPlayerControllerState();
}

class _AudioPlayerControllerState extends State<AudioPlayerController> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioModel>(
      builder: (_, audio, __) {
        return Column(
          children: [
            // 歌曲信息
            Text("第${audio.currentLyricLine}行"),
            Text(
              "${Duration(milliseconds: audio.currentPlayedPos)}"
              "/${Duration(milliseconds: audio.audioDuration)}",
            ),
            // 控制音频播放
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () =>
                      audio.controlLyric(control: ControlPlayedLine.pre),
                  icon: const Icon(Icons.keyboard_arrow_left),
                ),
                IconButton(
                  onPressed: () {
                    audio.isPlaying ? audio.pause() : audio.play();
                  },
                  icon: !audio.isPlaying
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                ),
                IconButton(
                  onPressed: () =>
                      audio.controlLyric(control: ControlPlayedLine.next),
                  icon: const Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
            // 控制播放速度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(0.5);
                  },
                  child: const Text("0.5x"),
                ),
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(0.25);
                  },
                  child: const Text("0.25x"),
                ),
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(1.0);
                  },
                  child: const Text("1x"),
                ),
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(2.0);
                  },
                  child: const Text("2.0x"),
                ),
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(2.5);
                  },
                  child: const Text("2.5x"),
                ),
                TextButton(
                  onPressed: () {
                    audio.setPlaybackRate(3.0);
                  },
                  child: const Text("3.0x"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
