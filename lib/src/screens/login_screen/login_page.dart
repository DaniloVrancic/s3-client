import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/home_page/home_page.dart';
import 'package:s3_client/src/screens/register_screen/register_page.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}



class _LoginPageWidgetState extends State<LoginPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late String userBucket;

  bool _isLoading = false;

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 6) {
      return 'Username must be at least 6 characters';
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

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    String loginUsername = _usernameController.text.trim();
    String loginPassword = _passwordController.text;
    

    BackblazeService b2service = context.read<BackblazeService>(); //Gets the S3 Compatible Service From the context (Initialized at Start in main method)
    User loggedUser = context.read<User>();
    
    List<String> listOfUsers = [];
    await b2service.fetchUserbase()
    .then<List<String>?>((List<String> userStringList) { //Parses through all the users in the listOfUsers, return the tokens of the found user, or null if the user hasn't been found
      for(String line in userStringList)
      {
        listOfUsers.addAll(userStringList);
        List<String> tokens = line.split(",");
        if(tokens.length != 3)
        {
          continue;
        }

        if(loginUsername == tokens.elementAt(1) || loginUsername == tokens.elementAt(0))
        {
          return tokens;
        }
      }
      return null;
    },
    onError: (e) => {
      SnackbarShower.showSnackbar(
        context: context,
        message: 'Something went wrong with connecting to the server!',
        color: Colors.red.shade400
        )
    })
    .then((List<String>? foundUser) { //List<String>? foundUser are the tokens of the found user given in order of email/username/hashedPassword, attempts to login with the password and (username or email)
      if(foundUser != null && foundUser.length == 3)
      {
        String? foundEmail = foundUser.elementAtOrNull(0);
        String? foundUsername = foundUser.elementAtOrNull(1);
        String? foundPassword = foundUser.elementAtOrNull(2);

        if(foundEmail != null && foundUsername != null && foundPassword != null)
        {
          User foundUserObj = User.fromInfo(username: foundUsername, email: foundEmail, password: foundPassword);
          bool isPasswordValid = foundUserObj.verifyPassword(loginPassword, foundUserObj.password);

          if(isPasswordValid)
          {
            loggedUser.setUser(newUsername: foundUsername, newEmail: foundEmail, newPassword: foundPassword);
            SnackbarShower.showSnackbar(
                            context: context,
                            message: 'Login successful!',
                            color: Colors.green.shade300
                            );

                 Future.delayed(Duration(seconds: 1), () {
                    Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context)=> const HomePageWidget())); // Assuming previous screen is Starting Screen
                  });
            
          }
          else{
            SnackbarShower.showSnackbar(
                            context: context,
                            message: 'Login failed.',
                            color: Colors.red.shade400
                            );
            return;
          }
        }
        else{
         SnackbarShower.showSnackbar(
                            context: context,
                            message: 'Corrupted user info.',
                            color: Colors.red.shade400
                            );
          return;
        }
      }
      else{
        SnackbarShower.showSnackbar(
                            context: context,
                            message: "That username or E-mail haven't been found.",
                            color: Colors.red.shade400
                            );
        return;
      }
    },
      onError: (e) {
        SnackbarShower.showSnackbar(
        context: context,
        message: 'An unexpected error happened.',
        color: Colors.red.shade400
        );
        return;
    });

      if(!loggedUser.isLoggedIn())
      {
        setState(() => _isLoading = false);
        return;
      }

      this.userBucket = "${loggedUser.username.toLowerCase()}-b2---${loggedUser.username.toLowerCase()}";

      await b2service.bucketExists(userBucket) //Make sure the bucket exists if the user is logging in
      .then((bool exists) async {
      if(exists){
        return;
      }
      else{
        await b2service.createBucket(userBucket).then((bool isCreated) {
          print("Is Bucket now successfully created? : $isCreated}");
          setState(() => _isLoading = false);
          });
      }
    },
    onError: (e) => print(e));
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process the Form
      
        _loginUser();

    }
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 50.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 228, 58, 11),
            theme.primaryColorDark
          ])
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  "Sign in to your account!",
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
                     color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _submit,
                        borderRadius: BorderRadius.circular(30), // Matches the container's border radius
                        splashColor: (theme.brightness == Brightness.light) ? Colors.black87 : theme.splashColor, 
                        highlightColor: Colors.transparent, // Prevents unwanted highlights
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
                            ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                            : Text(
                              "LOG IN",
                              style: TextStyle(
                                color: (theme.brightness == Brightness.light) ? theme.primaryColorLight : Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                          Text("Don't have an account?",
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500
                          ),
                            ),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPageWidget()));
                            },
                            child: Text("SIGN UP",
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