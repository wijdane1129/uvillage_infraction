// lib/screens/media_player_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class MediaPlayerScreen extends StatefulWidget {
  final String filePath;
  final String mediaType;

  const MediaPlayerScreen({
    Key? key,
    required this.filePath,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.mediaType == 'VIDEO') {
      _videoController = VideoPlayerController.file(File(widget.filePath));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );
      setState(() {});
    } else if (widget.mediaType == 'AUDIO') {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setSourceDeviceFile(widget.filePath);
      await _audioPlayer!.resume();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.mediaType == 'VIDEO' ? 'Lecture vidéo' : 'Lecture audio',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child:
            widget.mediaType == 'VIDEO'
                ? _buildVideoPlayer()
                : _buildAudioPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController == null) {
      return const CircularProgressIndicator();
    }
    return Chewie(controller: _chewieController!);
  }

  Widget _buildAudioPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.audiotrack, color: Colors.cyan, size: 120),
        const SizedBox(height: 40),
        Text(
          widget.filePath.split('/').last,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                if (_isPlaying) {
                  await _audioPlayer?.pause();
                } else {
                  await _audioPlayer?.resume();
                }
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              icon: Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 64,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () async {
                await _audioPlayer?.stop();
                setState(() {
                  _isPlaying = false;
                });
              },
              icon: const Icon(Icons.stop_circle, size: 64, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
