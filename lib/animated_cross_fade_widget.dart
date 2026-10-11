import 'package:flutter/material.dart';
import 'animated_container_widget.dart';

// =====================================================================
//  ANIMATED CROSSFADE WIDGETS
//  Is file ke sab widgets AnimatedCrossFade use karte hain.
// =====================================================================

/// Login form aur Sign Up form ek dusre mein smoothly fade hote hain.
class AuthCrossFade extends StatelessWidget {
  final bool showLogin;
  final TextEditingController name, email, pass, conf;
  const AuthCrossFade({super.key, required this.showLogin, required this.name, required this.email, required this.pass, required this.conf});

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
    duration: const Duration(milliseconds: 400),
    crossFadeState: showLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    // pehli state: Login
    firstChild: Column(children: [
      AppField(email, 'Email', Icons.email, kt: TextInputType.emailAddress),
      AppField(pass, 'Password', Icons.lock, pass: true),
    ]),
    // dusri state: Sign Up
    secondChild: Column(children: [
      AppField(name, 'Full name', Icons.person),
      AppField(email, 'Email (@gmail.com)', Icons.email, kt: TextInputType.emailAddress),
      AppField(pass, 'Password', Icons.lock, pass: true),
      AppField(conf, 'Confirm password', Icons.lock_outline, pass: true),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Min 8 characters with uppercase, lowercase and a number.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ),
    ]),
  );
}

/// Lecture screen: "Mark as completed" button fade hokar "Completed" chip ban jata hai.
class DoneCrossFade extends StatelessWidget {
  final bool done;
  final VoidCallback onDone;
  const DoneCrossFade({super.key, required this.done, required this.onDone});

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
    duration: const Duration(milliseconds: 500),
    crossFadeState: done ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    firstChild: AnimButton('Mark as completed', onDone),
    secondChild: const Chip(label: Text('Completed'), avatar: Icon(Icons.check, size: 16, color: green)),
  );
}
