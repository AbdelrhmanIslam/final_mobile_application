import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/favorites_service.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. GET THEME COLORS (This makes Dark Mode work)
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor, // Dynamic Background
      appBar: AppBar(
        title: Text("Wishlist", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: cardColor, // <--- Dark Circle in Dark Mode
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor), // <--- White Arrow in Dark Mode
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoritesService().getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No favorites yet.", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Adjusted to fit content better
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index].data() as Map<String, dynamic>;
              final docId = items[index].id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image & Remove Button
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor, // <--- Product BG matches Dark Mode
                            borderRadius: BorderRadius.circular(15),
                          ),
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: data['image'],
                              fit: BoxFit.cover,
                              errorWidget: (c,u,e) => const Center(child: Icon(Icons.error)),
                            ),
                          ),
                        ),
                        // Remove Button (Top Right)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: cardColor, // <--- Dark Circle
                            radius: 15,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 18, color: Colors.red),
                              onPressed: () {
                                // Delete from favorites
                                FirebaseFirestore.instance
                                    .collection('favorites')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('items')
                                    .doc(docId)
                                    .delete();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: textColor), // Dynamic Text
                  ),
                  Text(
                    "\$${data['price']}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), // Dynamic Text
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}