import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ClearTab extends StatefulWidget {
  @override
  _ClearTabState createState() => _ClearTabState();
}

class _ClearTabState extends State<ClearTab> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  String _customerName = '';
  int _currentPrice = 0;

  void _searchCustomer() async {
    final phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() {
        _customerName = '';
        _currentPrice = 0;
      });
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final customer = querySnapshot.docs.first;
      setState(() {
        _customerName = customer['name'];
        _currentPrice = customer['totalPrice'];
      });
    } else {
      setState(() {
        _customerName = '';
        _currentPrice = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer not found')),
      );
    }
  }

  void _payDues() async {
    final phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isEmpty || _currentPrice == 0) {
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final customer = querySnapshot.docs.first;

      int paymentAmount = int.tryParse(_paymentController.text) ?? 0;
      if (paymentAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid payment amount')),
        );
        return; // Do not proceed if payment is not a valid positive number.
      }

      final newPrice = _currentPrice - paymentAmount;

      if (newPrice <= 0) {
        // Delete customer if the dues are cleared
        await customer.reference.delete();
        setState(() {
          _customerName = '';
          _currentPrice = 0;
          _paymentController.clear(); // Clear the payment input field
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successfully settled')),
        );
      } else {
        // Update the price in the database
        await customer.reference.update({'totalPrice': newPrice});
        setState(() {
          _currentPrice = newPrice;
          _paymentController.clear(); // Clear the payment input field
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successfully processed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Search by Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(LineIcons.search),
                onPressed: _searchCustomer,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (_customerName.isNotEmpty)
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Customer: $_customerName',
                      style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Total Price: $_currentPrice', // Display the current price from Firestore
                      style: GoogleFonts.openSans(),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _paymentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Payment Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _payDues,
                      child: Text('Pay'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
