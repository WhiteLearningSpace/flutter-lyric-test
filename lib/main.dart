import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: MyApp(),
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
  AudioPlayer? audioPlayer;
  double sliderCurrentPos = 0;
  double maxValue = 1;

  bool isPlaying = false;
  bool isTap = false;

  final LyricsModelBuilder lyricsModelBuilder = LyricsModelBuilder.create();
  LyricsReaderModel? lyricsReaderModel;
  var lyricUI = UINetease();

  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }

  @override
  void initState() {
    super.initState();
    getLyric();
  }

  void getLyric() async {
    var str = await rootBundle.loadString("assets/last_night/last_night.lrc");
    lyricsModelBuilder.bindLyricToMain(str);
    lyricsReaderModel = lyricsModelBuilder.getModel();
    refreshLyric();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildLyricReader(),
          Text(
            "${Duration(milliseconds: sliderCurrentPos.toInt())}"
            "/${Duration(milliseconds: maxValue.toInt())}",
          ),
          ...buildPlayer(),
          ...buildPlayerControl(),
        ],
      ),
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
                    LyricsLog.logD("点击事件");
                    confirm.call();
                    setState(() {
                      audioPlayer?.seek(Duration(milliseconds: progress));
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

  // 音频播放器
  List<Widget> buildPlayer() {
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
            audioPlayer?.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      IconButton(
        onPressed: () async {
          if (audioPlayer == null) {
            audioPlayer = AudioPlayer()
              ..play(AssetSource("last_night/last_night.mp3"));
            setState(() {
              isPlaying = true;
            });
            audioPlayer?.setReleaseMode(ReleaseMode.loop);
            audioPlayer?.onDurationChanged.listen((event) {
              setState(() {
                maxValue = event.inMilliseconds.toDouble();
              });
            });
            audioPlayer?.onPositionChanged.listen((event) {
              if (isTap) return;
              setState(() {
                sliderCurrentPos = event.inMilliseconds.toDouble();
              });
            });
            audioPlayer?.onPlayerStateChanged.listen((state) {
              setState(() {
                isPlaying = state == PlayerState.playing;
              });
            });
          } else {
            isPlaying ? audioPlayer?.pause() : audioPlayer?.resume();
            setState(() {
              isPlaying = !isPlaying;
            });
          }
        },
        icon:
            !isPlaying ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
      ),
    ];
  }

  // 音频控制器
  List<Widget> buildPlayerControl() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              audioPlayer?.setPlaybackRate(0.5);
            },
            child: const Text("0.5x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer?.setPlaybackRate(1.0);
            },
            child: const Text("1x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer?.setPlaybackRate(2.0);
            },
            child: const Text("2.0x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer?.setPlaybackRate(2.5);
            },
            child: const Text("2.5x"),
          ),
          ElevatedButton(
            onPressed: () {
              audioPlayer?.setPlaybackRate(3.0);
            },
            child: const Text("3.0x"),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              var line =
                  lyricsReaderModel?.getCurrentLine(sliderCurrentPos.toInt());
              var startTime = lyricsReaderModel?.lyrics[line - 1].startTime;
              if (startTime is int) {
                audioPlayer?.seek(Duration(milliseconds: startTime));
              }
            },
            icon: const Icon(Icons.keyboard_arrow_left),
          ),
          IconButton(
            onPressed: () {
              var line =
                  lyricsReaderModel?.getCurrentLine(sliderCurrentPos.toInt());
              var startTime = lyricsReaderModel?.lyrics[line + 1].startTime;
              if (startTime is int) {
                audioPlayer?.seek(Duration(milliseconds: startTime));
              }
            },
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ],
      )
    ];
  }
}
