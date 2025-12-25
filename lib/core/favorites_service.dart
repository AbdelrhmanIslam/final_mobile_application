import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Toggle Favorite (Add or Remove)
  Future<void> toggleFavorite(Product product) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .doc(product.id.toString());

    final doc = await docRef.get();

    if (doc.exists) {
      // If it exists, remove it (Unlike)
      await docRef.delete();
    } else {
      // If not, add it (Like)
      await docRef.set({
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.images.isNotEmpty ? product.images[0] : '',
        'category': product.category,
        'addedAt': DateTime.now(),
      });
    }
  }

  // 2. Check if an item is favorited
  Stream<bool> isFavorite(int productId) {
    User? user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .doc(productId.toString())
        .snapshots()
        .map((doc) => doc.exists);
  }

  // 3. Get All Favorites
  Stream<QuerySnapshot> getFavoritesStream() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}