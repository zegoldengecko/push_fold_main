import 'package:flutter/material.dart';
import 'package:push_fold_main/screens/drill_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Column(
        children: [
          // Red banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.red,
            child: const SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  "placeholder poker app name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🖼️ YOUR IMAGE HERE
                  Image.asset(
                    'assets/titel_royal_flush.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  _MenuButton(
                    title: "Practice",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrillScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const _MenuButton(title: "Learn"),
                  const SizedBox(height: 16),
                  const _MenuButton(title: "Stats"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}