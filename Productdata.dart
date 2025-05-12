import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../Model/Products.dart';



class Productdata extends ChangeNotifier {


  final Map<String, List<Product>> _categoryProducts = { };

  bool isLoading = false;


  Map<String, List<Product>> get categoryProducts => _categoryProducts;

  Future<void> fetchProductsFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final categoriesSnapshot = await firestore.collection('products').get();

    _categoryProducts.clear();

    for (var categoryDoc in categoriesSnapshot.docs) {
      final categoryName = categoryDoc.id;

      final itemsSnapshot = await firestore
          .collection('products')
          .doc(categoryName)
          .collection('items')
          .get();

      List<Product> products = itemsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          name: data['name'] ?? '',
          price: data['price'] ?? '',
          imagePath: data['imagePath'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();

      _categoryProducts[categoryName] = products;
    }

    notifyListeners();
  }


  Future<void> addProduct(List<PlatformFile> files, Product p, String targetCategory) async {
    isLoading = true;
    if (_categoryProducts.containsKey(targetCategory)) {
      final firestore = FirebaseFirestore.instance;
      final categoryDoc = firestore.collection('products').doc(targetCategory);
      final itemsCollection = categoryDoc.collection('items');

      List<String> imageUrls = [];

      for (var file in files) {
        if (file.bytes != null) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('ProductsImages')
              .child(targetCategory)
              .child('$fileName.jpg');

          // Upload using bytes (required for web)
          UploadTask uploadTask = storageRef.putData(
            file.bytes!,
            SettableMetadata(contentType: 'image/png'),
          );

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);

          // Create product with image URL
          Product singleImageProduct = Product(
            name: p.name,
            imagePath: downloadUrl,
            description: p.description,
            price: p.price,
          );

          await itemsCollection.add(singleImageProduct.toJson());
          _categoryProducts[targetCategory]!.add(singleImageProduct);
        }
      }
      isLoading = false;
      notifyListeners();
    }
  }



  void addCategory(String targetCategory) async {
     if (_categoryProducts.containsKey(targetCategory)) {
       return;
     } else {
       _categoryProducts[targetCategory] = [];

       // ✅ Create category document in Firestore
       final firestore = FirebaseFirestore.instance;
       await firestore.collection('products').doc(targetCategory).set({});

       // ✅ Pick one file to act as a placeholder (optional)
       // FilePickerResult? result = await FilePicker.platform.pickFiles(
       //   allowMultiple: false, // only one for placeholder
       //   type: FileType.image, // restrict to images
       // );
       //
       // if (result != null && result.files.single.path != null) {
       //   final fileBytes = result.files.single.bytes!;
       //   final fileName = result.files.single.name;
       //   File file = File(result.files.single.path!);

         final storageRef = FirebaseStorage.instance
             .ref()
             .child('ProductsImages')
             .child(targetCategory)
             .child('test.txt');

         await storageRef.putString('test.txt');

       notifyListeners();
     }
   }


  Future<void> deleteCategory(String categoryName) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      // Delete Firestore subcollection items
      final categoryDoc = firestore.collection('products').doc(categoryName);
      final itemsCollection = categoryDoc.collection('items');
      final itemsSnapshot = await itemsCollection.get();

      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the category document
      await categoryDoc.delete();

      // Delete images from Firebase Storage
      final storageRef = storage.ref().child('ProductsImages').child(categoryName);
      final ListResult listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        await item.delete();
      }

      // Remove from local state
      if (_categoryProducts.containsKey(categoryName)) {
        _categoryProducts.remove(categoryName);
      }

      notifyListeners();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }


  Future<void> deleteProduct(String categoryName, Product product) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      // 1. Delete from Firestore
      final itemsCollection = firestore
          .collection('products')
          .doc(categoryName)
          .collection('items');

      final querySnapshot = await itemsCollection
          .where('name', isEqualTo: product.name)
          .where('description', isEqualTo: product.description)
          .where('price', isEqualTo: product.price)
          .where('imagePath', isEqualTo: product.imagePath)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete image from Firebase Storage
      try {
        final imageRef = storage.refFromURL(product.imagePath);
        await imageRef.delete();
      } catch (e) {
        print("Image delete failed (maybe already deleted): $e");
      }

      // 3. Delete from local state
      if (_categoryProducts.containsKey(categoryName)) {
        _categoryProducts[categoryName]!.remove(product);
      }

      notifyListeners();
    } catch (e) {
      print("Error deleting product: $e");
    }
  }




  Future<void> saveStorageImagesToFirestore(String categoryName) async {
    final storageRef = FirebaseStorage.instance.ref('ProductsImages/$categoryName');
    final ListResult result = await storageRef.listAll();

    final firestore = FirebaseFirestore.instance;
    final categoryDoc = firestore.collection('products').doc(categoryName);
    final itemsCollection = categoryDoc.collection('items');

    for (Reference ref in result.items) {
      final downloadUrl = await ref.getDownloadURL();

      // Create a product document with the image URL
      final productData = {
        'name': DateTime.now().toString(),
        'description': '',
        'price': 899,
        'imagePath': downloadUrl,
      };

      await itemsCollection.add(productData);
      print('Added ${ref.name} to Firestore');
    }

    print('All files saved to Firestore!');
  }




// Future<void> uploadCategoryProductsToFirestore() async {
//   final firestore = FirebaseFirestore.instance;
//
//   for (final entry in _categoryProducts.entries) {
//     final category = entry.key;
//     final products = entry.value;
//
//     final categoryDoc = firestore.collection('products').doc(category);
//     final itemsCollection = categoryDoc.collection('items');
//
//     for (final product in products) {
//       await itemsCollection.add(product.toJson());
//     }
//   }

// Future<void> getAllCategoryProducts() async {
//   final firestore = FirebaseFirestore.instance;
//   final categoriesSnapshot = await firestore.collection('products').get();
//
//   Map<String, List<Product>> categoryMap = {};
//
//   for (var categoryDoc in categoriesSnapshot.docs) {
//     final itemsSnapshot = await categoryDoc.reference.collection('items').get();
//     final products = itemsSnapshot.docs
//         .map((doc) => Product.fromJson(doc.data()))
//         .toList();
//
//     categoryMap[categoryDoc.id] = products;
//   }
//
//   _categoryProducts = categoryMap;
//   notifyListeners();
// }
  }

//
// Future<List<File>> pickMultipleImages() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.image,
//     allowMultiple: true,
//   );
//   if (result != null) {
//     return result.paths.map((path) => File(path!)).toList();
//   } else {
//     return [];
//   }
// }
