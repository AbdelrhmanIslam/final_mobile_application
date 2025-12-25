import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // --- ADDRESS ---
  // Save Address to the User's Profile
  Future<void> saveAddress(String name, String country, String city, String phone, String address) async {
    if (uid == null) return;

    // We save it inside the 'users' collection so it sticks to the account
    await _firestore.collection('users').doc(uid).set({
      'shipping_address': {
        'name': name,
        'country': country,
        'city': city,
        'phone': phone,
        'address': address,
      }
    }, SetOptions(merge: true)); // Merge ensures we don't delete other info
  }

  // Listen to Address Changes
  Stream<DocumentSnapshot> getAddressStream() {
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // --- CARDS ---
  // Add a new card to the sub-collection
  Future<void> addCard(String owner, String number, String exp, String cvv, int type) async {
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('cards').add({
      'owner': owner,
      'number': number,
      'exp': exp,
      'cvv': cvv,
      'type': type, // 0=Master, 1=Paypal, 2=Bank
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Listen to Cards
  Stream<QuerySnapshot> getCardsStream() {
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).collection('cards').orderBy('addedAt', descending: true).snapshots();
  }
}