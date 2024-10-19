import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/layout.dart';
import 'package:shorts_a7md/screens/tabs/profile/profile_video.dart';
import 'package:shorts_a7md/utils/utils.dart';
import 'package:shorts_a7md/widgets/shimmer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  String username = '';
  String photoUrl = '';
  String bio = '';
  bool follow = false;

  var followers;
  var following;
  var videos;

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
          .doc(FirebaseAuth.instance.currentUser!.uid)
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

  @override
  Widget build(BuildContext context) {
    return Loading(
      isLoading: isLoading,
      loadingContent: buildShimmerContent(),
      loadedContent: buildProfileContent(),
    );
  }

  Widget buildShimmerContent() {
    return Column(
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
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        buildShimmerBox(80, 15),
                        const SizedBox(height: 9),
                        buildShimmerBox(120, 15),
                      ],
                    ),
                    const SizedBox(width: 15),
                    buildShimmerMetrics(),
                    const SizedBox(width: 10),
                    buildShimmerMetrics(),
                    const SizedBox(width: 10),
                    buildShimmerMetrics(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildShimmerBox(165, 35 / 1.2),
                    buildShimmerBox(165, 35 / 1.2),
                  ],
                ),
              ),
              Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
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
                      buildMetricsColumn(videos?.length ?? 0, "Videos"),
                      const SizedBox(width: 10),
                      buildMetricsColumn(followers?.length ?? 0, "Followers"),
                      const SizedBox(width: 10),
                      buildMetricsColumn(following?.length ?? 0, "Following"),
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
                                    borderRadius: BorderRadius.circular(9))),
                            onPressed: () {},
                            child: const Text(
                              "Edit profile",
                              style: TextStyle(fontSize: 15),
                            )),
                      ),
                      SizedBox(
                        height: 35,
                        width: 165,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9))),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Layout(initialIndex: 2)));
                            },
                            child: const Text(
                              "Upload new",
                              style: TextStyle(fontSize: 15),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 61, 61, 61),
                ),
                videos != null && videos.isNotEmpty
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
                                          loadedContent: Container()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )),
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
}
