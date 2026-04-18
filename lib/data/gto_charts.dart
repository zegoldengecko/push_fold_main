// ─────────────────────────────────────────────────────────────────────────────
// GTO Push/Fold Charts — Compact Format with Range Parser
// ─────────────────────────────────────────────────────────────────────────────
//
// Range string notation:
//   22+      all pairs from 22 up to AA
//   AKs      exact suited hand
//   AKo      exact offsuit hand
//   AK       both suited and offsuit (AKs + AKo)
//   A2s+     A2s up to AKs (all suited aces from A2s)
//   K5o+     K5o up to KQo
//   87s      exact hand only (no +)

import 'package:push_fold_main/models/drill_spot.dart';


// ranking cards from lowest to highest and converting to a number
const String _ranks = '23456789TJQKA';
int _rankIndex(String r) => _ranks.indexOf(r);

/// Expands a shorthand token like 'A2s+', '22+', 'AKo' into explicit hands.
List<String> _expandToken(String token) {
  final List<String> result = [];
  final bool isPlus = token.endsWith('+');
  final String t = isPlus ? token.substring(0, token.length - 1) : token;

  // CASE 1: Pocket pairs
  if (t.length == 2 && t[0] == t[1]) {
    final int base = _rankIndex(t[0]);
    if (isPlus) {
      for (int i = base; i < _ranks.length; i++) {
        result.add('${_ranks[i]}${_ranks[i]}');
      }
    } else {
      result.add('${t[0]}${t[1]}');
    }
    return result;
  }

  // CASE 2: Suited/offsuit hands
  if (t.length == 3) {
    final String hi = t[0];
    final String lo = t[1];
    final String suit = t[2]; // 's' or 'o'
    final int hiIdx = _rankIndex(hi);
    final int loIdx = _rankIndex(lo);

    if (isPlus) {
      // Iterate kicker from loIdx up to hiIdx - 1
      for (int i = loIdx; i < hiIdx; i++) {
        result.add('$hi${_ranks[i]}$suit');
      }
    } else {
      result.add('$hi$lo$suit');
    }
    return result;
  }

  // CASE 3: No suit specified, counts as both suited and offsuit
  if (t.length == 2) {
    final String hi = t[0];
    final String lo = t[1];
    final int hiIdx = _rankIndex(hi);
    final int loIdx = _rankIndex(lo);
    if (isPlus) {
      for (int i = loIdx; i < hiIdx; i++) {
        result.add('$hi${_ranks[i]}s');
        result.add('$hi${_ranks[i]}o');
      }
    } else {
      result.add('$hi${lo}s');
      result.add('$hi${lo}o');
    }
    return result;
  }

  return result;
}

/// Parses a full range string into a deduplicated list of hands.
List<String> parseRange(String range) {
  if (range.trim().isEmpty) return [];
  final Set<String> hands = {};
  for (final token in range.trim().split(RegExp(r'\s+'))) {
    hands.addAll(_expandToken(token));
  }
  return hands.toList();
}

