import 'package:flutter/material.dart';

class EarningsTransactionsPageTest extends StatelessWidget {
  const EarningsTransactionsPageTest({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orders = [
      {
        'quantity': 3,
        'pricePerCylinder': 7.0,
        'paymentMethod': 'Cash',
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'quantity': 2,
        'pricePerCylinder': 7.5,
        'paymentMethod': 'Card',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'quantity': 5,
        'pricePerCylinder': 6.5,
        'paymentMethod': 'Cash',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    final totalEarnings = orders.fold<double>(
      0,
          (sum, order) =>
      sum + (order['quantity'] * order['pricePerCylinder']),
    );

    const accentColor = Color(0xFF002B49);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text("Earnings (Test)", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
              border: Border.all(color: accentColor.withAlpha(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Earnings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: accentColor)),
                const SizedBox(height: 8),
                Text("JD ${totalEarnings.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: accentColor)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final total = order['quantity'] * order['pricePerCylinder'];
                final date = order['date'] as DateTime;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.monetization_on, color: Colors.green),
                    title: Text("Order: ${order['quantity']} Cylinder(s)",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "Payment: ${order['paymentMethod']}\nDate: ${date.day}/${date.month}/${date.year}",
                      style: const TextStyle(height: 1.4),
                    ),
                    trailing: Text("JD ${total.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
