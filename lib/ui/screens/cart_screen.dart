import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/cart_service.dart';
import '../../core/user_service.dart';
import 'order_success_screen.dart';
import 'address_screen.dart';
import 'payment_screen.dart';

// CHANGED TO STATEFUL WIDGET TO REMEMBER SELECTION
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Variable to store the manually selected card
  Map<String, dynamic>? _selectedCardData;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Cart", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CartService().getCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Your cart is empty", style: TextStyle(color: textColor)));

          final cartItems = snapshot.data!.docs;
          double totalPrice = 0;
          for (var item in cartItems) {
            double price = (item['price'] as num).toDouble();
            int qty = (item['quantity'] as num).toInt();
            totalPrice += price * qty;
          }

          return Column(
            children: [
              // List of Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index].data() as Map<String, dynamic>;
                    final docId = cartItems[index].id;
                    int qty = data['quantity'] ?? 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          Container(
                            height: 80, width: 80,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: data['image'], fit: BoxFit.cover)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                                const SizedBox(height: 5),
                                Text("\$${data['price']}", style: const TextStyle(color: LazaColors.grey, fontSize: 11)),
                                const SizedBox(height: 10),
                                Row(children: [
                                  _qtyBtn(Icons.remove, () => CartService().updateQuantity(docId, -1), context),
                                  const SizedBox(width: 15),
                                  Text("$qty", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                  const SizedBox(width: 15),
                                  _qtyBtn(Icons.add, () => CartService().updateQuantity(docId, 1), context),
                                ])
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.delete_outline, color: LazaColors.grey), onPressed: () => CartService().removeFromCart(docId))
                        ],
                      ),
                    );
                  },
                ),
              ),

              // DELIVERY & PAYMENT SECTION
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ADDRESS STREAM
                    StreamBuilder<DocumentSnapshot>(
                        stream: UserService().getAddressStream(),
                        builder: (context, addrSnapshot) {
                          String addrText = "Add Address";
                          if (addrSnapshot.hasData && addrSnapshot.data!.exists) {
                            final data = addrSnapshot.data!.data() as Map<String, dynamic>?;
                            if (data != null && data.containsKey('shipping_address')) {
                              final addr = data['shipping_address'];
                              addrText = "${addr['address']}, ${addr['city']}";
                            }
                          }
                          return _infoRow("Delivery Address", addrText, Icons.map, context, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddressScreen())));
                        }
                    ),
                    const SizedBox(height: 15),

                    // CARD SELECTION LOGIC
                    // 1. If user selected a card, show it.
                    // 2. If not, check Firebase for any card.
                    // 3. If none, show "Add Payment Method".
                    Builder(
                        builder: (context) {
                          if (_selectedCardData != null) {
                            // Show Manually Selected Card
                            return _infoRow("Payment Method", "${_selectedCardData!['type']} ${_selectedCardData!['number']}", Icons.payment, context, _openPaymentSelection);
                          } else {
                            // Fallback to Database
                            return StreamBuilder<QuerySnapshot>(
                                stream: UserService().getCardsStream(),
                                builder: (context, cardSnapshot) {
                                  String cardText = "Add Payment Method";
                                  if (cardSnapshot.hasData && cardSnapshot.data!.docs.isNotEmpty) {
                                    final data = cardSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                    String num = data['number'].toString();
                                    String type = (data['type'] == 1) ? "Paypal" : (data['type'] == 2 ? "Bank" : "Visa");
                                    cardText = "$type **** ${num.length > 4 ? num.substring(num.length-4) : '0000'}";
                                  }
                                  return _infoRow("Payment Method", cardText, Icons.payment, context, _openPaymentSelection);
                                }
                            );
                          }
                        }
                    ),

                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)), Text("\$${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: LazaColors.primary))]),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async { await CartService().checkout(); if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const OrderSuccessScreen())); }, style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary), child: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // New function to handle selection
  void _openPaymentSelection() async {
    // Wait for the result from PaymentSelectionScreen
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const PaymentSelectionScreen())
    );

    // If a card was picked, update state
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedCardData = result;
      });
    }
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: LazaColors.grey.withOpacity(0.3))), child: Icon(icon, size: 15, color: Theme.of(context).iconTheme.color)));
  }

  Widget _infoRow(String title, String subtitle, IconData icon, BuildContext context, VoidCallback onTap) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return GestureDetector(onTap: onTap, child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: LazaColors.lightBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: LazaColors.primary)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)), Text(subtitle, style: const TextStyle(color: LazaColors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)])), const Icon(Icons.arrow_forward_ios, size: 14, color: LazaColors.grey)]));
  }
}