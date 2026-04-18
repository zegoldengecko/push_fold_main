import 'package:flutter/material.dart';
import 'package:push_fold_main/services/drill_generator.dart';
import 'package:push_fold_main/models/drill_spot.dart';
import 'package:push_fold_main/data/gto_charts.dart';
import 'package:push_fold_main/data/common_failures.dart';

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

  // Submitting the answer
  void submitAnswer(bool pushed, DrillSpot spot) {
    if (pushed && shouldShove(spot) || !pushed && !shouldShove(spot)) {
      print('Correctly acted in spot ${spot.position} ${spot.stack} ${spot.hand}. They pushed: $pushed');
    } else if (pushed && !shouldShove(spot) || !pushed && shouldShove(spot)) {
      print('Incorrectly acted in spot ${spot.position} ${spot.stack} ${spot.hand}. They pushed: $pushed');
      recordFailure(spot);
    }

    nextSpot();
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
              onPressed: () => submitAnswer(true, spot),
              child: const Text('Push'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => submitAnswer(false, spot),
              child: const Text('Fold'),
            ),
          ],
        ),
      ),
    );
  }
}