import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadShopkeeperDetails();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  void _loadShopkeeperDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _nameController.text = docSnapshot.get('name');
          _phoneNumberController.text = docSnapshot.get('phoneNumber');
          _locationController.text = docSnapshot.get('location');
        });
      }
    }
  }

  Future<void> _saveShopkeeperDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        setState(() {
          _isSaving = true;
        });

        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'location': _locationController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shopkeeper details saved.')));
      } catch (e) {
        print('Error saving shopkeeper details: $e');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopkeeper Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(LineIcons.alternateSignOut), onPressed: _signOut),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Icon(LineIcons.user, color: Colors.black),
                ),
                Text(
                  'Shopkeeper Details',
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isEditing ? Colors.green : Colors.blue, // Color changes based on edit mode
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isEditing ? Icons.check : Icons.edit, // Icon changes based on edit mode
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _isEditing ? 'Save' : 'Edit', // Text changes based on edit mode
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTextField('Name', _nameController, enabled: _isEditing),
                  SizedBox(height: 16),
                  _buildDetailTextField('Phone Number', _phoneNumberController, enabled: _isEditing),
                  SizedBox(height: 16),
                  _buildDetailTextField('Location', _locationController, enabled: _isEditing),
                  SizedBox(height: 30),
                  _isSaving
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : Container(),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              child: Center(
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTextField(String label, TextEditingController controller, {bool enabled = false}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
