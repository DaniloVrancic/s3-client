import 'package:flutter/material.dart';
import 'package:s3_client/src/screens/login_screen/login_page.dart';

class RegisterPageWidget extends StatelessWidget {
  const RegisterPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50.0),
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
            const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text("Create your account!", 
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
                decoration: const BoxDecoration( 
                  color:  Color.fromARGB(255, 20, 5, 5),
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
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Enter Username", 
                        prefixIcon: Icon(Icons.person)),
                    ),
                     const SizedBox(height: 30.0,),
                     const Text("E-mail",
                     
                style: TextStyle(
                  color: Color.fromARGB(255, 228, 58, 11), 
                  fontSize: 15.0, 
                  fontWeight: FontWeight.bold),),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Enter E-mail", 
                        prefixIcon: Icon(Icons.email)),
                    ),
                     const SizedBox(height: 30.0,),
                     const Text("Password", 
                style: TextStyle(
                  color: Color.fromARGB(255, 228, 58, 11), 
                  fontSize: 15.0, 
                  fontWeight: FontWeight.bold),),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        prefixIcon: Icon(Icons.password)),
                    ),
                      const SizedBox(height: 60.0,),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(255, 228, 58, 11),
                            Color.fromARGB(175, 80, 30, 10)
                          ], begin: Alignment.topLeft, end: Alignment.topRight), borderRadius: BorderRadius.circular(30)
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: Text("REGISTER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                          )),),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 11,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                          const Text("Already have an account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500
                          ),
                            ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPageWidget()));
                            },
                            child: const Text("SIGN IN",
                            style: TextStyle(
                              color: Colors.lightBlue, 
                            fontSize: 14.0, 
                            fontWeight: FontWeight.bold
                            ),),
                          )
                        ],)
                      ],)
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