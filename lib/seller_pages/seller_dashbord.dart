import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_detail_page.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final Color accentColor = const Color(0xFF002B49);
  late String sellerId;

  @override
  void initState() {
    super.initState();
    sellerId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _updateStatus(
      BuildContext context, String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order marked as $newStatus")),
    );
  }

  Widget _buildSwipeBackground(
      IconData icon, String label, Color color, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        title:
        const Text("Seller Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final int quantity = data['quantity'] ?? 0;
              final String status = data['status'] ?? 'pending';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final DateTime date = timestamp.toDate();

              Color statusColor;
              switch (status) {
                case 'delivered':
                  statusColor = Colors.green;
                  break;
                case 'on_the_way':
                  statusColor = Colors.orange;
                  break;
                case 'accepted':
                  statusColor = accentColor;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Dismissible(
                key: Key(order.id),
                background: _buildSwipeBackground(
                    Icons.check, "Accept", accentColor, Alignment.centerLeft),
                secondaryBackground: _buildSwipeBackground(
                    Icons.done, "Deliver", Colors.green, Alignment.centerRight),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _updateStatus(context, order.id, 'accepted');
                  } else {
                    await _updateStatus(context, order.id, 'delivered');
                  }
                  return false;
                },
                child: Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                            orderId: order.id,
                            orderData: data,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.inventory_2_rounded, color: statusColor),
                    ),
                    title: Text(
                      "Order: $quantity Cylinder(s)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Status: ${status.replaceAll('_', ' ').toUpperCase()}"),
                        Text(
                            "Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(date)}",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'orders_detail_page.dart';

class SellerDashboardPage extends StatelessWidget {
  final String sellerId;
  const SellerDashboardPage({super.key, required this.sellerId});

  final Color accentColor = const Color(0xFF002B49);

  Future<void> _updateStatus(BuildContext context, String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order marked as $newStatus")),
    );
  }

  Widget _buildSwipeBackground(IconData icon, String label, Color color, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text("Seller Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final int quantity = data['quantity'] ?? 0;
              final String status = data['status'] ?? 'pending';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final DateTime date = timestamp.toDate();

              Color statusColor;
              switch (status) {
                case 'delivered':
                  statusColor = Colors.green;
                  break;
                case 'on_the_way':
                  statusColor = Colors.orange;
                  break;
                case 'accepted':
                  statusColor = accentColor;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Dismissible(
                key: Key(order.id),
                background: _buildSwipeBackground(Icons.check, "Accept", accentColor, Alignment.centerLeft),
                secondaryBackground: _buildSwipeBackground(Icons.done, "Deliver", Colors.green, Alignment.centerRight),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _updateStatus(context, order.id, 'accepted');
                  } else {
                    await _updateStatus(context, order.id, 'delivered');
                  }
                  return false; // don't dismiss
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                            orderId: order.id,
                            orderData: data,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.inventory_2_rounded, color: statusColor),
                    ),

                    title: Text(
                      "Order: $quantity Cylinder(s)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Status: ${status.replaceAll('_', ' ').toUpperCase()}"),
                        Text("Date: ${DateFormat('dd MMM yyyy – hh:mm a').format(date)}",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} */


