import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/user_service.dart';
import 'sidebar_screens.dart'; // Needed for AddNewCardScreen

class PaymentSelectionScreen extends StatelessWidget {
  const PaymentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: UserService().getCardsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No cards saved yet", style: TextStyle(color: textColor)));
                  }

                  final cards = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final data = cards[index].data() as Map<String, dynamic>;

                      // Card Visual Logic
                      Gradient? cardGradient;
                      Color bg = LazaColors.primary;
                      IconData icon = Icons.credit_card;
                      int type = data['type'] ?? 0;
                      String typeName = "VISA";

                      if (type == 0) {
                        cardGradient = const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)]);
                        typeName = "Mastercard";
                      } else if (type == 1) {
                        bg = const Color(0xFF0070BA);
                        icon = Icons.paypal;
                        typeName = "Paypal";
                      } else {
                        bg = const Color(0xFF1D1E20);
                        icon = Icons.account_balance;
                        typeName = "Bank";
                      }

                      String numberStr = data['number'].toString();
                      String maskedNumber = "**** ${numberStr.length > 4 ? numberStr.substring(numberStr.length - 4) : '0000'}";

                      return GestureDetector(
                        onTap: () {
                          // --- THE FIX ---
                          // Send selected data back to Cart
                          Navigator.pop(context, {
                            'type': typeName,
                            'number': maskedNumber,
                            'icon': icon, // We can't pass IconData easily but we pass text
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardGradient == null ? bg : null,
                            gradient: cardGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      typeName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                      maskedNumber,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                                  ),
                                  Text(
                                      data['owner'] ?? "User",
                                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                                  ),
                                ],
                              ),
                              Icon(icon, color: Colors.white, size: 30)
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add New Card Button
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddNewCardScreen(fromCart: true))),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: LazaColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                  color: LazaColors.primary.withOpacity(0.1),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_box_outlined, color: LazaColors.primary),
                    SizedBox(width: 10),
                    Text("Add new card", style: TextStyle(color: LazaColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}