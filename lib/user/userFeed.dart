import 'package:flutter/material.dart';

class Userfeed extends StatefulWidget {
  const Userfeed({super.key});

  @override
  State<Userfeed> createState() => _UserfeedState();
}

class _UserfeedState extends State<Userfeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Text(
            "user Feed",
          ),
        ),
      ),
    );
  }
}
