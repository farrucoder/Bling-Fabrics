import 'package:blingfabrics/CMS/Pages/ManageProductdata.dart';
import 'package:blingfabrics/Provider/Productdata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/Products.dart';

class Managecategoriesdata extends StatelessWidget {
  const Managecategoriesdata({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<Productdata>(context);
    final List<String> Categoriesname = categoryProvider.categoryProducts.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Categories',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

      showDialog(
        context: context,
        builder: (context) {
          TextEditingController _controller = TextEditingController();
          return AlertDialog(
              title: Text("Add Category"),
          content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Enter category name"),
          ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _controller.text.trim();
                  if (name.isNotEmpty) {
                    categoryProvider.addCategory(name);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Add"),
              ),
            ],
          );
        },
      );

        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
                itemCount: Categoriesname.length,
                itemBuilder: (contex, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${Categoriesname[index]}',
                            softWrap: true,
                            maxLines: 2,),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                String CategoryName = Categoriesname[index];
                                List<Product>? Currentcategoryproducts =
                                    categoryProvider.categoryProducts[CategoryName];

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (contex) => Manageproductdata(
                                            CategoryName: CategoryName,
                                            CategoryProducts:
                                                Currentcategoryproducts)));
                              },
                              icon: Icon(Icons.add_business_outlined)),
                          SizedBox(width: 20),
                          IconButton(
                              onPressed: () {
                                   categoryProvider.deleteCategory(Categoriesname[index]);
                              }, icon: Icon(Icons.delete)),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
