import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final User? user;
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.user,
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the avatar widget
    final Widget? avatar = user != null
        ? (user!.photoURL != null
        ? CircleAvatar(
      backgroundImage: NetworkImage(user!.photoURL!),
      radius: 24,
    )
        : CircleAvatar(
          child: Icon(Icons.person, size: 20),
          radius: 24,
    ))
        : null;


    // Explicitly type as List<Widget>
    final List<Widget> allActions = [
      IconButton(
        icon: Icon(Icons.ios_share),
        tooltip: 'Share',
        onPressed: () {
          // Implement your share logic here

        },
      ),
      ...(actions ?? <Widget>[]),
      if (avatar != null)
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: avatar,
        ),

    ];

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.lightBlueAccent,
      elevation: 2,
      centerTitle: true,
      actions: allActions, // Now typed correctly
      leading: leading,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
