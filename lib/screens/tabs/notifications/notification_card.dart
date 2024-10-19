import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notificationData;

  const NotificationCard({Key? key, required this.notificationData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String type = notificationData['type'];
    String username = notificationData['username'];
    String userPhoto = notificationData['userPhoto'];

    String actionText;
    if (type == 'like') {
      actionText = 'liked your video';
    } else if (type == 'comment') {
      actionText = 'commented on your video';
    } else {
      actionText = 'followed you';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userPhoto),
      ),
      title: Text(
        '$username $actionText',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        DateFormat.yMMMd().format(notificationData['datePublished']
            .toDate()), // using timeago package for relative time
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        // Navigate to the relevant screen (e.g., video or profile) based on the notification type
      },
    );
  }
}
