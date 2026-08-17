import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'model/userdata.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart';
import 'screens/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(    
    ChangeNotifierProvider( 
      create: (context) => UserData(), 
      child: const MyApp(),
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  // Whether to show Login or Signup while logged out — owned here, not by
  // Navigator, so it can never end up stacked on top of (or replacing) this
  // StreamBuilder. That was the cause of "logout does nothing": once Login or
  // Signup pushed/replaced routes on their own, this StreamBuilder either got
  // buried under extra routes or destroyed outright, leaving nothing to react
  // to sign-out.
  bool _showSignup = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return _SuspensionGate(user: snapshot.data!);
        }
        if (_showSignup) {
          return Signup_Page(onHaveAccount: () => setState(() => _showSignup = false));
        }
        return LoginPage(onCreateAccount: () => setState(() => _showSignup = true));
      },
    );
  }
}

class _SuspensionGate extends StatelessWidget {
  final User user;

  const _SuspensionGate({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data?.data()?['suspended'] == true) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.block, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Your account has been suspended for posting inappropriate or scam content after receiving multiple reports.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final userData = context.read<UserData>();
        return Home(userdata: userData);
      },
    );
  }
}