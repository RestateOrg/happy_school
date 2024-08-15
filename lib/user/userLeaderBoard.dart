import 'package:flutter/material.dart';

class Userleaderboard extends StatefulWidget {
  const Userleaderboard({super.key});

  @override
  State<Userleaderboard> createState() => _UserleaderboardState();
}

class _UserleaderboardState extends State<Userleaderboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Text("User Leaderboard"),
        ),
      ),
    );
  }
}
