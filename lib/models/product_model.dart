class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    required this.category,
  });

  // This factory converts the JSON data from the internet into a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      // The API might send price as an Integer, so we force it to Double
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      // The API sends a list of image URLs
      images: List<String>.from(json['images']),
      category: json['category']['name'],
    );
  }
}