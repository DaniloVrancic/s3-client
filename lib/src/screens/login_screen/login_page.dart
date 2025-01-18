import 'package:flutter/material.dart';

class LoginPageWidget extends StatelessWidget {
  const LoginPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 228, 58, 11),
            Color.fromARGB(255, 23, 22, 22)
          ])
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: const Text("Sign into\nyour account!", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 30.0, 
                  fontWeight: FontWeight.bold),),
              
            ),
            const SizedBox(height: 40.0,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration( 
                  color: const Color.fromARGB(255, 20, 5, 5),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Username", 
                style: TextStyle(
                  color: Color.fromARGB(255, 228, 58, 11), 
                  fontSize: 15.0, 
                  fontWeight: FontWeight.bold),),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Username", 
                        prefixIcon: Icon(Icons.person)),
                    ),
                    SizedBox(height: 30.0,),
                    const Text("Password", 
                style: TextStyle(
                  color: Color.fromARGB(255, 228, 58, 11), 
                  fontSize: 15.0, 
                  fontWeight: FontWeight.bold),),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        prefixIcon: Icon(Icons.password)),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
        )
    );
  }
}