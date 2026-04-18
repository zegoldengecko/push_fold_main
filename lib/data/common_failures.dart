import 'package:push_fold_main/models/drill_spot.dart';

class FailureRecord {
  final String key; // e.g. "BTN_10_K7s"
  int weight;

  FailureRecord({
    required this.key,
    required this.weight,
  });
}

void recordFailure(DrillSpot spot) {
  final storageString = '${spot.position}_${spot.stack}_${spot.hand}';

  if (failureDB.containsKey(storageString)) {
    failureDB[storageString] !.weight += 1;
  } else {
    failureDB[storageString] = FailureRecord(key: storageString, weight: 1);
  }
}

void removeFailure(DrillSpot spot) {
  final storageString = '${spot.position}_${spot.stack}_${spot.hand}';

  if (failureDB.containsKey(storageString)) {
    final record = failureDB[storageString]!;

    if (record.weight <= 1) {
      failureDB.remove(storageString);
    } else {
      record.weight -= 1;
    }
  }
}

Map<String, FailureRecord> failureDB = {};