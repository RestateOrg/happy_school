import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool passwordvisible = true;
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController reenterpassword = TextEditingController();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    reenterpassword.dispose();
    super.dispose();
  }

  String generateRandomPassword() {
    const int passwordLength = 8;
    const String allowedChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';

    Random random = Random();
    String password = '';

    for (int i = 0; i < passwordLength; i++) {
      int randomIndex = random.nextInt(allowedChars.length);
      password += allowedChars[randomIndex];
    }

    return password;
  }

  Future<void> sendEmail(String email, String password) async {
    final smtpServer =
        gmail('happyschoolculture@gmail.com', 'arvr nkpm ects ikco');

    final message = Message()
      ..from = Address('happyschoolculture@gmail.com', 'Happy School')
      ..recipients.add(email)
      ..subject = 'Your Account Details'
      ..text =
          'Welcome! Your account has been created successfully.\n\nEmail: $email\nPassword: $password\n\nPlease keep this information secure.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Image.asset(
                      'assets/images/signup.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Text(
                      'User access',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    controller: emailcontroller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        // Generate the password before making any async calls
                        String generatedPassword = generateRandomPassword();
                        passwordcontroller.text = generatedPassword;

                        // Create the user with the generated password
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: emailcontroller.text,
                                password: generatedPassword);

                        // Store user info in Firestore
                        await firestore
                            .collection("Users")
                            .doc(emailcontroller.text)
                            .collection("userinfo")
                            .doc("userinfo")
                            .set({
                          "email": emailcontroller.text,
                          "type": "user",
                        });

                        // Send email after account creation
                        await sendEmail(
                            emailcontroller.text, generatedPassword);

                        setState(() {
                          isLoading = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              String message;
                              if (e.code == "invalid-email") {
                                message = 'Please enter a valid email address';
                              } else if (e.code == "weak-password") {
                                message =
                                    'Password should be at least 6 characters long';
                              } else if (e.code == "email-already-in-use") {
                                message = 'Email already in use. Please login';
                              } else if (e.code == "network-request-failed") {
                                message =
                                    'Please check your internet connection';
                              } else {
                                message = e.code;
                              }
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Text(message),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ],
                              );
                            });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30),
                      child: Container(
                          width: width,
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(80, 0, 0, 0),
                                blurRadius: 3.0,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0, 3.0),
                              )
                            ],
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 131, 7),
                                Color.fromARGB(255, 255, 141, 48)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
