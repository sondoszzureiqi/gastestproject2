import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastestproject/driver_authentication/signup_screen_driver.dart';
import 'package:gastestproject/driver_pages/dashboard.dart';
import 'package:gastestproject/widgets/loading_dialog.dart';
import 'package:gastestproject/methods/common_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreenDriver extends StatefulWidget {
  const LoginScreenDriver({super.key});

  @override
  State<LoginScreenDriver> createState() => _LoginScreenDriverState();
}

class _LoginScreenDriverState extends State<LoginScreenDriver> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late bool securetext;
  CommonMethods cMethods = CommonMethods();

  @override
  void initState() {
    securetext = true;
    super.initState();
  }

  loginUserNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: 'Logging you in...'),
    );

    try {
      final User? userFirebase = (await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ))
          .user;

      if (!context.mounted) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userFirebase!.uid)
          .get();

      final role = doc['role'];

      Navigator.pop(context);

      if (role == 'seller') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        cMethods.displaySnackBar('Access denied: not a seller.', context);
      }
    } catch (e) {
      Navigator.pop(context);
      cMethods.displaySnackBar('Login failed: ${e.toString()}', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset('assets/man.png'),
                const Text(
                  'Login as Driver',
                  style: TextStyle(
                      color: Color(0xFF0F0F29),
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: securetext,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              securetext ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                securetext = !securetext;
                              });
                            },
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          loginUserNow();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F0F29),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Color.fromARGB(255, 188, 186, 186),
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreenDriver()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an Account? Register Here',
                    style: TextStyle(color: Color(0xFF296BD3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
