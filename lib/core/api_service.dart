import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // This is the URL from your project requirements
  static const String baseUrl = "https://api.escuelajs.co/api/v1/products";

  // This function fetches the data
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // If the server says "OK" (200), we parse the data
        final List<dynamic> data = json.decode(response.body);

        // Convert the list of JSON objects into a list of Products
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }
}