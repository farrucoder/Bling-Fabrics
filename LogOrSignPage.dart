import 'package:blingfabrics/CMS/Pages/ManageCategoriesdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Model/Products.dart';
import '../../../Provider/Productdata.dart';

class Logorsignpage extends StatelessWidget {
  Logorsignpage({super.key});

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Log or Sign in'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            Container(
              height: 50,
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black12,
              )),
              child: TextField(
                controller: email,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  label: Text('Email'),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 50,
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black12,
              )),
              child: TextField(
                controller: password,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  label: Text('Password'),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              height: 40,
              width: 300,
              child: TextButton(
                onPressed: () {

                  if ('blingadmine@gmail.com' == email.text.trim() &&
                      'Bling@123' == password.text.trim()) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Managecategoriesdata()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Entered Wrong!')));
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Log in'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
