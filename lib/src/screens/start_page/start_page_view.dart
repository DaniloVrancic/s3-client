import 'package:flutter/material.dart';

class StartPageWidget extends StatelessWidget {
  const StartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const Text('Hello World'),
      ),
    );
  }
}