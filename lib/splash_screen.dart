import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For Lottie animation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateToHome() {
    // Navigation triggered by the "Get Started" button
    Navigator.pushReplacementNamed(context, '/home'); // Change '/home' to your actual home route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Takes full width of the screen
        height: double.infinity, // Takes full height of the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blueAccent.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/animations/sunny.json', // Ensure the path matches your project structure
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // App Name
            const Text(
              'Weather Star',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            const Text(
              'Get the accurate weather info\nanytime and anywhere',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),

            // "Get Started" Button
            ElevatedButton(
              onPressed: _navigateToHome, // Trigger navigation
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button background color
                foregroundColor: Colors.blue, // Button text color
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}