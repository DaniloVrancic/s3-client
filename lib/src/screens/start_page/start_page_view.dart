import 'package:flutter/material.dart';

class StartPageWidget extends StatelessWidget {
  const StartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/images/welcome_page_bg.png', 
              fit: BoxFit.cover),
              )
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 180,
                      height: 180,
                      color: const Color.fromARGB(255, 79, 8, 133),
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/logo_with_name_no_background_preview.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center),

                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: const Text("Welcome to Bucketer, your trusted S3 storage manager!"),
                  )
                ],  
              ),
            )
          ],
        ),
      ),
    );
  }
}