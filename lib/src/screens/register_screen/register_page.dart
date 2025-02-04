import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/login_screen/login_page.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';

class RegisterPageWidget extends StatefulWidget {
  const RegisterPageWidget({super.key});

  @override
  State<RegisterPageWidget> createState() => _RegisterPageWidgetState();
}

class _RegisterPageWidgetState extends State<RegisterPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? validateEmail(String? value) {
    const emailPattern =
        r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    final regex = RegExp(emailPattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }
    if(value.contains('---'))
    {
      return 'Username has illegal character combination';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

    void _registerUser() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    User userToRegister = User();
    userToRegister.updateUser(newUsername: username, newEmail: email, newPassword: password);

    // Validate username
    if (username.contains('---')) {
      _showSnackbar("Invalid username: Cannot contain '---'", Colors.red);
      return;
    }
    else if(username.startsWith("-")) {
      _showSnackbar("Invalid username: Username cannot start with: '-'", Colors.red);
      return;
    }
    else if(!RegExp(r'^[a-z0-9][a-z0-9.-]+[a-z0-9]$').hasMatch(username))
    {
      _showSnackbar("Invalid username: Username is of invalid form. (Use only alphanumericals and '-', can't start and end with '-')", Colors.red);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showSnackbar("Register failed.", Colors.red);
        return;
    }

    BackblazeService b2service = context.read<BackblazeService>(); //Gets the S3 compatible service from the context (initialized at start in main method)

    bool foundUser = false;
    List<String> listOfUsers = [];
    await b2service.fetchUserbase().then((List<String> userStringList) {
      for(String line in userStringList)
      {
        List<String> tokens = line.split(",");
        if(tokens.length != 3)
        {
          continue;
        }

        if(username == tokens.elementAt(1) || email == tokens.elementAt(0))
        {
          foundUser = true;
          break;
        }
      }
    });

    if(foundUser) //  If the User already exists in the users file on the cloud
    {
      _showSnackbar("User already registered.", Colors.red);
      return;
    }
    
    userToRegister.updateUser(
      newUsername: username,
      newEmail: email,
      newPassword: password);
    
    listOfUsers.add(userToRegister.toString());
    listOfUsers=listOfUsers..sort((u1,u2) => u1.split(",").elementAt(1).compareTo(u2.split(",").elementAt(1))); //  Sort by Username

    String listOfUsersString = listOfUsers.join('\n');
    List<int> listOfUsersCodeUnits = utf8.encode(listOfUsersString); //Used to create a proper Uint8List to send to method
    await b2service.uploadFileFromBytes(
      Uint8List.fromList(listOfUsersCodeUnits),
      b2service.userbaseBucket.toString(),
      b2service.userbaseObject.toString(),
      contentType: "text/csv"
    ).then(
      (bool value) => {
        if(value == true)
        {
          _showSnackbar("User successfully registered!", Colors.green)
        }
      },
      onError: (e) {
          _showSnackbar("An Error occured: Couldn't register User", Colors.red);
      }
    );

    _showSnackbar("Successfully registered User: $username!", Colors.green);

    // Redirect to previous page after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Assuming previous screen is Starting Screen
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _registerUser();
    }
  }

    void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 228, 58, 11),
            Color.fromARGB(255, 23, 22, 22)
          ]),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  "Create your account!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 20, 5, 5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Username",
                        style: TextStyle(
                          color: Color.fromARGB(255, 228, 58, 11),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Enter Username",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: validateUsername,
                        expands: false,
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        "E-mail",
                        style: TextStyle(
                          color: Color.fromARGB(255, 228, 58, 11),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Enter E-mail",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        expands: false,
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: Color.fromARGB(255, 228, 58, 11),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter Password",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: validatePassword,
                        expands: false,
                      ),
                      const SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color.fromARGB(255, 228, 58, 11),
                              Color.fromARGB(175, 80, 30, 10),
                            ]),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "REGISTER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: MediaQuery.of(context).size.height / 40,),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageWidget()));
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
          ),
          
        ),
        
      ),
    );
  }
}
