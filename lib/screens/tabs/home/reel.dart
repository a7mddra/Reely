import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/screens/tabs/home/profile.dart';
import 'package:shorts_a7md/widgets/player.dart';

class Reel extends StatefulWidget {
  final index,
      onPageChanged,
      postId,
      photoUrl,
      postUrl,
      username,
      myImage,
      myName,
      uid,
      description,
      date,
      likes;

  Reel({
    Key? key,
    required this.index,
    required this.onPageChanged,
    required this.postId,
    required this.photoUrl,
    required this.postUrl,
    required this.username,
    required this.myImage,
    required this.myName,
    required this.description,
    required this.date,
    required this.likes,
    required this.uid,
  }) : super(key: key);

  @override
  _ReelState createState() => _ReelState();
}

class _ReelState extends State<Reel> {
  PageController horizontalController = PageController();

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserViewingOwnVideo =
        widget.uid == FirebaseAuth.instance.currentUser!.uid;

    return PageView(
      controller: horizontalController,
      scrollDirection: Axis.horizontal,
      onPageChanged: widget.onPageChanged,
      physics: isCurrentUserViewingOwnVideo
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [
        Player(
          photoUrl: widget.photoUrl,
          username: widget.username,
          postUrl: widget.postUrl,
          uid: widget.uid,
          myImage: widget.myImage,
          myName: widget.myName,
          postId: widget.postId,
          description: widget.description,
          date: widget.date,
          likes: widget.likes,
        ),
        if (!isCurrentUserViewingOwnVideo)
          Profile(
            uid: widget.uid,
          ),
      ],
    );
  }
}
