
class Product {
  String name;
   String price;
   String imagePath;
   String description;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      imagePath: json['imagePath'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'price': price,
    'imagePath': imagePath,
    'description': description,
  };

}
