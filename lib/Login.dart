import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/SignInPage.dart';// Your login page
import 'notes_main.dart'; // Your notes home page

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking auth state
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // User is signed in
          return NotesHome();
        }
        // User is NOT signed in
        return AdvancedSignInPage();
      },
    );
  }
}
