import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_school/admin/adminHome.dart';
import 'package:happy_school/user/userHome.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordvisible = true;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/loginpage.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: TextField(
                      controller: _password,
                      obscureText: passwordvisible,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        focusColor: Colors.orange,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                passwordvisible = !passwordvisible;
                              });
                            },
                            child: Icon(passwordvisible == false
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _email.text, password: _password.text);
                        setState(() {
                          isLoading = false;
                        });
                        if (_email.text == "happyschoolculture@gmail.com") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Adminhome()));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Userhome()));
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              if (e.code == "channel-error") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Please enter a valid email address'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "user-not-found") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Password should be atleast 6 characters long'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "wrong-password") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'The password is invalid or the user does not have a password'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              if (e.code == "network-request-failed") {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'Please check your internet connection'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              }
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Text(e.code),
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
                                color: Color.fromARGB(80, 0, 0, 0),
                                blurRadius: 3.0,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0, 3.0),
                              )
                            ],
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 255, 131, 7),
                                Color.fromARGB(255, 255, 141, 48)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Login',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
