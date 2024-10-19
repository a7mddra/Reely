import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorts_a7md/screens/tabs/home/feed_controller.dart';
import 'package:shorts_a7md/screens/tabs/notifications/notifications.dart';
import 'package:shorts_a7md/screens/tabs/profile/profile.dart';
import 'package:shorts_a7md/screens/tabs/settings.dart' as tab;
import 'package:shorts_a7md/screens/tabs/upload.dart';
import 'package:shorts_a7md/utils/utils.dart';

class Layout extends StatefulWidget {
  final int initialIndex;
  const Layout({super.key, this.initialIndex = 0});

  @override
  createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;
  double _indicatorPosition = 0.0;
  bool isLoading = false;
  String username = '';
  String photoUrl = '';
  String bio = '';
  var followers;
  var following;
  var videos;
  var userData = {};
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    checkUnreadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData();
  }

  Future<void> checkUnreadNotifications() async {
    try {
      var notificationsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      setState(() {
        hasUnreadNotifications = notificationsSnap.docs.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      setState(() {
        photoUrl = userData['photoUrl'];
        username = userData['username'];
        bio = userData['bio'];
        followers = userData['followers'];
        following = userData['following'];
        videos = userData['videos'];
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _indicatorPosition = index.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FeedController(
        isTabVisible: _selectedIndex == 0,
        username: username,
        photoUrl: photoUrl,
        hasData: !isLoading,
      ),
      const Notifications(),
      Upload(
        isTabVisible: _selectedIndex == 2,
        username: username,
        photoUrl: photoUrl,
        hasData: !isLoading,
      ),
      const Profile(),
      const tab.Settings(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: onItemTapped,
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: ''),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),
                      if (hasUnreadNotifications)
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Container(
                            width: 9.0,
                            height: 9.0,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.add_box), label: ''),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: ''),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: ''),
              ],
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.black,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
            ),
            Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width * _indicatorPosition / 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width / 5,
                height: 3.0,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
