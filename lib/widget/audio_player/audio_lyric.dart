import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:lyrics_reader_test/models/audio_model.dart';
import 'package:provider/provider.dart';

class AudioLyric extends StatefulWidget {
  const AudioLyric({Key? key}) : super(key: key);

  @override
  State<AudioLyric> createState() => _AudioLyricState();
}

class _AudioLyricState extends State<AudioLyric> {
  @override
  Widget build(BuildContext context) {
    // 歌词阅读器
    return Consumer<AudioModel>(
      builder: (_, audio, __) {
        return Container(
          decoration: const BoxDecoration(color: Colors.black45),
          child: LyricsReader(
            model: audio.lyricsReaderModel,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            position: audio.currentPlayedPos,
            lyricUi: audio.lyricUI,
            playing: audio.isPlaying,
            size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
            emptyBuilder: () => Center(
              child: Text(
                "No lyrics",
                style: audio.lyricUI.getOtherMainTextStyle(),
              ),
            ),
            selectLineBuilder: (progress, confirm) {
              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        confirm.call();
                        setState(() {
                          audio.seek(Duration(milliseconds: progress));
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
      },
    );
  }
}
