import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/resources/firestore_methods.dart';
import 'package:shorts_a7md/screens/tabs/profile/profile_video.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';

class Profile extends StatefulWidget {
  final String uid;

  const Profile({
    super.key,
    required this.uid,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  bool follow = false;
  bool block = false;
  String username = '';
  String photoUrl = '';
  String bio = '';
  var followers = [];
  var following = [];
  var videos = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var userData = userSnap.data()!;
      setState(() {
        photoUrl = userData['photoUrl'];
        username = userData['username'];
        bio = userData['bio'];
        followers = userData['followers'];
        following = userData['following'];
        videos = userData['videos'];
        follow = userData['followers']
            .contains(FirebaseAuth.instance.currentUser!.uid);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, e.toString());
      }
    }
  }

  // Optimistic update for follow/unfollow
  void toggleFollow() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Optimistic update: update the UI immediately
    setState(() {
      if (follow) {
        followers.remove(currentUserId);
        follow = false;
      } else {
        followers.add(currentUserId);
        follow = true;
      }
    });

    // Perform Firestore operation in the background
    try {
      await FireStoreMethods().followUser(widget.uid);

      // If needed, you can double-check Firestore here and adjust the UI again if necessary.
    } catch (e) {
      // If the Firestore operation fails, revert the optimistic update
      setState(() {
        if (follow) {
          followers.remove(currentUserId);
          follow = false;
        } else {
          followers.add(currentUserId);
          follow = true;
        }
      });
      showSnackBar(context, 'Failed to update follow status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Loading(
      isLoading: isLoading,
      loadingContent: buildShimmerContent(),
      loadedContent: buildProfileContent(),
    );
  }

  Widget buildProfileContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await getData();
      },
      color: Colors.blue,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor:
                                const Color.fromARGB(255, 20, 20, 20),
                            backgroundImage: photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(photoUrl)
                                : null,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            username,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            bio,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      buildMetricsColumn(videos.length, "Videos"),
                      const SizedBox(width: 10),
                      buildMetricsColumn(followers.length, "Followers"),
                      const SizedBox(width: 10),
                      buildMetricsColumn(following.length, "Following"),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 35,
                        width: 165,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          onPressed: toggleFollow,
                          child: Text(
                            follow ? "Unfollow" : "Follow",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        width: 165,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              block = !block;
                            });
                          },
                          child: Text(
                            block ? "Blocked" : "Block",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 61, 61, 61),
                ),
                videos.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: videos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 9 / 16,
                          ),
                          itemBuilder: (context, index) {
                            String thumbUrl = videos[index]['thumbUrl']!;
                            return AspectRatio(
                              aspectRatio: 9 / 16,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProfileVideo(
                                            index: index,
                                            myImage: photoUrl,
                                            myName: username,
                                            videos: videos,
                                          )));
                                },
                                child: Container(
                                  color: Colors.black12,
                                  child: CachedNetworkImage(
                                    imageUrl: thumbUrl,
                                    placeholder: (context, url) => Loading(
                                      isLoading: true,
                                      loadingContent: Container(
                                        color: Colors.white,
                                      ),
                                      loadedContent: Container(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Capture the moment with a friend",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'be',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildMetricsColumn(int count, String label) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 18),
      Text(
        count.toString(),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    ],
  );
}
