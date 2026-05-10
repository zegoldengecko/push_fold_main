import 'package:flutter/material.dart';
import 'package:push_fold_main/services/drill_generator.dart';
import 'package:push_fold_main/models/drill_spot.dart';
import 'package:push_fold_main/data/gto_charts.dart';
import 'package:push_fold_main/data/common_failures.dart';
import 'dart:math';

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

  void submitAnswer(bool pushed, DrillSpot spot) {
    if (pushed && shouldShove(spot) || !pushed && !shouldShove(spot)) {
      removeFailure(spot);
    } else {
      recordFailure(spot);
    }
    nextSpot();
  }

  // Parse hand string like "Ad4d" or "AKo" into two cards
  List<Map<String, dynamic>> parseHand(String hand) {
    const suitSymbols = {'h': '♥', 'd': '♦', 'c': '♣', 's': '♠'};
    const redSuits = {'h', 'd'};

    // Suited hand e.g. "Ad4d"
    if (hand.length == 4) {
      final r1 = hand[0];
      final s1 = hand[1];
      final r2 = hand[2];
      final s2 = hand[3];
      return [
        {'rank': r1, 'suit': suitSymbols[s1] ?? s1, 'red': redSuits.contains(s1)},
        {'rank': r2, 'suit': suitSymbols[s2] ?? s2, 'red': redSuits.contains(s2)},
      ];
    }

    // Offsuit/pair e.g. "AKo" or "AA"
    final r1 = hand[0];
    final r2 = hand[1];
    return [
      {'rank': r1, 'suit': '♠', 'red': false},
      {'rank': r2, 'suit': (hand.endsWith('o') ? '♥' : '♣'), 'red': hand.endsWith('o')},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cards = parseHand(spot.hand);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1f2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top bar: position + stack
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoBadge(label: 'Position', value: spot.position),
                  _InfoBadge(label: 'Stack', value: '${spot.stack}bb'),
                ],
              ),

              const Spacer(),

              // Poker table
              _PokerTable(activePosition: spot.position),

              const Spacer(),

              // Cards label
              const Text(
                'Your hole cards',
                style: TextStyle(fontSize: 12, color: Color(0xFF506070)),
              ),
              const SizedBox(height: 10),

              // Hole cards
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PlayingCard(
                    rank: cards[0]['rank'],
                    suit: cards[0]['suit'],
                    red: cards[0]['red'],
                  ),
                  const SizedBox(width: 14),
                  _PlayingCard(
                    rank: cards[1]['rank'],
                    suit: cards[1]['suit'],
                    red: cards[1]['red'],
                  ),
                ],
              ),

              const Spacer(),

              // Push / Fold buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Fold',
                      sublabel: 'Muck your hand',
                      color: const Color(0xFFff8080),
                      background: const Color(0xFF3a2020),
                      border: const Color(0xFF6a3030),
                      onTap: () => submitAnswer(false, spot),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'Push',
                      sublabel: 'All-in!',
                      color: const Color(0xFF60d080),
                      background: const Color(0xFF1a3a20),
                      border: const Color(0xFF2a6a30),
                      onTap: () => submitAnswer(true, spot),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2a3050),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3a4060), width: 0.5),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFFa0b0d0)),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(color: Color(0xFFe0eaff), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingCard extends StatelessWidget {
  final String rank;
  final String suit;
  final bool red;

  const _PlayingCard({required this.rank, required this.suit, required this.red});

  @override
  Widget build(BuildContext context) {
    final color = red ? const Color(0xFFcc2222) : const Color(0xFF111111);
    return Container(
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFdddddd), width: 0.5),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Stack(
        children: [
          // Top-left corner pip
          Positioned(
            top: 5,
            left: 6,
            child: Column(
              children: [
                Text(rank, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.1)),
                Text(suit, style: TextStyle(fontSize: 10, color: color, height: 1.1)),
              ],
            ),
          ),
          // Centre
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rank, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: color, height: 1)),
                Text(suit, style: TextStyle(fontSize: 22, color: color, height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.background,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: color)),
          ),
        ),
        const SizedBox(height: 4),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: Color(0xFF506070))),
      ],
    );
  }
}

class _PokerTable extends StatelessWidget {
  final String activePosition;

  const _PokerTable({required this.activePosition});

  // 8-handed positions in clockwise order starting from BTN at top-right
  static const _positions = ['BTN', 'CO', 'HJ', 'LJ', 'UTG+1', 'UTG', 'BB', 'SB'];

  @override
  Widget build(BuildContext context) {
    const tableW = 260.0;
    const tableH = 150.0;
    const seatR = 11.0;
    // Ellipse radii for seat placement (seat centre on the ellipse)
    const rx = tableW / 2 + seatR + 2;
    const ry = tableH / 2 + seatR + 2;
    const cx = rx;
    const cy = ry;
    final totalW = cx * 2;
    final totalH = cy * 2;

    return SizedBox(
      width: totalW,
      height: totalH,
      child: Stack(
        children: [
          // Felt
          Positioned(
            left: seatR + 2,
            top: seatR + 2,
            child: Container(
              width: tableW,
              height: tableH,
              decoration: BoxDecoration(
                color: const Color(0xFF1a6644),
                borderRadius: BorderRadius.circular(tableH / 2),
                border: Border.all(color: const Color(0xFF0d3d28), width: 4),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
                  ),
                ),
              ),
            ),
          ),

          // Seats
          ..._positions.asMap().entries.map((entry) {
            final i = entry.key;
            final pos = entry.value;
            final angle = (2 * pi * i / _positions.length) - pi / 2;
            final x = cx + rx * cos(angle) - seatR;
            final y = cy + ry * sin(angle) - seatR;
            final isActive = pos == activePosition;

            return Positioned(
              left: x,
              top: y,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: seatR * 2,
                    height: seatR * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFFe8b84b) : const Color(0xFF2a3a50),
                      border: Border.all(
                        color: isActive ? const Color(0xFFf5d080) : const Color(0xFF3a5070),
                        width: isActive ? 2 : 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pos,
                    style: TextStyle(
                      fontSize: 8,
                      color: isActive ? const Color(0xFFf5d080) : const Color(0xFF607080),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}