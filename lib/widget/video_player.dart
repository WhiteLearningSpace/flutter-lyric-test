import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class BuildVideoPlayer extends StatefulWidget {
  const BuildVideoPlayer({Key? key}) : super(key: key);

  @override
  State<BuildVideoPlayer> createState() => _BuildVideoPlayerState();
}

class _BuildVideoPlayerState extends State<BuildVideoPlayer> {
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
