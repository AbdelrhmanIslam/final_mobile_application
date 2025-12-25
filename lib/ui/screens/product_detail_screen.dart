import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../models/product_model.dart';
import '../../core/cart_service.dart';
import 'cart_screen.dart';
import 'review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = "L";
  final List<String> _sizes = ["S", "M", "L", "XL", "2XL"];
  final CartService _cartService = CartService();

  // 1. Dynamic Price Logic
  double get _currentPrice {
    double base = widget.product.price;
    int index = _sizes.indexOf(_selectedSize);
    // Mock logic: +$5 for every size up
    return base + (index * 5);
  }

  @override
  Widget build(BuildContext context) {
    // 2. Theme Colors
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: cardColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: cardColor,
              child: IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: textColor),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Area
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              color: LazaColors.lightBg,
              child: CachedNetworkImage(
                imageUrl: widget.product.images.isNotEmpty ? widget.product.images[0] : "",
                fit: BoxFit.cover,
                errorWidget: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),

            // Details Sheet
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor, // Adapts to Dark Mode
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product.category, style: const TextStyle(color: LazaColors.grey, fontSize: 13)),
                            const SizedBox(height: 5),
                            Text(widget.product.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Price", style: TextStyle(color: LazaColors.grey, fontSize: 13)),
                          // 3. Use Dynamic Price Here
                          Text("\$${_currentPrice.toStringAsFixed(0)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text("Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _sizes.map((size) {
                      bool isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? LazaColors.primary : cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(size, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textColor))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
                  const SizedBox(height: 10),
                  Text(widget.product.description, style: const TextStyle(color: LazaColors.grey, height: 1.5)),
                  const SizedBox(height: 20),

                  // Reviews Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ReviewScreen())),
                        child: const Text("View All", style: TextStyle(color: LazaColors.grey)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: bgColor,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adding to Cart...")));
              await _cartService.addToCart(widget.product, _selectedSize);
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${widget.product.title}!"), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}