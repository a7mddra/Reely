import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shorts_a7md/models/post.dart';
import 'package:shorts_a7md/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List vid, String uid,
      String username, String profImage) async {
    String res = "Some error occurred";
    try {
      String videoUrl =
          await StorageMethods().uploadVideoToStorage('posts', vid, true);

      String thumbUrl = await generateThumbnail(videoUrl);

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: videoUrl,
        thumbUrl: thumbUrl,
        profImage: profImage,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      await _firestore.collection('users').doc(uid).update({
        'videos': FieldValue.arrayUnion([
          {
            'postId': postId,
            'thumbUrl': thumbUrl,
          }
        ])
      });

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> generateThumbnail(String videoUrl) async {
    final dir = await getTemporaryDirectory();
    final thumbnailPath = '${dir.path}/thumbnail.png';
    await FFmpegKit.execute(
        '-i $videoUrl -ss 00:00:01.000 -vframes 1 $thumbnailPath');
    Uint8List thumbnailBytes = await File(thumbnailPath).readAsBytes();
    String thumbUrl = await StorageMethods()
        .uploadImageToStorage('posts', thumbnailBytes, true);
    File(thumbnailPath).deleteSync();
    return thumbUrl;
  }

  Future<String> likePost(
      String postId, String uid, List likes, bool smallLike) async {
    String res = "Some error occurred";
    try {
      DocumentSnapshot postSnap =
          await _firestore.collection('posts').doc(postId).get();
      String postOwnerId = postSnap['uid'];

      if (smallLike) {
        if (likes.contains(uid)) {
          _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayUnion([uid])
          });
        } else {
          _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayRemove([uid])
          });

          if (postOwnerId != uid) {
            await _firestore
                .collection('users')
                .doc(postOwnerId)
                .collection('notifications')
                .add({
              'type': 'like',
              'postId': postId,
              'uid': uid,
              'username': (await _firestore
                  .collection('users')
                  .doc(uid)
                  .get())['username'],
              'userPhoto': (await _firestore
                  .collection('users')
                  .doc(uid)
                  .get())['photoUrl'],
              'datePublished': DateTime.now(),
            });
          }
        }
      } else {
        if (likes.contains(uid)) {
          _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayUnion([uid])
          });

          if (postOwnerId != uid) {
            await _firestore
                .collection('users')
                .doc(postOwnerId)
                .collection('notifications')
                .add({
              'type': 'like',
              'postId': postId,
              'uid': uid,
              'username': (await _firestore
                  .collection('users')
                  .doc(uid)
                  .get())['username'],
              'userPhoto': (await _firestore
                  .collection('users')
                  .doc(uid)
                  .get())['photoUrl'],
              'datePublished': DateTime.now(),
            });
          }
        }
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });

        DocumentSnapshot postSnap =
            await _firestore.collection('posts').doc(postId).get();
        String postOwnerId = postSnap['uid'];

        if (postOwnerId != uid) {
          await _firestore
              .collection('users')
              .doc(postOwnerId)
              .collection('notifications')
              .add({
            'type': 'comment',
            'postId': postId,
            'uid': uid,
            'username': name,
            'userPhoto': profilePic,
            'text': text,
            'datePublished': DateTime.now(),
          });
        }

        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid) async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List followers = (snap.data()! as dynamic)['followers'];

      if (followers.contains(myId)) {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([myId])
        });

        await _firestore.collection('users').doc(myId).update({
          'following': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([myId])
        });

        await _firestore.collection('users').doc(myId).update({
          'following': FieldValue.arrayUnion([uid])
        });

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add({
          'type': 'follow',
          'uid': myId,
          'username': (await _firestore
              .collection('users')
              .doc(myId)
              .get())['username'],
          'userPhoto': (await _firestore
              .collection('users')
              .doc(myId)
              .get())['photoUrl'],
          'datePublished': DateTime.now(),
          'read': false,
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }
}
