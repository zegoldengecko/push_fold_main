import 'dart:math';
import 'package:push_fold_main/models/drill_spot.dart';

final _positions = ['SB', 'BB', 'UTG', 'UTG+1', 'UTG+2', 'UTG+3', 'LJ', 'HJ', 'CO', 'BTN'];
final _stacks = List.generate(15, (i) => i + 1);

DrillSpot generateRandomSpot() {
  final rand = Random();
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