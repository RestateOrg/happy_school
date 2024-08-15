import 'package:flutter/material.dart';

class Usercourses extends StatefulWidget {
  const Usercourses({super.key});

  @override
  State<Usercourses> createState() => _UsercoursesState();
}

class _UsercoursesState extends State<Usercourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Text("User courses"),
        ),
      ),
    );
  }
}
