import 'package:blingfabrics/Model/Products.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/Productdata.dart';

class Manageproductdata extends StatefulWidget {
  Manageproductdata(
      {super.key, required this.CategoryName, required this.CategoryProducts});


  final CategoryName;
  List<Product>? CategoryProducts;

  @override
  State<Manageproductdata> createState() => _ManageproductdataState();
}

class _ManageproductdataState extends State<Manageproductdata> {

  TextEditingController nameController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  TextEditingController priceController = TextEditingController();

  List<PlatformFile> selectedFiles = [];

  Future<List<PlatformFile>?> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true, // this is important for web
    );

    if (result != null) {
      setState(() {
        //selectedFiles = result.paths.map((path) => File(path!)).toList();
        selectedFiles = result.files;
      });
    }
  }

  Future<void> uploadProduct() async {
    if (selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select at least one image')));
      return;
    }

    Product p = Product(
      name: nameController.text.trim(),
      imagePath: '', // not used directly in list
      description: descriptionController.text.trim(),
      price: priceController.text,
    );

    await Provider.of<Productdata>(context, listen: false)
        .addProduct(selectedFiles, p, widget.CategoryName);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<Productdata>(context);

    return Scaffold(
      appBar: AppBar(
        title:Text(
          '${widget.CategoryName} of Products : ${widget.CategoryProducts!.length}',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{

      await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20),
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
              TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
              SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 ElevatedButton(onPressed: pickFiles, child: Text("Pick Images")),
                 SizedBox(height: 5),
                 ElevatedButton(onPressed: uploadProduct, child: categoryProvider.isLoading ? Center(child: CircularProgressIndicator(),) : Text("Upload Product")),
               ],
             ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      );

        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
                itemCount: widget.CategoryProducts!.length,
                itemBuilder: (context, index) {
                  final product = widget.CategoryProducts![index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      height: 100,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(error);
                                  return Icon(Icons.broken_image);  // Show broken image icon if the image fails to load
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product.price}'),
                              Text(
                                '${product.description}',
                                softWrap: true,
                                maxLines: 2,
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                categoryProvider.deleteProduct(
                                    widget.CategoryName,
                                   widget.CategoryProducts![index]);
                              },
                              icon: Icon(Icons.delete)),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
