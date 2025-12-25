import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import '../../core/app_colors.dart';
import '../../core/api_service.dart';
import '../../models/product_model.dart';
import 'product_detail_screen.dart';
import '../../core/favorites_service.dart';
import 'cart_screen.dart';
import '../widgets/laza_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _selectedBrand = "All";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.fetchProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
        });
      }
    } catch (e) {}
  }

  void _filterByBrand(String brand) {
    setState(() {
      _selectedBrand = brand;
      _searchController.clear();
      if (brand == "All") {
        _filteredProducts = _allProducts;
      } else if (brand == "Electro") {
        _filteredProducts = _allProducts.where((p) => p.category.toLowerCase().contains("electronic")).toList();
      } else {
        // Smart filter for clothing brands
        _filteredProducts = _allProducts.where((p) =>
        p.category.toLowerCase().contains("cloth") || p.category.toLowerCase().contains("shoe")
        ).toList();
      }
    });
  }

  void _searchFilter(String query) {
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _startVoiceSearch() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final textColor = Theme.of(context).textTheme.bodyLarge?.color;
        final cardColor = Theme.of(context).cardColor;
        return AlertDialog(
          backgroundColor: cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, size: 50, color: LazaColors.primary),
              const SizedBox(height: 20),
              Text("Listening...", style: TextStyle(color: textColor, fontSize: 18)),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        List<String> terms = ["Hoodie", "Nike", "Shoes", "Shirt", "Classic"];
        String result = terms[Random().nextInt(terms.length)];
        setState(() {
          _searchController.text = result;
          _searchFilter(result);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const LazaDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: CircleAvatar(
            backgroundColor: cardColor,
            child: IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
            const Text("Welcome to Laza.", style: TextStyle(fontSize: 15, color: LazaColors.grey)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: LazaColors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchFilter,
                            style: TextStyle(color: textColor),
                            decoration: const InputDecoration(hintText: "Search...", border: InputBorder.none, hintStyle: TextStyle(color: LazaColors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: _startVoiceSearch,
                  child: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(color: LazaColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Choose Brand", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                TextButton(
                    onPressed: () => setState(() { _selectedBrand = "All"; _searchController.clear(); _loadProducts(); }),
                    child: const Text("View All", style: TextStyle(color: LazaColors.grey))
                ),
              ],
            ),

            // --- BRAND LOGOS (USING LOCAL ASSETS) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBrandIcon("Adidas", "assets/icons/adidas.png", isDark),
                  const SizedBox(width: 10),
                  _buildBrandIcon("Nike", "assets/icons/nike.png", isDark),
                  const SizedBox(width: 10),
                  _buildBrandIcon("Fila", "assets/icons/fila.png", isDark),
                  const SizedBox(width: 10),
                  _buildBrandIcon("Puma", "assets/icons/puma.png", isDark),
                  const SizedBox(width: 10),
                  _buildBrandIcon("Electro", "", isDark), // Special case for icon
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("New Arraival", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: LazaColors.grey))),
              ],
            ),

            if (_filteredProducts.isEmpty && _allProducts.isNotEmpty)
              Center(child: Padding(padding: const EdgeInsets.only(top: 50), child: Text("No products found", style: TextStyle(color: textColor))))
            else if (_allProducts.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator()))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 15, mainAxisSpacing: 15),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return StreamBuilder<bool>(
                      stream: FavoritesService().isFavorite(product.id),
                      builder: (context, favSnapshot) {
                        bool isLiked = favSnapshot.data ?? false;
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: product.images.isNotEmpty ? product.images[0] : "",
                                          fit: BoxFit.cover,
                                          width: double.infinity, height: double.infinity,
                                          errorWidget: (c,u,e) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10, right: 10,
                                        child: GestureDetector(
                                          onTap: () => FavoritesService().toggleFavorite(product),
                                          child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : LazaColors.grey),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: textColor)),
                              Text("\$${product.price}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                            ],
                          ),
                        );
                      }
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandIcon(String name, String assetPath, bool isDark) {
    bool isSelected = _selectedBrand == name;

    return GestureDetector(
      onTap: () => _filterByBrand(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? LazaColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
              child: name == "Electro"
                  ? Icon(Icons.electrical_services, size: 24, color: isDark ? Colors.white : Colors.black)
                  : Image.asset(
                assetPath, // Use Local Asset
                fit: BoxFit.contain,
                // AUTO COLOR: Forces white in dark mode, black in light mode
                color: isDark ? Colors.white : Colors.black,
                errorBuilder: (c,e,s) => Icon(Icons.branding_watermark, color: isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(width: 10),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }
}