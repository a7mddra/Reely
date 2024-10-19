import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/widgets/player.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';
import 'package:shorts_a7md/utils/utils.dart';

class ProfileVideo extends StatefulWidget {
  final index, myImage, myName, videos;

  const ProfileVideo({
    super.key,
    required this.index,
    required this.myImage,
    required this.myName,
    required this.videos,
  });

  @override
  State<ProfileVideo> createState() => _ProfileVideoState();
}

class _ProfileVideoState extends State<ProfileVideo> {
  late PageController _pageController;
  Map<String, Map<String, dynamic>> videoDataCache = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _loadInitialVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> getVideo(String postId) async {
    if (videoDataCache.containsKey(postId)) {
      return;
    }
    try {
      DocumentSnapshot videoSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      Map<String, dynamic> fetchedVideo =
          videoSnap.data() as Map<String, dynamic>;

      setState(() {
        videoDataCache[postId] = fetchedVideo;
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _loadInitialVideos() async {
    setState(() {
      isLoading = true;
    });

    await getVideo(widget.videos[widget.index]['postId']);
    if (widget.index + 1 < widget.videos.length) {
      await getVideo(widget.videos[widget.index + 1]['postId']);
    }
    if (widget.index - 1 >= 0) {
      await getVideo(widget.videos[widget.index - 1]['postId']);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (index) async {
          if (index + 1 < widget.videos.length) {
            await getVideo(widget.videos[index + 1]['postId']);
          }
          if (index - 1 >= 0) {
            await getVideo(widget.videos[index - 1]['postId']);
          }
        },
        itemBuilder: (context, index) {
          final postId = widget.videos[index]['postId'];

          if (!videoDataCache.containsKey(postId)) {
            return Loading(
              isLoading: true,
              loadedContent: reelLoading(),
              loadingContent: reelLoading(),
            );
          }

          final videoData = videoDataCache[postId];

          return Stack(
            fit: StackFit.expand,
            children: [
              Player(
                photoUrl: videoData!['profImage'],
                username: videoData['username'],
                postUrl: videoData['postUrl'],
                myImage: widget.myImage,
                myName: widget.myName,
                uid: videoData['uid'],
                postId: videoData['postId'],
                description: videoData['description'],
                date: videoData['datePublished'],
                likes: videoData['likes'],
              ),
              Positioned(
                top: 30,
                left: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
