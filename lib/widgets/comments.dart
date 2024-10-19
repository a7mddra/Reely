import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shorts_a7md/resources/firestore_methods.dart';
import 'package:shorts_a7md/widgets/comment_card.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String username;
  final String imageUrl;

  const Comments({
    super.key,
    required this.postId,
    required this.username,
    required this.imageUrl,
  });

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController commentController = TextEditingController();
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> postComment(
      String postId, String uid, String name, String profilePic) async {
    setState(() {
      isPosting = true;
    });

    try {
      String res = await FireStoreMethods().postComment(
        postId,
        commentController.text,
        uid,
        name,
        profilePic,
      );

      setState(() {
        isPosting = false;
      });

      if (res == 'success') {
        commentController.clear();
      } else {
        debugPrint('Error posting comment: $res');
      }
    } catch (err) {
      debugPrint('Error posting comment: $err');
      setState(() {
        isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.7,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 32, 32, 32),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 4,
                  width: 38,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                height: 1.5,
                width: double.infinity,
                color: Colors.grey,
              ),
              Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('datePublished', descending: true)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loading(
                            isLoading: true,
                            loadingContent: ListView.builder(
                              controller: controller,
                              itemCount: 8,
                              itemBuilder: (context, index) {
                                return const ShimmerCommentCard();
                              },
                            ),
                            loadedContent: ListView.builder(
                              controller: controller,
                              itemCount: 8,
                              itemBuilder: (context, index) {
                                return const ShimmerCommentCard();
                              },
                            ),
                          );
                        }
                        return ListView.builder(
                            controller: controller,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var commentData = snapshot.data!.docs[index];
                              return CommentCard(
                                profilePicUrl: commentData['profilePic'],
                                username: commentData['name'],
                                comment: commentData['text'],
                                date: DateFormat.yMMMd().format(
                                  commentData['datePublished'].toDate(),
                                ),
                              );
                            });
                      })),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    color: const Color.fromARGB(255, 32, 32, 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                CachedNetworkImageProvider(widget.imageUrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Comment as ${widget.username}",
                                filled: true,
                                fillColor: Colors.grey[850],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          isPosting
                              ? SizedBox(
                                  child: Center(
                                    child: LottieBuilder.asset(
                                      'assets/animations/loading.json',
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isPosting = true;
                                    });
                                    postComment(
                                      widget.postId,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      widget.username,
                                      widget.imageUrl,
                                    );
                                    setState(() {
                                      isPosting = false;
                                    });
                                    commentController.clear();
                                  },
                                )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
