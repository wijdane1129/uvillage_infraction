import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaViewer extends StatefulWidget {
  final String url;
  final bool isVideo;

  const MediaViewer({Key? key, required this.url, this.isVideo = false})
    : super(key: key);

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializing = true;
      _videoController = VideoPlayerController.network(widget.url)
        ..initialize()
            .then((_) {
              _chewieController = ChewieController(
                videoPlayerController: _videoController!,
                autoPlay: true,
                looping: false,
                allowMuting: true,
                allowPlaybackSpeedChanging: true,
              );
              setState(() {
                _initializing = false;
              });
            })
            .catchError((e) {
              // ignore errors, show fallback
              setState(() {
                _initializing = false;
              });
            });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child:
            widget.isVideo
                ? _buildVideo()
                : InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.contain,
                    placeholder: (c, u) => const CircularProgressIndicator(),
                    errorWidget:
                        (c, u, e) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_initializing) {
      return const CircularProgressIndicator();
    }
    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }
    return const Icon(Icons.broken_image, color: Colors.white);
  }
}
