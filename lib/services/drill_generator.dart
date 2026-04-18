import 'dart:math';
import 'package:push_fold_main/models/drill_spot.dart';
import '../data/common_failures.dart';

final _positions = ['SB', 'BB', 'UTG', 'UTG+1', 'UTG+2', 'UTG+3', 'LJ', 'HJ', 'CO', 'BTN'];
final _stacks = List.generate(15, (i) => i + 1);

DrillSpot generateRandomSpot() {
  final rand = Random();

  // 2 in 3 chance of pulling from list of commonly failing hands
  if ((rand.nextInt(3) + 1) > 2) {
    final result = useChallengingHand(rand);
    return result;
  }

  // otherwise generate new hand
  final position = _positions[rand.nextInt(_positions.length)];
  final stack = _stacks[rand.nextInt(_stacks.length)];

  final hand = _randomhand(rand);

  return DrillSpot(position: position, stack: stack, hand: hand);
}

String _randomhand(Random rand) {
  const ranks = '23456789TJQKA';

  final r1 = ranks[rand.nextInt(ranks.length)];
  final r2 = ranks[rand.nextInt(ranks.length)];
  
  // Pocket pair
  if (r1 == r2) {
    return '$r1$r2';
  }

  // Checking suited or not
  final suited = rand.nextBool() ? 's' : 'o';

  return '$r1$r2$suited';
}

DrillSpot useChallengingHand(Random rand) {
  if (failureDB.isEmpty) {
    return generateRandomSpot();
  }

  final List<String> weightedKeys = [];

  // Adding to weighted keys depending on weight
  for (final entry in failureDB.values) {
    for (int i = 0; i < entry.weight; i++) {
      weightedKeys.add(entry.key);
    }
  }

  if (weightedKeys.isEmpty) {
    return generateRandomSpot();
  }

  // Picking a random key
  final selectedKey = weightedKeys[rand.nextInt(weightedKeys.length)];

  return convertToSpot(selectedKey);
}

DrillSpot convertToSpot(String key) {
  // split the key
  final parts = key.split('_');

  final position = parts[1];
  final stack = int.parse(parts[2]);
  final hand = parts[3];

  return DrillSpot(position: position, stack: stack, hand: hand);
}