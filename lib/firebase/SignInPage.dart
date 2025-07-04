import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes_app/firebase/youtube.dart';
import '../notes_main.dart';
import 'Google.dart';



class AdvancedSignInPage extends StatefulWidget {
  final VoidCallback? onGuestSignIn;
  final Future<void> Function(String email, String password)? onSignIn;
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onGitHubSignIn;
  final VoidCallback? onYouTubeSignIn;


  const AdvancedSignInPage({
    Key? key,
    this.onGuestSignIn,
    this.onSignIn,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    this.onForgotPassword,
    this.onGitHubSignIn,
    this.onYouTubeSignIn
  }) : super(key: key);

  @override
  State<AdvancedSignInPage> createState() => _AdvancedSignInPageState();
}

class _AdvancedSignInPageState extends State<AdvancedSignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _obscurePassword = true;
  String? _errorMessage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _passwordError;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branding or illustration
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.lock_outline, size: 48, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),

                  // Email field
                  Form(
                    child:
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _email = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter your email';
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),

                  // Password field with toggle
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      errorText: _passwordError,
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onChanged: (value) {
                      setState(() {
                        _passwordError = null; // Clear error when typing
                      });
                    },
                    // REMOVE validator for server-side error
                  ),
                  SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.onForgotPassword,
                      child: Text('Forgot password?'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            // Login successful, you can navigate or show success
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => NotesHome()), // Replace NextPage with your page
                            );
                          }on FirebaseAuthException catch (e) {
                            print('FirebaseAuthException code: ${e.code}');
                            print('FirebaseAuthException message: ${e.message}');
                            if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                              setState(() {
                                _passwordError = 'Incorrect email or password. Please try again.';
                              });
                            } else {
                              // Handle other errors or show a general message
                              setState(() {
                                _passwordError = 'Login failed. Please try again.';
                              });
                            }
                          }
                         }
                         },
                      child: Text('Login'),
                    )

                  ),
                  SizedBox(height: 16),

                  // Social sign-in
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('or sign in with'),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 42),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16),
                      _SocialButton(
                        icon: Image.asset('assets/google.png', height: 34, width: 34),
                        label: 'Google',
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => GoogleSignInPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 16),
                      _SocialButton(
                        icon: FaIcon(FontAwesomeIcons.youtube, size: 28, color: Colors.red),
                        label: 'YouTube',
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => YouTubeSignInPage(),
                            ),
                          );
                        }
                      )
                    ],
                  ),

                  SizedBox(height: 24),

                  // Guest sign-in
                  TextButton(
                    onPressed: widget.onGuestSignIn,
                    child: Text('Continue as Guest'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: icon,
      label: Text(label),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