/// Returns true if [hand] is a shove from [position] at [stackDepth] BB.
bool shouldShove(DrillSpot spot) {
  final posMap = gtoCharts[spot.position];
  if (posMap == null) return false;
  final range = posMap[spot.stack];
  if (range == null) return false;
  return parseRange(range).contains(spot.hand);
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart Data
// position -> stack depth (BB) -> range string (shove = listed, else fold)
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, Map<int, String>> gtoCharts = {

  // ── SMALL BLIND ──────────────────────────────────────────────────────────
  'SB': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 82o+ 72s+ 72o+ 62s+ 62o+ 52s+ 52o+ 42s+ 42o+ 32s 32o',
    2:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 63s+ 65o 53s+ 43s',
    3:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T3o+ 92s+ 95o+ 84s+ 86o+ 74s+ 76o 65s 54s',
    4:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T6o+ 93s+ 96o+ 84s+ 86o+ 74s+ 76o 64s+ 53s+',
    5:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J4o+ T2s+ T6o+ 94s+ 97o+ 84s+ 86o+ 74s+ 76o 64s+ 53s+',
    6:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J6o+ T2s+ T7o+ 94s+ 97o+ 84s+ 87o 74s+ 76o 64s+ 53s+ 43s',
    7:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q3o+ J2s+ J7o+ T3s+ T8o+ 95s+ 97o+ 84s+ 87o 74s+ 76o 64s+ 53s+',
    8:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q5o+ J2s+ J7o+ T4s+ T7o+ 95s+ 97o+ 85s+ 87o 74s+ 76o 64s+ 53s+',
    9:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q6o+ J3s+ J8o+ T4s+ T8o+ 95s+ 97o+ 85s+ 87o 74s+ 76o 64s+ 53s+',
    10: '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q8o+ J3s+ J8o+ T4s+ T8o+ 95s+ 97o+ 85s+ 87o 74s+ 64s+ 53s+',
    11: '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q8o+ J4s+ J8o+ T5s+ T8o+ 95s+ 98o 85s+ 87o 75s+ 64s+ 53s+',
    12: '22+ A2s+ A2o+ K2s+ K3o+ Q2s+ Q8o+ J4s+ J8o+ T6s+ T8o+ 95s+ 98o 85s+ 87o 75s+ 64s+ 54s',
    13: '22+ A2s+ A2o+ K2s+ K5o+ Q3s+ Q9o+ J5s+ J8o+ T6s+ T8o+ 95s+ 98o 85s+ 87o 75s+ 64s+ 54s',
    14: '22+ A2s+ A2o+ K2s+ K6o+ Q4s+ Q9o+ J5s+ J9o+ T6s+ T8o+ 96s+ 98o 85s+ 75s+ 64s+ 54s',
    15: '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J5s+ J9o+ T6s+ T8o+ 96s+ 98o 85s+ 75s+ 65s 54s'
  },

  // ── BUTTON ───────────────────────────────────────────────────────────────
  'BTN': {
    1:  '22+ A2s+ A2o+ K2s+ K5o+ Q4s+ Q8o+ J6s+ J8o+ T7s+ T8o+ 97s+ 87s',
    2:  '22+ A2s+ A2o+ K2s+ K5o+ Q4s+ Q8o+ J7s+ J8o+ T7s+ T9o 97s+',
    3:  '22+ A2s+ A2o+ K2s+ K5o+ Q4s+ Q8o+ J7s+ J9o+ T7s+ T9o 98s',
    4:  '22+ A2s+ A2o+ K2s+ K5o+ Q5s+ Q8o+ J7s+ J9o+ T7s+ T9o 98s 87s',
    5:  '22+ A2s+ A2o+ K2s+ K5o+ Q5s+ Q9o+ J7s+ J9o+ T7s+ 97s+ 87s 76s',
    6:  '22+ A2s+ A2o+ K2s+ K7o+ Q6s+ Q9o+ J7s+ JTo T7s+ 97s+ 86s+ 76s 65s',
    7:  '22+ A2s+ A2o+ K2s+ K8o+ Q6s+ QTo+ J7s+ JTo T7s+ 97s+ 86s+ 76s 65s',
    8:  '22+ A2s+ A2o+ K4s+ K9o+ Q8s+ QTo+ J7s+ JTo T7s+ 97s+ 86s+ 76s 65s',
    9:  '22+ A2s+ A2o+ K5s+ KTo+ Q8s+ QTo+ J8s+ JTo T7s+ 97s+ 86s+ 76s 65s',
    10: '22+ A2s+ A2o+ K5s+ KTo+ Q8s+ QTo+ J8s+ JTo T7s+ 97s+ 87s 76s',
    11: '22+ A2s+ A2o+ K6s+ KTo+ Q8s+ QTo+ J8s+ JTo T8s+ 97s+ 87s 76s',
    12: '22+ A2s+ A2o+ K6s+ KTo+ Q8s+ QTo+ J8s+ JTo T8s+ 97s+ 87s 76s',
    13: '22+ A2s+ A2o+ K7s+ KTo+ Q8s+ QTo+ J8s+ JTo T8s+ 97s+ 87s',
    14: '22+ A2s+ A2o+ K9s+ KTo+ Q8s+ QTo+ J8s+ JTo T8s+ 98s+ 87s',
    15: '22+ A2s+ A2o+ K9s+ KTo+ Q9s+ QTo+ J8s+ JTo T8s+ 98s+ 87s'
  },

  // ── CUTOFF ───────────────────────────────────────────────────────────────
  'CO': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J4o+ T2s+ T6o+ 93s+ 96o+ 84s+ 86o+ 74s+ 76o 64s+ 53s+',
    2:  '33+ A2s+ A2o+ K2s+ K6o+ Q4s+ Q8o+ J7s+ J9o+ T7s+ T9o 97s+ 87s 76s',
    3:  '33+ A2s+ A2o+ K2s+ K7o+ Q6s+ Q9o+ J8s+ J9o+ T8s+ T9o 98s',
    4:  '22+ A2s+ A2o+ K3s+ K7o+ Q6s+ QTo+ J8s+ JTo T8s+ 98s',
    5:  '22+ A2s+ A2o+ K4s+ K9o+ Q8s+ QTo+ J8s+ JTo T8s+ 97s+ 87s',
    6:  '22+ A2s+ A2o+ K5s+ KTo+ Q8s+ QTo+ J8s+ JTo T8s+ 97s+ 86s+ 76s',
    7:  '22+ A2s+ A2o+ K6s+ KTo+ Q9s+ QTo+ J8s+ JTo T8s+ 98s 87s',
    8:  '22+ A2s+ A3o+ K7s+ KTo+ Q9s+ QJo J8s+ JTo T8s+ 98s 87s',
    9:  '22+ A2s+ A4o+ K7s+ KTo+ Q9s+ QJo J8s+ JTo T8s+ 98s 87s',
    10: '22+ A2s+ A5o+ K8s+ KTo+ Q9s+ QJo J8s+ JTo T8s+ 98s 87s',
    11: '22+ A2s+ A8o+ K8s+ KJo+ Q9s+ QJo J8s+ JTo T8s+ 98s 87s',
    12: '22+ A2s+ A9o+ K8s+ KJo+ Q8s+ QJo J8s+ JTo T8s+ 98s',
    13: '22+ A2s+ A9o+ K8s+ KJo+ Q8s+ QJo J8s+ T8s+ 98s',
    14: '22+ A2s+ ATo+ K8s+ KJo+ Q9s+ QJo J8s+ T8s+ 98s',
    15: '22+ A3s+ ATo+ K9s+ KJo+ Q9s+ QJo J9s+ T9s 98s'
  },

  // ── HIJACK ───────────────────────────────────────────────────────────────
  'HJ': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+',
    2:  '22+ A2s+ A2o+ K2s+ K6o+ Q4s+ Q8o+ J7s+ J9o+ T7s+ T9o 97s+ 87s 76s',
    3:  '33+ A2s+ A3o+ K4s+ K9o+ Q8s+ Q9o+ J8s+ JTo+ T8s+ 98s',
    4:  '22+ A2s+ A2o+ K5s+ K9o+ Q8s+ QTo+ J9s+ JTo T9s',
    5:  '22+ A2s+ A3o+ K6s+ KTo+ Q9s+ QTo+ J9s+ JTo T8s+ 98s',
    6:  '22+ A2s+ A4o+ K7s+ KTo+ Q9s+ QJo J8s+ T8s+ 98s 87s',
    7:  '22+ A2s+ A7o+ A5o K9s+ KTo+ Q9s+ QJo J8s+ T8s+ 98s 87s',
    8:  '22+ A2s+ A8o+ K8s+ KJo+ Q9s+ QJo J8s+ T8s+ 98s',
    9:  '22+ A2s+ A9o+ K9s+ KJo+ Q9s+ QJo J8s+ T8s+ 98s',
    10: '22+ A3s+ A9o+ K9s+ KJo+ Q9s+ QJo J9s+ T8s+ 98s',
    11: '33+ A3s+ A9o+ K9s+ KJo+ Q9s+ QJo J9s+ T8s+ 98s',
    12: '33+ A7s+ A5s A4s ATo+ K8s+ KJo+ Q9s+ J9s+ T9s',
    13: '33+ A8s+ A5s ATo+ K9s+ KJo+ Q9s+ J9s+ T9s',
    14: '33+ A8s+ A5s AJo+ K9s+ KJo+ Q9s+ J9s+ T9s',
    15: '44+ A8s+ A5s AJo+ K9s+ KQo Q9s+ J9s+ T9s'
  },

  // ── LOJACK ───────────────────────────────────────────────────────────────
  'LJ': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+ 42s+ 43o 32s',
    2:  '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J7s+ J9o+ T7s+ T9o 97s+ 86s+ 76s 65s',
    3:  '33+ A2s+ A4o+ K5s+ K9o+ Q8s+ QTo+ J9s+ JTo+ T9s',
    4:  '22+ A2s+ A4o+ K6s+ KTo+ Q9s+ QTo+ J9s+ T9s',
    5:  '22+ A2s+ A7o+ A5o K8s+ KTo+ Q9s+ QJo J9s+ T8s+ 98s',
    6:  '22+ A2s+ A7o+ K9s+ KJo+ Q9s+ QJo J89+ T8s+ 98s',
    7:  '22+ A3s+ A9o+ K9s+ KJo+ Q9s+ QJo J9s+ T8s+ 98s',
    8:  '22+ A3s+ A8o+ K9s+ KJo+ Q9s+ J9s+ T8s+ 98s',
    9:  '33+ A7s+ A5s A4s ATo+ K9s+ KJo+ Q9s+ J9s+ T9s',
    10: '33+ A7s+ A5s ATo+ K9s+ KJo+ Q9s+ J9s+ T9s',
    11: '44+ A8s+ A5s ATo+ K9s+ KQo Q9s+ J9s+ T9s',
    12: '44+ A8s+ A5s AJo+ K9s+ KQo Q9s+ J9s+ T9s',
    13: '55+ A9s+ A5s ATo+ K9s+ KQo QTs+ J9s+ T9s',
    14: '55+ A9s+ A5s AJo+ K9s+ KQo QTs+ JTs',
    15: '55+ A9s+ A5s AQo+ KTs+ KQo QTs+ JTs'
  },

  // ── UTG+3 ────────────────────────────────────────────────────────────────
  'UTG+3': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+ 42s+ 43o 32s',
    2:  '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J7s+ J9o+ T7s+ T9o 96s+ 86s+ 76s 65s',
    3:  '44+ A2s+ A5o A7o+ K6s+ KTo+ Q8s+ QTo+ J9s+ T9s',
    4:  '22+ A2s+ A7o+ A5o K7s+ KTo+ Q9s+ QJo J9s+ T9s',
    5:  '22+ A2s+ A8o+ K9s+ KJo+ Q9s+ J9s+ T9s 98s',
    6:  '22+ A3s+ A9o+ K9s+ KJo+ Q9s+ J9s+ T8s+ 98s',
    7:  '33+ A3s+ ATo+ K9s+ KJo+ Q9s+ J9s+ T9s',
    8:  '33+ A5s+ ATo+ K9s+ KQo Q9s+ J9s+ T9s',
    9:  '44+ A8s+ ATo+ K9s+ KQo Q9s+ J9s+ T9s',
    10: '44+ A8s+ A5s AJo+ K9s+ KQo QTs+ J9s+ T9s',
    11: '55+ A9s+ A5s AJo+ K9s+ KQo QTs+ JTs',
    12: '55+ A8s+ A5s AJo+ KTs+ QTs+ JTs',
    13: '66+ A9s+ A5s AJo+ KTs+ QTs+ JTs',
    14: '88+ A9s+ A5s A4s AQo+ KTs+ QTs+ JTs',
    15: '88+ ATs+ A5s A4s A3s AQo+ KJs+ QTs+'
  },

  // ── UTG+2 ────────────────────────────────────────────────────────────────
  'UTG+2': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+ 42s+ 43o 32s',
    2:  '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J6s+ J9o+ T6s+ T9o 96s+ 86s+ 76s 65s 54s',
    3:  '44+ A2s+ A7o+ K7s+ KTo+ Q9s+ QJo J9s+ T9s',
    4:  '33+ A2s+ A8o+ K9s+ KJo+ Q9s+ QJo J9s+ T9s',
    5:  '33+ A3s+ A9o+ K9s+ KJo+ Q9s+ J9s+ T9s',
    6:  '33+ A4s+ ATo+ K9s+ KQo Q9s+ J9s+ T9s',
    7:  '44+ A8s+ A5s ATo+ K9s+ KQo Q9s+ J9s+ T9s',
    8:  '44+ A8s+ A5s ATo+ K9s+ KQo QTs+ J9s+ T9s',
    9:  '55+ A9s+ AJo+ K9s+ KQo QTs+ JTs T9s',
    10: '66+ A9s+ A5s AJo+ KTs+ QTs+ JTs',
    11: '55+ A9s+ A5s AJo+ KTs+ QTs+ JTs',
    12: '88+ A9s+ A5s A4s AQo+ KTs+ QTs+ JTs',
    13: '99+ ATs+ A5s A4s A3s AQo+ KTs+ QTs+',
    14: 'TT+ ATs+ A5s A4s A3s AQo+ KTs+ QJs',
    15: 'TT+ ATs+ A5s A4s A3s AQo+ KJs+ QJs+'
  },

  // ── UTG+1 ────────────────────────────────────────────────────────────────
  'UTG+1': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+ 42s+ 43o 32s',
    2:  '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J6s+ J9o+ T6s+ T9o 96s+ 86s+ 75s+ 65s 54s',
    3:  '44+ A2s+ A8o+ K8s+ KTo+ Q9s+ QJo J9s+ T9s',
    4:  '33+ A3s+ A9o+ K9s+ KJo+ Q9s+ J9s+ T9s',
    5:  '33+ A4s+ ATo+ K9s+ KQo QTs+ J9s+ T9s',
    6:  '44+ A8s+ A5s ATo+ K9s+ KQo Q9s+ JTs T9s',
    7:  '55+ A8s+ A5s AJo+ K9s+ KQo QTs+ JTs T9s',
    8:  '55+ A9s+ AJo+ K9s+ KQo QTs+ JTs',
    9:  '55+ A9s+ A5s AJo+ KTs+ QTs+ JTs',
    10: '88+ A9s+ A5s A4s AQo+ KTs+ QTs+ JTs',
    11: '88+ ATs+ A5s A4s A3s AQo+ KTs+ QTs+',
    12: '99+ ATs+ A5s A4s A3s AQo+ KJs+ QJs',
    13: 'TT+ ATs+ A5s A4s AQo+ KJs+ QJs',
    14: 'TT+ ATs+ A5s A4s A3s AQo+ KTs+',
    15: 'TT+ ATs+ A7s A5s A4s A3s AQo+ KQs'
  },

  // ── UTG ──────────────────────────────────────────────────────────────────
  'UTG': {
    1:  '22+ A2s+ A2o+ K2s+ K2o+ Q2s+ Q2o+ J2s+ J2o+ T2s+ T2o+ 92s+ 92o+ 82s+ 84o+ 72s+ 74o+ 62s+ 63o+ 52s+ 53o+ 42s+ 43o 32s',
    2:  '22+ A2s+ A2o+ K2s+ K7o+ Q4s+ Q9o+ J6s+ J9o+ T6s+ T9o 96s+ 86s+ 75s+ 65s 54s',
    3:  '44+ A3s+ A9o+ K9s+ KTo+ Q9s+ J9s+ T9s',
    4:  '44+ A4s+ ATo+ K9s+ KJo+ QTs+ JTs T9s',
    5:  '44+ A7s+ A5s ATo+ K9s+ KQo QTs+ JTs T9s',
    6:  '55+ A8s+ A5s ATo+ K9s+ KQo QTs+ JTs T9s',
    7:  '55+ A9s+ A5s AJo+ KTs+ KQo QTs+ JTs',
    8:  '66+ ATs+ A5s AJo+ KTs+ QTs+ JTs',
    9:  '88+ ATs+ A5s A4s AQo+ KTs+ QTs+ JTs',
    10: '88+ ATs+ A5s A4s A3s AQo+ KTs+ QTs+',
    11: '99+ ATs+ A5s A4s A3s AQo+ KJs+ QJs',
    12: 'TT+ ATs+ A5s A4s A3s AQo+ KJs+',
    13: 'TT+ ATs+ A7s A5s A4s A3s AQo+ KQs',
    14: 'TT+ ATs+ A5s A4s A3s AQo+ KQs',
    15: 'TT+ AJs+ A5s A4s AKo KQs'
  },
};
