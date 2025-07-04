import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart'; // Your auth-checking widget

class AnimatedSplashScreen extends StatefulWidget {
  @override
  _AnimatedSplashScreenState createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _logoFadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();

    _colorAnimation = ColorTween(
      begin: Color(0xFF42A5F5), // Blue
      end: Color(0xFF7E57C2),   // Purple
    ).animate(_controller);

    _logoFadeIn = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 1.0, curve: Curves.easeIn),
    );

    // After 2.5 seconds, go to main app
    Timer(Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFadeIn,
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Icon(
                          //Icons.note_add_sharp,
                          FontAwesomeIcons.noteSticky,
                        size: 40,
                      )
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _logoFadeIn,
                  child: Text(
                    "Notes App",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.92),
                      letterSpacing: 1.2,
                      fontFamily: 'Montserrat', // Optional: use a nice font
                    ),
                  ),
                ),
                SizedBox(height: 8),
                FadeTransition(
                  opacity: _logoFadeIn,
                  child: Text(
                    "Organize your ideas instantly",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
