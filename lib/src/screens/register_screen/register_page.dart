import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/login_screen/login_page.dart';
import 'package:s3_client/src/screens/start_page/start_page_view.dart';
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

  bool _isLoading = false; // Loading state

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
        // Validate username
    if (value.contains('---')) {
      return "Invalid username: Cannot contain '---'";
    }
    else if(value.startsWith("-")) {
      return "Invalid username: Username cannot start with: '-'";
    }
    else if(!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$').hasMatch(value))
    {
      return "Invalid username: Username is of invalid form. (Use only alphanumericals and '-', can't start and end with '-')";
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
    Future<String> hashedPassword = User.hashPassword(password);

    setState(() => _isLoading = true); // Start loading

    User userToRegister = User();


    if (!_formKey.currentState!.validate()) {
      _showSnackbar("Register failed.", Colors.red.shade400);
        return;
    }

    BackblazeService b2service = context.read<BackblazeService>(); //Gets the S3 Compatible Service From the context (Initialized at Start in main method)

    bool foundUser = false;
    List<String> listOfUsers = [];
    await b2service.fetchUserbase().then((List<String> userStringList) {
      for(String line in userStringList)
      {
        List<String> tokens = line.split(",");
        if(tokens.length == 3 && tokens[2].length >= 28) //if there are exactly 3 tokens and the password is longer than 28 characters (min length of BCrypt salt = the pass is hashed) - then take it into consideration
        {
          listOfUsers.add(line);
        }
        else{
          continue;
        }

        if(username.toLowerCase() == tokens.elementAt(1).toLowerCase() || email.toLowerCase() == tokens.elementAt(0).toLowerCase())
        {
          foundUser = true;
          break;
        }
      }
    });

    if(foundUser) //  If the User already exists in the users file on the cloud
    {
      _showSnackbar("User already registered.", Colors.red.shade400);
      setState(() => _isLoading = false);
      return;
    }
    
    userToRegister.setUser(
      newUsername: username,
      newEmail: email,
      newPassword: await hashedPassword);
    
    listOfUsers.add(userToRegister.toString());
    
    listOfUsers=listOfUsers..sort((u1,u2) => u1.split(",").elementAt(1).compareTo(u2.split(",").elementAt(1))); //  Sort by Username

    String listOfUsersString = listOfUsers.join('\n');
    List<int> listOfUsersCodeUnits = utf8.encode(listOfUsersString); //Used to create a proper Uint8List to send to method

    bool isUserCreated = false;

     await b2service.bucketExists(username.toLowerCase()).then((bool exists) async {
      if(exists){
        print("Bucket already exists");
      }
      else{
        return await b2service.createBucket(username.toLowerCase());
      }
    },
    onError: (e) => {
      print("Some unknown error happened, don't even know why: $e")
      
    })
    .then( (bool? isCreated)  {
      if(isCreated == true){
        isUserCreated = true;
        //_showSnackbar("Successfully registered User: $username!", Colors.green.shade300);
      }
      else{
        
        _showSnackbar("An error occured during registration!", Colors.red.shade400);
      }
    });

    await b2service.uploadFileFromBytes(
      Uint8List.fromList(listOfUsersCodeUnits),
      b2service.userbaseBucket.toString(),
      b2service.userbaseObject.toString(),
      contentType: "text/csv"
    ).then(
      (bool value) => {
        if(value == true)
        {
          //_showSnackbar("User successfully registered!", Colors.green.shade300)
        }
      },
      onError: (e) {
          _showSnackbar("An Error occured: Couldn't register User", Colors.red.shade400);
          setState(() => _isLoading = false); // Stop loading
          return;
      }
    );
    
     if(isUserCreated == true)
     {
        _showSnackbar("Successfully registered User: $username!", Colors.green.shade300);
     }
      setState(() => _isLoading = false); // Stop loading
    // Redirect to previous page after 2 seconds
    Future.delayed(Duration(seconds: 1, milliseconds: 400), () {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context)=> const StartPageWidget())); // Assuming previous screen is Starting Screen
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _registerUser();
    }
  }

void _showSnackbar(String message, Color color) {
  if (!mounted) return; // Ensure the widget is still active
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: color,),
  );
}

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 228, 58, 11),
            theme.primaryColorDark
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
                  decoration: BoxDecoration(
                    color: theme.dialogBackgroundColor,
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
                      Material(
                      color: Colors.transparent, // Added just not to add another background color layer
                      child: InkWell(
                        onTap: _isLoading ? null : _submit, // Disables click while loading
                        borderRadius: BorderRadius.circular(30), 
                        splashColor: (theme.brightness == Brightness.light) ? Colors.black87 : theme.splashColor,
                        highlightColor: Colors.transparent, 
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color.fromARGB(255, 228, 58, 11),
                              (theme.brightness == Brightness.light) ? Color.fromARGB(235, 245, 145, 30) : Color.fromARGB(174, 50, 20, 5),
                            ]),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
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
                    ),                  
                    SizedBox(height: MediaQuery.of(context).size.height / 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                          Text("Already have an account?",
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500
                          ),
                            ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageWidget()));
                            },
                            child: Text("SIGN IN",
                            style: TextStyle(
                              color: (theme.brightness == Brightness.dark) ? Colors.lightBlue : Colors.blue.shade700,
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
