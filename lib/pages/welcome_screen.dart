import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gastestproject/authentication/login_screen.dart';
import 'package:gastestproject/authentication/signup_screen.dart';
import'package:gastestproject/driver_authentication/signup_screen_driver.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _opacity = 0.0;
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();


    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });


    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showShimmer = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Center(
            child: Column(
              children: [

                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    "assets/gasongo_logo2-removebg-preview.png",
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),


                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  child: _showShimmer
                      ? Shimmer.fromColors(
                    baseColor: Colors.black87,
                    highlightColor: Colors.grey[300]!,
                    period: const Duration(seconds: 2),
                    child: Text(
                      "Because Every Flame Deserves Fast Fuel",
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  )
                      : Text(
                    "Because Every Flame Deserves Fast Fuel",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Customer Button
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(255, 15, 15, 41),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, top: 13, bottom: 13),
                      elevation: 5,
                      shadowColor: Colors.black45,
                    ),
                    onPressed: () {Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                    },
                    child: const Text(
                      "Get Gas Now",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //  Seller Button
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(255, 15, 15, 41),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, top: 13, bottom: 13),
                      elevation: 5,
                      shadowColor: Colors.black45,
                    ),
                    onPressed: () {
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreenDriver()));
                    },
                    child: const Text(
                      "Start Selling Gas",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

