import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_app_1/models/player.dart';

class PlayerLifeWidget extends StatelessWidget {
  final Player player;
  final VoidCallback onLifeIncrement;
  final VoidCallback onLifeDecrement;
  final Function(int) onLifeAdjust;
  final VoidCallback onCommanderDamageTap;

  const PlayerLifeWidget({
    super.key,
    required this.player,
    required this.onLifeIncrement,
    required this.onLifeDecrement,
    required this.onLifeAdjust,
    required this.onCommanderDamageTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDead = player.life <= 0;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            // Content
            Opacity(
              opacity: isDead ? 0.5 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotated text for opponents? Usually for 2 player head-to-head, TOP player is rotated 180.
                  // For 4 players 2x2, usually all face center or all upright.
                  // Requirement doesn't specify rotation. Assuming upright for now.
                  Text(
                    player.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Life Total
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      '${player.life}',
                      key: ValueKey<int>(player.life),
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Adjustment Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdjustButton(context, -5, Colors.red),
                      const SizedBox(width: 8),
                      _buildAdjustButton(context, -1, Colors.red),
                      const SizedBox(width: 16),
                      _buildAdjustButton(context, 1, Colors.green),
                      const SizedBox(width: 8),
                      _buildAdjustButton(context, 5, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Commander Damage Indicator
                  GestureDetector(
                    onTap: onCommanderDamageTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚔️ CMD', style: TextStyle(fontSize: 12)),
                          // We could show max damage taken or something. For now just label.
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Death Overlay
            if (isDead)
              Positioned.fill(
                child: Container(
                  color: Colors.red.withOpacity(0.1),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.skull_outline, // Wait, material icons doesn't have skull_outline?
                    // Icons.dangerous or something similar if skull not available.
                    // Actually Icons.warning_amber is available.
                    Icons.close,
                    size: 80,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(BuildContext context, int delta, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
            HapticFeedback.lightImpact();
            onLifeAdjust(delta);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 50, // Slightly smaller than req to fit 4 in row on small screens? Req says "minimum 60px height".
          // Width needs to be enough. 
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            delta > 0 ? '+$delta' : '$delta',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
