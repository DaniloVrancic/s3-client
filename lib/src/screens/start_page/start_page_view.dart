import 'package:flutter/material.dart';
import 'package:s3_client/src/screens/login_screen/login_page.dart';
import 'package:s3_client/src/screens/register_screen/register_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';

class StartPageWidget extends StatelessWidget {
  const StartPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: "Settings",
                    iconSize: 30.0,
                    color: Colors.deepOrange,
                    splashColor: Colors.white,
                    highlightColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const SettingsPageWidget())
                      );
                    },
                  ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageWidget()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Set button color
                        foregroundColor: Colors.black, // Ensures text/splash effect
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        elevation: 5, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color.fromARGB(255, 40, 97, 190),
                        ),
                      ),
),
                   
                 ),
                 const SizedBox(height: 30),
                 Padding(
                  padding: const EdgeInsets.all(20),
                   child: 
                     ElevatedButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPageWidget()));
                        
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
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