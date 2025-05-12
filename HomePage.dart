import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../CMS/Pages/Auth/LogOrSignPage.dart';
import '../Provider/Productdata.dart';
import '../ReusableWidget/FullImageView.dart';
import 'SignIn.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

 String? selectedCategory;

  bool? loading;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    loading = true;
    final productProvider = Provider.of<Productdata>(context, listen: false);
    await productProvider.fetchProductsFromFirestore();

    if (productProvider.categoryProducts.keys.isNotEmpty) {
      setState(() {
        selectedCategory = productProvider.categoryProducts.keys.first;
      });
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<Productdata>(context);
    final currentProducts =
    selectedCategory != null
        ? categoryProvider.categoryProducts[selectedCategory] ?? []
        : [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            final result = await showDialog(
              context: context,
              builder: (context) => SignInDialog(),
            );

            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Signed in successfully!')),
              );
            }
          } else {
            final number = '9702572423';
            final message = "Hi, I am interested in your product.";
            final url = Uri.parse("https://wa.me/$number?text=$message");

            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch WhatsApp')),
              );
            }
          }
        },
        child: Icon(Icons.messenger_outline),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Bling Fabrics',
          style: GoogleFonts.bodoniModa(color: Colors.pink[400]),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              onDoubleTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Logorsignpage()));
              },
              child: Icon(CupertinoIcons.heart),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                      items: categoryProvider.categoryProducts.keys
                          .toSet()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.aBeeZee(
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              if (selectedCategory != null)
                Text(
                  selectedCategory!,
                  style: GoogleFonts.aBeeZee(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: loading! ? Center(child: CircularProgressIndicator()):GridView.builder(
                  itemCount: currentProducts.length,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = currentProducts[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            FullImageScreen(
                                                imagePath:
                                                product.imagePath),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    product.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                        Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rs. ${product.price.toString()}',
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 17),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  product.description,
                                  maxLines: 3,
                                  style: GoogleFonts.lato(
                                      fontSize: 15),
                                ),
                                SizedBox(height: 5),
                                InkWell(
                                  onTap: () async {
                                    final user = FirebaseAuth
                                        .instance.currentUser;

                                    if (user == null) {
                                      final result =
                                      await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            SignInDialog(),
                                      );

                                      if (result == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                            content: Text(
                                                'Signed in successfully!')));
                                      }
                                    } else {
                                      final number = '9702572423';
                                      final message =
                                          "Hi, I am interested in your product,\n$selectedCategory\n${product
                                          .description}\n${product.price}";
                                      final url = Uri.parse(
                                          "https://wa.me/$number?text=$message");

                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                            content: Text(
                                                'Could not launch WhatsApp')));
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.black),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Buy Now',
                                        style: GoogleFonts.raleway(
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
