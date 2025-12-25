import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/user_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // FIXED: Removed the text inside ("") so they start empty
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  bool _saveAsPrimary = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Address", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Name", textColor),
              _inputField("Type Name", _nameCtrl, cardColor, textColor),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Country", textColor), _inputField("Country", _countryCtrl, cardColor, textColor)])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("City", textColor), _inputField("City", _cityCtrl, cardColor, textColor)])),
                ],
              ),
              const SizedBox(height: 15),
              _label("Phone Number", textColor),
              _inputField("Phone Number", _phoneCtrl, cardColor, textColor),
              const SizedBox(height: 15),
              _label("Address", textColor),
              _inputField("Street Address", _addressCtrl, cardColor, textColor),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Save as primary address", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Switch(value: _saveAsPrimary, activeColor: LazaColors.primary, onChanged: (val) => setState(() => _saveAsPrimary = val))
                ],
              )
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: bgColor,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () async {
              await UserService().saveAddress(
                  _nameCtrl.text, _countryCtrl.text, _cityCtrl.text, _phoneCtrl.text, _addressCtrl.text
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address Saved!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary),
            child: const Text("Save Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color? color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)));
  }

  Widget _inputField(String hint, TextEditingController controller, Color fillColor, Color? textColor) {
    return Container(decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(10)), child: TextField(controller: controller, style: TextStyle(color: textColor), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: LazaColors.grey), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15))));
  }
}