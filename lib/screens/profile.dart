


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../model/item_service.dart';
import '../model/userdata.dart';


class ProfilePage extends StatelessWidget {


  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ValueNotifier<bool> savedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<File?> imageFileNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(true); 

  final ItemService _itemService = ItemService();
    ProfilePage({super.key}) {
    _loadProfile(); 
  }
 Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoadingNotifier.value = false;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        emailController.text = data['email'] ?? user.email ?? '';
        usernameController.text = data['username'] ?? user.displayName ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
      } else {
        emailController.text = user.email ?? '';
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }
  
 Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      imageFileNotifier.value = File(picked.path);
    }
  }




  Future<void> saveProfile(BuildContext context) async {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in email, username, and phone number')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userdata = context.read<UserData>();
    savedNotifier.value = true;

    try {
      String? photoUrl;
      if (imageFileNotifier.value != null) {
        photoUrl = await _itemService.uploadImage(imageFileNotifier.value!);
        userdata.photoUrl = photoUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': emailController.text,
        'username': usernameController.text,
        'phoneNumber': phoneController.text,
        if (photoUrl != null) 'photoUrl': photoUrl,
      }, SetOptions(merge: true));

      userdata.email = emailController.text;
      userdata.username = usernameController.text;
      userdata.phoneNumber = phoneController.text;


      savedNotifier.value = true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      savedNotifier.value = false; 
    }
  }
  @override
  Widget build(BuildContext context) {

    final userdata = context.watch<UserData>();
        if (emailController.text.isEmpty) {
      emailController.text = userdata.email;
      usernameController.text = userdata.username;
      phoneController.text = userdata.phoneNumber;

      
    }
    

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('My Profile'),
        centerTitle: true,
      ),
     body: ValueListenableBuilder<bool>( 
        valueListenable: isLoadingNotifier,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // CHANGED: now tappable and actually reflects the picked/saved image
                      ValueListenableBuilder<File?>(
                        valueListenable: imageFileNotifier,
                        builder: (context, pickedFile, child) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 3),
                                    image: DecorationImage(
                                      image: pickedFile != null
                                          ? FileImage(pickedFile)
                                          : (userdata.photoUrl.isNotEmpty
                                              ? NetworkImage(userdata.photoUrl)
                                              : const AssetImage('images/profile.jpg')) as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.green,
                                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: false,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_android),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // TextField(
                  //   obscureText: false,
                  //   controller: passwordController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Password',
                  //     prefixIcon: const Icon(Icons.password),
                  //     border:
                  //         OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: savedNotifier,
                    builder: (context, saved, child) {
                      if (!saved) return const SizedBox.shrink();
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 5),
                            Text('Your Profile has been Updated!',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed:() => saveProfile(context),
                      child: const Text(
                        'SAVE CHANGES',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

