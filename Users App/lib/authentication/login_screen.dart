import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/assistants/assistant_methods.dart';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();

    emailTextEditingController.addListener(() => setState(() {}) );
    passwordTextEditingController.addListener(() => setState(() {}) );
  }

  loginUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Logging in");
        }
    );

    final User? firebaseUser = (
        await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password:passwordTextEditingController.text.trim()
        ).catchError((message){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + message);
        })
    ).user;

    if(firebaseUser != null) {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child("Users");
      reference.child(firebaseUser.uid).once().then((userKey) {
        final snapshot = userKey.snapshot;
        if (snapshot.exists) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful");
          Navigator.pushNamed(context, '/');
        }

        else {
          Fluttertoast.showToast(msg: "No User record exist with this credentials");
          firebaseAuth.signOut();
          Navigator.pushNamed(context, '/');
        }
      });
    }

    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Wrong Credentials! Try Again");
    }



  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Image.asset("images/Trippo Logo.png"),

                  const Text(
                    "Login as an User",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",

                      prefixIcon: Icon(Icons.email),
                      suffixIcon: emailTextEditingController.text.isEmpty ?
                          Container(width: 0) :
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => emailTextEditingController.clear(),
                          ),

                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),

                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),
                    ),

                    validator: (value){
                      if(value!.isEmpty){
                        return "The field is empty";
                      }

                      else if (!value.contains('@')) {
                        return "Invalid Email Address";
                      }

                      else
                        return null;
                    },

                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",

                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                          icon: isPasswordVisible ?
                          const Icon(Icons.visibility_off) :
                          const Icon(Icons.visibility),

                          onPressed: () {
                            if(isPasswordVisible == true){
                              setState(() {
                                isPasswordVisible = false;
                              });
                            }

                            else {
                              setState(() {
                                isPasswordVisible = true;
                              });
                            }

                          }

                      ),

                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),
                    ),

                    validator: (value){
                      if (value!.isEmpty) {
                        return "The field is empty";
                      }

                      else
                        return null;
                    },

                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.black
                      ),
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),
                      )
                  ),

                  TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, '/register_screen');
                      },
                      child: const Text(
                        "Don't have an account? Register Now",
                        style: TextStyle(color: Colors.black),
                      )
                  )



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
