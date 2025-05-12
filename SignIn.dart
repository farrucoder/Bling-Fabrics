import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInDialog extends StatefulWidget {
  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController numberController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Ensure the session persists
    FirebaseAuth.instance.setPersistence(
        Persistence.LOCAL); // Optional, for explicit persistence control.

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
        isLoading = false;
      });
    });

    // Check if a user is already signed in when the app starts
    checkUserAuthentication();
  }

  // Check if the user is already signed in when the page is first loaded
  void checkUserAuthentication() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              controller: numberController,
              decoration: InputDecoration(
                  labelText: 'Number', border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Password', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Center(
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {

                        String name = nameController.text.trim();
                        String number = numberController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (email.isEmpty ||
                            password.isEmpty ||
                            name.isEmpty ||
                            number.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please fill in all fields.')),
                          );
                          return;
                        }

                        if (password.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Password must be at least 8 characters long.')),
                          );
                          return;
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Please enter a valid email address.')),
                          );
                          return;
                        }

                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please enter a valid number.')),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                  email: email.trim(),
                                  password: password.trim());

                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: email, password: password);

                          User? user = userCredential.user;

                          // Save extra data in Firestore or Adding user in firestore..
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user!.uid)
                              .set({
                            'name': name,
                            'number': number,
                            'email': email,
                            'password': password,
                          });
                        } catch (e) {
                          return;
                        } finally {
                          setState(() {
                            Navigator.of(context)
                                .pop(true);
                            isLoading = false;
                          });
                        }
                      },
                      child: Text('Sign In'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
