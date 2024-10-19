import 'package:shorts_a7md/resources/storage_methods.dart';
import 'package:shorts_a7md/models/user.dart' as model;
import 'package:shorts_a7md/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String username,
    required String password,
    required String bio,
    required Uint8List? file,
  }) async {
    String res = "An Error has occurred :/";
    try {
      if (email.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = 'null';
        if (file != null) {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
        }

        if (cred.user != null) {
          await cred.user!.sendEmailVerification();

          model.User user = model.User(
            email: email,
            uid: cred.user!.uid,
            username: username,
            photoUrl: photoUrl,
            bio: bio,
            followers: [],
            following: [],
            videos: [],
          );

          await _firestore
              .collection('users')
              .doc(cred.user!.uid)
              .set(user.toJson());
          res = "Success";
        } else {
          res = "User creation failed. Please try again.";
        }
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'Sorry, invalid email.';
      } else if (err.code == 'email-already-in-use') {
        res = 'Sorry, the email address is already in use by another account.';
      } else if (err.code == 'weak-password') {
        res =
            "Sorry, your password is too weak.\nPlease choose a stronger password.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> logInUser({
    required String email,
    required String password,
  }) async {
    String res = "An Error has occurred :/";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        if (cred.user != null && !cred.user!.emailVerified) {
          res = "Your email is not verified.\nPlease check your inbox.";
          await cred.user!.sendEmailVerification();
        } else {
          res = "Success";
        }
      } else {
        res = "Please enter all required fields.";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-credential' || err.code == 'user-not-found') {
        res =
            "Sorry, either the email or password\nis incorrect. Please check and try again.";
      }
    } catch (err) {
      res = "An unknown error occurred. Please try again.";
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      User? user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        showSnackBar(context, 'Verification email has been sent.');
      } else {
        showSnackBar(
            context, 'No user signed in or email is already verified.');
      }
    } catch (e) {
      showSnackBar(
          context, 'Failed to send verification email: ${e.toString()}');
    }
  }
}
