import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/resources/firestore_methods.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:shorts_a7md/widgets/like_animation.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String postId;
  final List<String> likes;
  final Function(List<String>) onLikeChanged;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    required this.postId,
    required this.likes,
    required this.onLikeChanged,
  });

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool _areOptionsVisible = false;
  bool isLikeAnimating = false;
  Timer? _optionsTimer;

  void _toggleOptionsVisibility() {
    setState(() {
      _areOptionsVisible = !_areOptionsVisible;
    });

    if (_areOptionsVisible) {
      _optionsTimer?.cancel();
      _optionsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _areOptionsVisible = false;
          });
        }
      });
    } else {
      _optionsTimer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.setLooping(true);
    widget.controller.play();
    isMuted.addListener(() {
      if (mounted) {
        setState(() {
          widget.controller.setVolume(isMuted.value ? 0 : 1);
        });
      }
    });
    widget.controller.setVolume(isMuted.value ? 0 : 1);
  }

  @override
  void dispose() {
    _optionsTimer?.cancel();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _toggleOptionsVisibility,
          onDoubleTap: () {
            setState(() {
              isLikeAnimating = true;
              if (!widget.likes.contains(uid)) {
                widget.likes.add(uid);
                widget.onLikeChanged(widget.likes);
              }
            });
            FireStoreMethods()
                .likePost(widget.postId, uid, widget.likes, false);
          },
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(widget.controller),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 125,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 10,
          right: 10,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isMuted.value ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: () {
                      setState(() {
                        isMuted.value = !isMuted.value;
                        widget.controller.setVolume(isMuted.value ? 0 : 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              VideoProgressIndicator(
                widget.controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.grey,
                  backgroundColor: Color.fromARGB(255, 44, 44, 44),
                ),
              ),
            ],
          ),
        ),
        if (_areOptionsVisible)
          Center(
            child: GestureDetector(
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: const Color.fromARGB(183, 255, 255, 255),
                size: 50,
              ),
              onTap: () {
                setState(() {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                });
              },
            ),
          ),
      ],
    );
  }
}
