import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('customers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        }

        final customers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index].data() as Map<String, dynamic>;
            final name = customer['name'] ?? '';
            final phone = customer['phone'] ?? '';
            final location = customer['location'] ?? '';
            final commodities = customer['commodities'] ?? '';
            final totalPrice = customer['totalPrice'] ?? '';

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),

                ),
                child: ListTile(
                  leading: Icon(LineIcons.userCircle, color: Colors.blue, ),
                  title: Text(name, style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: $phone'),
                      Text('Location: $location'),
                      Text('Commodities: $commodities'),
                      Text('Total Price: $totalPrice'),
                    ],
                  ),
                  trailing: Icon(LineIcons.arrowCircleRight),
                  onTap: () {
                    // You can add further action on tapping each customer
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
