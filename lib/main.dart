import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("test"),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.audiotrack),
                ),
                Tab(
                  icon: Icon(Icons.video_call),
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MyAudioPlayer(),
              MyVideoPlayer(),
            ],
          ),
        ),
      ),
    ),
  );
}

class MyAudioPlayer extends StatefulWidget {
  const MyAudioPlayer({Key? key}) : super(key: key);

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    var str = await DefaultAssetBundle.of(context)
        .loadString("assets/last_night.lrc");
    lyricsModelBuilder.bindLyricToMain(str);
    lyricsReaderModel = lyricsModelBuilder.getModel();
    refreshLyric();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
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
            onPressed: () async {
              if (audioPlayer == null) {
                audioPlayer = AudioPlayer()
                  ..play(AssetSource("last_night.mp3"));
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
            icon: !isPlaying
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
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
    ];
  }
}

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({Key? key}) : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late VideoPlayerController _controller;

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.srt');
    return SubRipCaptionFile(fileContents);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      "assets/Butterfly-209.mp4",
      closedCaptionFile: _loadCaptions(),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_controller),
                  ClosedCaption(
                    text: _controller.value.caption.text,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      backgroundColor: Colors.white54,
                    ),
                  ),
                ],
              ),
            )
          : Container(),
      IconButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        icon: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeLeft],
            );
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            return MyVideoFullPage(_controller);
          }));
        },
        icon: const Icon(Icons.fullscreen),
      )
    ]);
  }
}

class MyVideoFullPage extends StatefulWidget {
  const MyVideoFullPage(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController controller;

  @override
  State<MyVideoFullPage> createState() => _MyVideoFullPageState();
}

class _MyVideoFullPageState extends State<MyVideoFullPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(widget.controller),
                  ClosedCaption(
                    text: widget.controller.value.caption.text,
                    // textStyle: const TextStyle(
                    //   fontSize: 20,
                    //   backgroundColor: Colors.white54,
                    // ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
                SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.portraitUp],
                );
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              },
            ),
          )
        ],
      ),
    );
  }
}
