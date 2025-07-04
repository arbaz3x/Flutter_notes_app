import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../notes_main.dart'; // Make sure this imports your NotesHome widget

class GoogleSignInPage extends StatefulWidget {
  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      debugPrint('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn
          .instance.authenticate();

      if (googleUser == null) {
        debugPrint('Google Sign-In aborted by user.');
        setState(() {
          _loading = false;
          _error = 'Google sign-in aborted.';
        });
        return;
      }
      debugPrint('Google user: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('Received idToken: ${googleAuth.idToken != null}');
      final credential = GoogleAuthProvider.credential(
        //accessToken: googleAuth.acessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('Signed in with Firebase!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotesHome()),
        );
      }
    } catch (e,stack) {
      debugPrint('Google sign-in failed: $e');
      debugPrint('Stack trace: $stack');
      setState(() {
        _error = 'Google sign-in failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing GoogleSignIn with:');
    debugPrint('clientId: 370046895538-3p1fj47ku05v5b76qj9a4vr1d2mb0r0u.apps.googleusercontent.com');

   if(Platform.isAndroid) {
     GoogleSignIn.instance.initialize(
       clientId: '370046895538-3p1fj47ku05v5b76qj9a4vr1d2mb0r0u.apps.googleusercontent.com',
       serverClientId: '370046895538-s185bnjmu1b08h49ceohlvjucvc4hq5v.apps.googleusercontent.com',
     );
   }

     if(Platform.isIOS) {
       GoogleSignIn.instance.initialize();
     }


  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF181A20) : Color(0xFFF2F6FC),
      body: Center(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 340),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: isDark ? Color(0xFF23262F) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Icon(Icons.note_alt_rounded, size: 42, color: theme.colorScheme.primary),
                        Image.asset(
                          'assets/google_1.png', // 24x24 PNG in assets, see below
                          height: 142,
                          width: 142,
                        ),
                        //SizedBox(height: 6),

                        Text(
                          'Sign In with your Google account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        _GoogleSignInButton(onPressed: _signInWithGoogle),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.08),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        minimumSize: Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey.shade300),
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shadowColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/google.png', // 24x24 PNG in assets, see below
            height: 32,
            width: 32,
          ),
          SizedBox(width: 12),
          Text('Sign in with Google'),
        ],
      ),
    );
  }
}
