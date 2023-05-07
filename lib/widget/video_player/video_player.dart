import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class BuildVideoPlayer extends StatefulWidget {
  const BuildVideoPlayer(this.videoPath, {Key? key}) : super(key: key);

  final String videoPath;

  @override
  State<BuildVideoPlayer> createState() => _BuildVideoPlayerState();
}

class _BuildVideoPlayerState extends State<BuildVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.videoPath),
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

  Future<ClosedCaptionFile> _loadCaptions() async {
    var files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["srt"],
    );
    final String fileContents =
        File(files?.files.single.path ?? "").readAsStringSync();
    return SubRipCaptionFile(fileContents);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  ClosedCaption(
                    text: _controller.value.caption.text,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      backgroundColor: Colors.white54,
                    ),
                  ),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
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
  void initState() {
    super.initState();
    AutoOrientation.landscapeAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    AutoOrientation.portraitAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AutoOrientation.portraitAutoMode();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(widget.controller),
                      ClosedCaption(
                        text: widget.controller.value.caption.text,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          backgroundColor: Colors.white54,
                        ),
                      ),
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
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
                    AutoOrientation.portraitAutoMode();
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
