import 'package:flutter/material.dart';

class SellerDashboardPageTest extends StatelessWidget {
  const SellerDashboardPageTest({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyOrders = [
      {
        'orderId': 'ORD001',
        'quantity': 3,
        'status': 'pending',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'orderId': 'ORD002',
        'quantity': 2,
        'status': 'on_the_way',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'orderId': 'ORD003',
        'quantity': 5,
        'status': 'delivered',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard (Test)"),
        backgroundColor: Color(0xFF002B49),
      ),
      body: ListView.builder(
        itemCount: dummyOrders.length,
        itemBuilder: (context, index) {
          final order = dummyOrders[index];
          return ListTile(
            title: Text("Order for ${order['quantity']} Cylinder(s)"),
            subtitle: Text("Status: ${order['status']}"),
            trailing: Text("${order['timestamp'].toString().split(' ')[0]}"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Tapped order ${order['orderId']}")),
              );
            },
          );
        },
      ),
    );
  }
}
