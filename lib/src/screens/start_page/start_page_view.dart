import 'package:flutter/material.dart';

class StartPageWidget extends StatelessWidget {
  const StartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white60,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset('assets/images/welcome_page_bg.png', 
              fit: BoxFit.fill),
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
                      color: const Color.fromARGB(255, 174, 109, 223),
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/logo_with_name_no_background_preview.png',
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center),
                        
                        ),
                      ),
                  ),
                  
                      const SizedBox(height: 50,),
                  
                  Container(
                    child: const Text("Bucketer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w700
                    ),
                    ),
                  ),
                  const SizedBox(height: 4,),
                  Container(
                    
                    child : const Text("Your trusted S3 storage manager!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600
                    ),
                    ),
                  ),
                 const SizedBox(height: 30,),
                 Padding(
                  padding: const EdgeInsets.all(20),
                   child: 
                     ElevatedButton(
                      onPressed: (){}, 
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 95, 56, 126),),
                        padding: WidgetStatePropertyAll(EdgeInsets.only(top: 15, bottom: 15))
                      ),
                      child: const Text("Login", 
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white
                      ),)),
                   
                 ),
                 const SizedBox(height: 30),
                 Padding(
                  padding: const EdgeInsets.all(20),
                   child: 
                     ElevatedButton(
                      onPressed: (){},
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        padding: WidgetStatePropertyAll(EdgeInsets.only(top: 15, bottom: 15)),
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