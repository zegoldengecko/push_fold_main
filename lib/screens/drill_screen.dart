import 'package:flutter/material.dart';
import 'package:push_fold_main/services/drill_generator.dart';
import 'package:push_fold_main/models/drill_spot.dart';

class DrillScreen extends StatefulWidget {
  const DrillScreen({super.key});

  @override
  State<DrillScreen> createState() => _DrillScreenState();
}

class _DrillScreenState extends State<DrillScreen> {
  late DrillSpot spot;

  @override
  void initState() {
    super.initState();
    spot = generateRandomSpot();
  }

  void nextSpot() {
    setState(() {
      spot = generateRandomSpot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${spot.position} • ${spot.stack}bb'),
            const SizedBox(height: 20),
            Text(
              spot.hand,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextSpot,
              child: const Text('Next'),
            )
          ],
        ),
      ),
    );
  }
}