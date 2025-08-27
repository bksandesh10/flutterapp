import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('project_c', style: TextStyle(
            color: Colors.white
        ),),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          children: [
            Text('User detail', style: TextStyle(
              fontSize: 30 ,
            ),),

            Padding(padding: EdgeInsets.only(left: 40),
              child: Row(
                children: [
                  Text('User detail', style: TextStyle(
                    fontSize: 30 ,
                  ),),
                  SizedBox(width: 20,),
                  Text('User detail', style: TextStyle(
                    fontSize: 30 ,
                  ),),

                ],
              ),
            ),
            Image.asset('assets/image/IMG_0941.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            VideoPlayers()
          ],
        ),
      ),
    );
  }
}

class VideoPlayers extends StatefulWidget {
  const VideoPlayers({super.key});

  @override
  State<VideoPlayers> createState() => _VideoPlayersState();
}

class _VideoPlayersState extends State<VideoPlayers> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController; // make nullable until ready

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/footage1.mp4');

    // Initialize VideoPlayerController first
    _controller.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
      );
      setState(() {}); // Refresh UI after initialization
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _controller.value.isInitialized) {
      return SizedBox(
        width: MediaQuery.of(context).size.width, // fit mobile width
        height: 200, // set a fixed height to avoid overflow
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return Center(child: CircularProgressIndicator()); // show loader
    }
  }
}