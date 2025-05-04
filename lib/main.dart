import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastestproject/splash_screen.dart';
import 'package:gastestproject/test_pages/test_seller_dashbord.dart';
import 'driver_authentication/login_screen_driver.dart';
import 'driver_authentication/signup_screen_driver.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
//import 'package:gastestproject/pages/map_page.dart';
import 'package:gastestproject/test_pages/test_map_page.dart';
import 'package:gastestproject/pages/welcome_screen.dart';
//import'package:gastestproject/pages/home_page.dart';
import'package:gastestproject/authentication/signup_screen.dart';
import'package:gastestproject/authentication/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import'package:gastestproject/pages/order_placement_page.dart';
import'package:gastestproject/pages/order_tracking_screen.dart';
import'package:gastestproject/pages/profile_screen.dart';
import'package:gastestproject/pages/Ratings_Reviews_Page.dart';
import'package:gastestproject/seller_pages/seller_dashbord.dart';
import'package:gastestproject/seller_pages/orders_detail_page.dart';
import'package:gastestproject/seller_pages/inventory_management_page.dart';
import'package:gastestproject/seller_pages/earnings_transactions_page.dart';
import'package:gastestproject/driver_pages/dashboard.dart';
import'package:gastestproject/test_pages/test_map_page.dart';
import'package:gastestproject/test_pages/test_payment_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.locationWhenInUse.isDenied.then((valueofPermission) {
    if (valueofPermission) {
      Permission.locationWhenInUse.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
          '/login': (context) => const LoginScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) =>
          const PlaceholderScreen(title: "Edit Profile"),
          //const PlaceholderScreen(title: "Settings"),
          // '/order_details': (context) => const OrderDetailsPage(),
          //'/route_optimization': (context) => const RouteOptimizationPage(),
          '/order_placement': (context) => const OrderPlacementPage(),
          '/order_tracking': (context) => OrderTrackingScreen(orderId: ''),
          '/payment': (context) => const PaymentPage(),
          '/edit_profile': (context) => const EditProfilePage(),
          '/notification': (context) => const NotificationPage(),

        },
      home:WelcomeScreen()
    );
  }
}

//AnimatedSplashScreenWidget()
