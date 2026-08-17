
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'userdata.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool hasError = false;
  String errorText = '';
  bool isLoading = false;

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  Future<bool> doSignup(UserData userData) async{
    String email = emailController.text;
    String pwd = pwdController.text;
    String username = usernameController.text;
    String phoneNumber = phoneController.text;

    if (email.isEmpty || pwd.isEmpty) {
      hasError = true;
      errorText = 'Email and Password cannot be empty';
      notifyListeners();
      return false;
    }

    if (!email.contains("@") || !email.contains(".")) {
      hasError = true;
      errorText = 'Email need to have @ and .com';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    // try {

    //   await FirebaseAuth.instance
    //       .createUserWithEmailAndPassword(
    //         email: email,
    //         password: pwd,

    //       )
    //       .timeout(const Duration(seconds: 15));
    //   // await FirebaseAuth.instance.signOut();
  
    //   userData.setCredentials(email, pwd, username, phoneNumber);

    //   hasError = false;
    //   errorText = '';
    //   return true;
    // }
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: pwd,
        )
        .timeout(const Duration(seconds: 15));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'email': email,
          'username': username,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });

    userData.setCredentials(email, pwd, username, phoneNumber);
    hasError = false;
    errorText = '';
    return true;
    
  }


     on TimeoutException {
      hasError = true;
      errorText = 'Network timeout. Please check your connection and try again.';
      return false;
    } on FirebaseAuthException catch (e) {
      hasError = true;
      if (e.code == 'weak-password') {
        errorText = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorText = 'An account already exists for that email.';
      } else {
        errorText = e.message ?? 'Registration failed.';
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }


  }

  @override
  void dispose() {
    _disposed = true;
    emailController.dispose();
    pwdController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}