import 'package:flutter/material.dart';

class Schools extends StatefulWidget {
  const Schools({super.key});

  @override
  State<Schools> createState() => _SchoolsState();
}

class _SchoolsState extends State<Schools> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Schools"),
    );
  }
}
