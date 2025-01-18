import 'package:flutter/material.dart';

class StartPageWidget extends StatelessWidget {
  const StartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(transform: GradientRotation(4.05),colors: [
            Color.fromARGB(255, 211, 112, 84),
            Color.fromARGB(255, 228, 58, 11),
            Color.fromARGB(255, 23, 22, 22)
          ])
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: Opacity(
                opacity: 0.4,
              
              )
            ),
            Center(
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipOval(
                    child: Container(
                      
                      width: 180,
                      height: 180,
                      
                      padding: const EdgeInsets.all(15),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/logo_no_background.png',
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center),
                        
                        ),
                      ),
                  ),
                  
                      const SizedBox(height: 50,),
                  
                  Container(
                    child: const Text("Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700
                    ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                 
                 Padding(
                  padding: const EdgeInsets.all(20),
                   child: 
                     ElevatedButton(
                      onPressed: (){}, 
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255),),
                        padding: WidgetStatePropertyAll(EdgeInsets.only(top: 15, bottom: 15))
                      ),
                      child: const Text("Login", 
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color.fromARGB(255, 40, 97, 190)
                      ),)),
                   
                 ),
                 const SizedBox(height: 30),
                 Padding(
                  padding: const EdgeInsets.all(20),
                   child: 
                     ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          width: 3.0,
                          color: Colors.white
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        
                      ),
                      
                      child: const Text("Register", 
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white
                      ),)),
                 ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}