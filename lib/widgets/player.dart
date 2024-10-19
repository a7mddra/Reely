import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:shorts_a7md/resources/firestore_methods.dart';
import 'package:shorts_a7md/widgets/comments.dart';
import 'package:shorts_a7md/widgets/custom_video_player.dart';
import 'package:shorts_a7md/widgets/like_animation.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';
import 'package:video_player/video_player.dart';

class Player extends StatefulWidget {
  final photoUrl,
      postUrl,
      username,
      myImage,
      myName,
      postId,
      uid,
      description,
      date,
      likes;

  const Player({
    super.key,
    required this.photoUrl,
    required this.postUrl,
    required this.uid,
    required this.username,
    required this.myImage,
    required this.myName,
    required this.postId,
    required this.description,
    required this.date,
    required this.likes,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late List<String> _likes;
  VideoPlayerController? _videoController;
  bool hasError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _likes = List<String>.from(widget.likes);
    _loadVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _handleLikeChanged(List<String> updatedLikes) {
    setState(() {
      _likes = updatedLikes;
    });
  }

  Future<void> _loadVideo() async {
    try {
      final fileInfo = await _checkCacheFor(widget.postUrl);
      if (fileInfo == null) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(widget.postUrl));
        await _videoController!.initialize();
        await _cacheForUrl(widget.postUrl);
      } else {
        final file = fileInfo.file;
        _videoController = VideoPlayerController.file(file);
        await _videoController!.initialize();
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  Future<FileInfo?> _checkCacheFor(String url) async {
    return await DefaultCacheManager().getFileFromCache(url);
  }

  Future<void> _cacheForUrl(String url) async {
    await DefaultCacheManager().getSingleFile(url);
  }

  @override
  Widget build(BuildContext context) {
    String postId = widget.postId;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String cnt = '0';
    return Loading(
      isLoading: isLoading,
      loadingContent: reelLoading(),
      loadedContent: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_videoController != null)
              CustomVideoPlayer(
                likes: _likes,
                onLikeChanged: _handleLikeChanged,
                postId: postId,
                controller: _videoController!,
              ),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 2, top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LikeAnimation(
                        isAnimating: _likes.contains(uid),
                        smallLike: true,
                        child: IconButton(
                          icon: _likes.contains(uid)
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : const Icon(Icons.favorite_border, size: 30),
                          onPressed: () {
                            setState(() {
                              if (_likes.contains(uid)) {
                                _likes.remove(uid);
                              } else {
                                _likes.add(uid);
                              }
                            });
                            FireStoreMethods()
                                .likePost(postId, uid, _likes, true);
                          },
                        ),
                      ),
                      Text(_likes.length.toString()),
                      const SizedBox(height: 15),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          size: 30,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Comments(
                                    postId: postId,
                                    username: widget.myName,
                                    imageUrl: widget.myImage,
                                  ));
                        },
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('comments')
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(cnt);
                            }
                            cnt = snapshot.data!.docs.length.toString();
                            return Text(cnt);
                          }),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color.fromARGB(255, 20, 20, 20),
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              widget.photoUrl),
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.username,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontFamily: 'be',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            DateFormat.yMMMd()
                                                .format(widget.date.toDate()),
                                            style: const TextStyle(
                                                fontFamily: 'be')),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(widget.description,
                                    style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
