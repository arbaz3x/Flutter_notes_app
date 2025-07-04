import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../notes_main.dart'; // Make sure this imports your NotesHome widget

class YouTubeSignInPage extends StatefulWidget {
  @override
  State<YouTubeSignInPage> createState() => _YouTubeSignInPageState();
}

class _YouTubeSignInPageState extends State<YouTubeSignInPage> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithYouTube() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Use authenticate() with YouTube scope
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.authenticate(
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/youtube.readonly',
        ],
      );

      if (googleUser == null) {
        setState(() {
          _loading = false;
          _error = 'YouTube sign-in aborted.';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotesHome()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'YouTube sign-in failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
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
                        Image.asset(
                          'assets/youtube_1.png', // 142x142 PNG in assets
                          height: 142,
                          width: 142,
                        ),
                        Text(
                          'Sign In with your YouTube account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        _YouTubeSignInButton(onPressed: _signInWithYouTube),
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

class _YouTubeSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _YouTubeSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        minimumSize: Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.red.shade700),
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shadowColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/youtube_big.png', // 32x32 PNG in assets
            height: 32,
            width: 32,
          ),
          SizedBox(width: 12),
          Text('Sign in with YouTube'),
        ],
      ),
    );
  }
}
