import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add to Cart
  Future<void> addToCart(Product product, String size) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('carts').doc(user.uid).collection('items').doc(product.id.toString());
    final doc = await docRef.get();

    if (doc.exists) {
      int currentQty = doc.data()?['quantity'] ?? 0;
      await docRef.update({'quantity': currentQty + 1});
    } else {
      await docRef.set({
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.images.isNotEmpty ? product.images[0] : '',
        'size': size,
        'quantity': 1,
        'addedAt': DateTime.now(),
      });
    }
  }

  // Update Quantity
  Future<void> updateQuantity(String productId, int change) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('carts').doc(user.uid).collection('items').doc(productId);
    final doc = await docRef.get();

    if (doc.exists) {
      int currentQty = doc.data()?['quantity'] ?? 1;
      int newQty = currentQty + change;
      if (newQty < 1) {
        await removeFromCart(productId);
      } else {
        await docRef.update({'quantity': newQty});
      }
    }
  }

  // Remove Item
  Future<void> removeFromCart(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('carts').doc(user.uid).collection('items').doc(productId).delete();
  }

  // Get Cart Stream
  Stream<QuerySnapshot> getCartStream() {
    User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('carts').doc(user.uid).collection('items').orderBy('addedAt', descending: true).snapshots();
  }

  // --- NEW CHECKOUT LOGIC ---
  Future<void> checkout() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // 1. Get all items currently in the cart
    var cartCollection = _firestore.collection('carts').doc(user.uid).collection('items');
    var snapshot = await cartCollection.get();

    if (snapshot.docs.isEmpty) return; // Don't checkout empty cart

    double total = 0;
    int itemCount = 0;
    List<Map<String, dynamic>> orderItems = [];

    for (var doc in snapshot.docs) {
      var data = doc.data();
      total += (data['price'] as num) * (data['quantity'] as num);
      itemCount += (data['quantity'] as num).toInt();
      orderItems.add(data);
    }

    // 2. Create a new Order Document in 'orders' collection
    await _firestore.collection('orders').doc(user.uid).collection('history').add({
      'totalAmount': total,
      'itemCount': itemCount,
      'status': 'Delivered', // For MVP we assume instant delivery
      'orderDate': DateTime.now(),
      'items': orderItems,
      'orderId': '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' // Generate pseudo ID
    });

    // 3. Clear the Cart
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}