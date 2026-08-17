import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userdata.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  bool hasError = false;
  String errorText = '';
  bool isLoading = false;

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  Future<bool> handlelogin(UserData userData) async{
    String email = emailController.text;
    String pwd = pwdController.text;

    if (email.isEmpty || pwd.isEmpty) {
      hasError = true;
      errorText = 'Email and Password cannot be empty';
      notifyListeners();
      return false;
    }

    else if (!email.contains("@") || !email.contains(".")) {
      hasError = true;
      errorText = 'Email need to have @ and .com';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

   try {
   
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: pwd,
          )
          .timeout(const Duration(seconds: 15));

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (userDoc.data()?['suspended'] == true) {
        // await FirebaseAuth.instance.signOut();
        hasError = true;
        errorText = 'Your account has been suspended for posting inappropriate or scam content after receiving multiple reports.';
        return false;
      }

      userData.setCredentials(email, pwd, userData.username, userData.phoneNumber);

      hasError = false;
      errorText = '';
      return true;
    } on TimeoutException {
      hasError = true;
      errorText = 'Network timeout. Please check your connection and try again.';
      return false;
    } on FirebaseAuthException catch (e) { // NEW
      hasError = true;
      if (e.code == 'user-not-found') {
        errorText = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorText = 'Your Email or Password is incorrect';
      } else {
        errorText = e.message ?? 'Login failed.';
      }
      return false;
    } finally {
      isLoading = false; // NEW
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    pwdController.dispose();
    super.dispose();
  }
}