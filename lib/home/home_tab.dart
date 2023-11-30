import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<Map<String, dynamic>> _commoditiesList = [];
  final _commodityController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addCommodity() {
    final String commodity = _commodityController.text;
    final String price = _priceController.text;

    if (commodity.isNotEmpty && price.isNotEmpty) {
      setState(() {
        _commoditiesList.add({'commodity': commodity, 'price': price});
        _commodityController.clear();
        _priceController.clear();
      });
    }
  }

  void _saveToFirebase() async {
    final String name = _nameController.text;
    final String phone = _phoneController.text;
    final String location = _locationController.text;

    if (name.isNotEmpty &&
        phone.isNotEmpty &&
        location.isNotEmpty &&
        _commoditiesList.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'location': location,
        'commodities': _commoditiesList,
        'totalPrice': calculateTotalPrice(), // Add the totalPrice field
      };

      try {
        await _firestore.collection('customers').add(data);
        // Successfully saved to Firebase
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form fields and commodities list
        setState(() {
          _nameController.clear();
          _phoneController.clear();
          _locationController.clear();
          _commoditiesList.clear();
          _isLoading = false;
        });
      } catch (error) {
        // Handle error while saving to Firebase
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $error'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Show a message if any required field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the required fields.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Calculate the total price based on the _commoditiesList
  int calculateTotalPrice() {
    return _commoditiesList
        .map<int>((item) => int.parse(item['price']))
        .reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Customer Details Container
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[100],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Customer Details',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          // Commodities Container
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[100],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Commodities',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commodityController,
                        decoration: InputDecoration(
                          labelText: 'Commodity',
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price (Ksh)',
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    IconButton(
                      icon: Icon(LineIcons.plusCircle),
                      onPressed: _addCommodity,
                      color: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                if (_commoditiesList.isNotEmpty)
                  Column(
                    children: _commoditiesList
                        .map(
                          (commodity) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(commodity['commodity']),
                          Text('${commodity['price']} Ksh'),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                SizedBox(height: 16.0),
                if (_commoditiesList.isNotEmpty)
                  Text(
                    'Total: ${calculateTotalPrice()} Ksh',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveToFirebase,
            child: _isLoading
                ? CircularProgressIndicator() // Show loading indicator while saving
                : Text('Credit'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
