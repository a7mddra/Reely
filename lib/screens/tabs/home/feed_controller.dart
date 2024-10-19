import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shorts_a7md/screens/tabs/home/reel.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';

class FeedController extends StatefulWidget {
  final username, photoUrl, isTabVisible, hasData;

  const FeedController({
    super.key,
    required this.username,
    required this.photoUrl,
    required this.isTabVisible,
    required this.hasData,
  });

  @override
  _FeedControllerState createState() => _FeedControllerState();
}

class _FeedControllerState extends State<FeedController> {
  PageController verticalController = PageController();
  bool canScrollVertically = true;
  bool isLoading = true;
  String myName = '';
  String myImage = '';
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    if (widget.hasData) {
      myName = widget.username;
      myImage = widget.photoUrl;
    }
    getVideos();
  }

  Future<void> getVideos() async {
    try {
      var videoSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('datePublished', descending: true)
          .get();

      List<Map<String, dynamic>> fetchedVideos = [];

      for (var doc in videoSnap.docs) {
        fetchedVideos.add(doc.data());
      }

      if (mounted) {
        setState(() {
          videos = fetchedVideos;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Loading(
          isLoading: isLoading,
          loadingContent: reelLoading(),
          loadedContent: PageView.builder(
            controller: verticalController,
            scrollDirection: Axis.vertical,
            physics: canScrollVertically
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var reelData = videos[index];

              return Reel(
                index: index,
                onPageChanged: (int pageIndex) {
                  setState(() {
                    canScrollVertically = pageIndex == 0;
                  });
                },
                photoUrl: reelData['profImage'],
                username: reelData['username'],
                postUrl: reelData['postUrl'],
                myImage: widget.photoUrl,
                myName: widget.username,
                postId: reelData['postId'],
                description: reelData['description'],
                date: reelData['datePublished'],
                likes: reelData['likes'],
                uid: reelData['uid'],
              );
            },
          ),
        ));
  }
}
