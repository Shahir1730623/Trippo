import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}) );
    emailTextEditingController.addListener(() => setState(() {}) );
    phoneTextEditingController.addListener(() => setState(() {}) );

  }

  saveUserInfo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Processing, Please wait");
        }
    );

    final User? firebaseUser = (
        await firebaseAuth.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password:passwordTextEditingController.text.trim()
        ).catchError((message){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + message);
        })
    ).user;

    if(firebaseUser != null){
      Map userMap = {
        'id' : firebaseUser.uid,
        'name' : nameTextEditingController.text.trim(),
        'email' : emailTextEditingController.text.trim(),
        'phone' : phoneTextEditingController.text.trim()
      };
      
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('Users');
      databaseReference.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been created");
      Navigator.pushNamed(context, '/');

    }

    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created");
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
                    "Register as an User",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name Field
                  TextFormField(
                    controller: nameTextEditingController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
                      prefixIcon: const Icon(Icons.person),

                      suffixIcon: nameTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => nameTextEditingController.clear(),
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

                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      }

                      else
                        return null;
                    },
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
                      suffixIcon: emailTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                            icon: Icon(Icons.close),
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

                  // Phone Field
                  TextFormField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Phone Number",

                      prefixIcon: Icon(Icons.phone),
                      suffixIcon: phoneTextEditingController.text.isEmpty
                        ? Container(width: 0)
                        : IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => phoneTextEditingController.clear()
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
                      if (value!.isEmpty) {
                        return "The field is empty";
                      }

                      else if (value.length != 11) {
                        return "Enter Correct Number";
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
                      prefixIcon: const Icon(Icons.lock),
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
                      if (value!.isEmpty) {
                        return "The field is empty";
                      }

                      else if (value.length < 6) {
                        return "Password too short";
                      }

                      else
                        return null;
                    },



                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.black),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveUserInfo();
                        }
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),

                  TextButton(
                      onPressed: (){
                        Navigator.pushNamed(context, '/login_screen');
                      },
                      child: const Text(
                        "Already have an account? Login Now",
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
