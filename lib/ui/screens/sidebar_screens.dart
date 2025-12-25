import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/user_service.dart'; // REQUIRED for Cards

// 1. ACCOUNT INFORMATION
class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Account Information", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile("Username", user?.displayName ?? "No Name Set", textColor, cardColor),
            const SizedBox(height: 20),
            _infoTile("Email", user?.email ?? "No Email", textColor, cardColor),
            const SizedBox(height: 20),
            _infoTile("User ID", user?.uid ?? "Error", textColor, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, Color? textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: LazaColors.grey, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
          child: Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}

// 2. CHANGE PASSWORD
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_currentController.text.isEmpty || _newController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if(user != null && user.email != null) {
        // Re-authenticate user to confirm current password
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: _currentController.text);
        await user.reauthenticateWithCredential(credential);

        // Update Password
        await user.updatePassword(_newController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Updated Successfully!"), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Check current password"), backgroundColor: Colors.red));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Change Password", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: _currentController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(labelText: "Current Password", border: InputBorder.none, contentPadding: EdgeInsets.all(15)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: _newController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(labelText: "New Password", border: InputBorder.none, contentPadding: EdgeInsets.all(15)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Password", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 3. ORDERS (REAL HISTORY FROM FIREBASE)
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(user?.uid)
            .collection('history')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No orders yet.", style: TextStyle(color: textColor)));

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: LazaColors.lightBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check_box_outlined, color: LazaColors.primary)),
                  title: Text("Order ${data['orderId']}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text("${data['itemCount']} Items • \$${data['totalAmount'].toStringAsFixed(2)}", style: const TextStyle(color: LazaColors.grey))),
                  trailing: const Text("Delivered", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 4. MY CARDS (REAL FIREBASE DATA)
class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("My Cards", style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
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
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No cards added yet", style: TextStyle(color: textColor)));

                  final cards = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final data = cards[index].data() as Map<String, dynamic>;

                      Gradient? cardGradient;
                      Color cardColor = LazaColors.primary;
                      String typeName = "VISA";
                      IconData typeIcon = Icons.credit_card;
                      int type = data['type'] ?? 0;

                      if (type == 0) { cardGradient = const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)]); typeName = "Mastercard"; }
                      else if (type == 1) { cardColor = const Color(0xFF0070BA); typeIcon = Icons.paypal; typeName = "Paypal"; }
                      else { cardColor = const Color(0xFF1D1E20); typeIcon = Icons.account_balance; typeName = "Bank Account"; }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        height: 180, width: double.infinity,
                        decoration: BoxDecoration(
                            color: cardGradient == null ? cardColor : null,
                            gradient: cardGradient,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(typeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Icon(typeIcon, color: Colors.white, size: 30)]),
                            Text("**** **** **** ${data['number'].toString().length > 4 ? data['number'].toString().substring(data['number'].toString().length - 4) : '0000'}", style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data['owner'], style: const TextStyle(color: Colors.white, fontSize: 14)), Text("Exp: ${data['exp']}", style: const TextStyle(color: Colors.white70, fontSize: 14))]),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddNewCardScreen(fromCart: false))),
                style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary),
                child: const Text("Add New Card", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 5. ADD NEW CARD (SAVES TO FIREBASE)
class AddNewCardScreen extends StatefulWidget {
  final bool fromCart;
  const AddNewCardScreen({super.key, this.fromCart = false});
  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final _ownerCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  int _selectedProvider = 0;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Add New Card", style: TextStyle(color: textColor)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [
              _iconBtn(0, Icons.credit_card, Colors.orange, "Card"), const SizedBox(width: 10),
              _iconBtn(1, Icons.paypal, Colors.blue, "Paypal"), const SizedBox(width: 10),
              _iconBtn(2, Icons.account_balance, Colors.green, "Bank"),
            ]),
            const SizedBox(height: 20),
            _input("Card Owner", _ownerCtrl, cardColor, textColor),
            const SizedBox(height: 15),
            _input("Card Number", _numberCtrl, cardColor, textColor),
            const SizedBox(height: 15),
            Row(children: [Expanded(child: _input("EXP", _expCtrl, cardColor, textColor)), const SizedBox(width: 15), Expanded(child: _input("CVV", _cvvCtrl, cardColor, textColor))]),
            const Spacer(),
            SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                    onPressed: () async {
                      if(_numberCtrl.text.isEmpty) return;
                      // SAVE TO FIREBASE
                      await UserService().addCard(
                          _ownerCtrl.text, _numberCtrl.text, _expCtrl.text, _cvvCtrl.text, _selectedProvider
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (!widget.fromCart) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card Saved!")));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary),
                    child: const Text("Save Card", style: TextStyle(color: Colors.white)))
            )
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(int i, IconData icon, Color color, String label) {
    return Expanded(child: GestureDetector(
        onTap: ()=>setState(()=>_selectedProvider=i),
        child: Container(
            height: 60,
            decoration: BoxDecoration(color: _selectedProvider==i ? LazaColors.primary.withOpacity(0.1) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10), border: _selectedProvider==i ? Border.all(color: LazaColors.primary):null),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 10))
              ],
            ))));
  }

  Widget _input(String label, TextEditingController c, Color fill, Color? text) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Container(decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(10)), child: TextField(controller: c, style: TextStyle(color: text), decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(15))))]);
  }
}

// 6. SETTINGS & PRIVACY
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Settings", style: TextStyle(color: textColor)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Notifications", style: TextStyle(color: textColor)),
            value: _notifEnabled,
            activeColor: LazaColors.primary,
            onChanged: (val) => setState(() => _notifEnabled = val),
          ),
          ListTile(
            title: Text("Privacy Policy", style: TextStyle(color: textColor)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyPolicyScreen())),
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Privacy Policy", style: TextStyle(color: textColor)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Here is the privacy policy of Laza app. We respect your data and privacy. This app uses Firebase for data storage and authentication...",
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}