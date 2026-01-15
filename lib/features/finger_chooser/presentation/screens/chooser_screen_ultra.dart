// lib/features/finger_chooser/presentation/screens/chooser_screen_ultra.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../../dare_display/presentation/screens/dare_display_screen.dart';
import '../provider/chooser_state_provider.dart';
import '../provider/chooser_models.dart';
import '../../../../models/finger_model.dart';
import '../../../../models/filter_criteria_model.dart';

class ChooserScreenUltra extends ConsumerStatefulWidget {
  final bool isQuickPlayMode;
  final List<String>? customDares;
  final FilterCriteria? filterCriteria;
  final String? loseRule;

  const ChooserScreenUltra({
    super.key,
    this.isQuickPlayMode = false,
    this.customDares,
    this.filterCriteria,
    this.loseRule,
  });

  @override
  ConsumerState<ChooserScreenUltra> createState() => _ChooserScreenUltraState();
}

class _ChooserScreenUltraState extends ConsumerState<ChooserScreenUltra>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late AnimationController _particleController;
  late ConfettiController _confettiController;
  
  // Add GlobalKey to track the touch area position
  final GlobalKey _touchAreaKey = GlobalKey();

  final AudioPlayer _countdownPlayer = AudioPlayer();
  final AudioPlayer _selectionPlayer = AudioPlayer();
  final AudioPlayer _falseStartPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheController.dispose();
    _particleController.dispose();
    _confettiController.dispose();
    _countdownPlayer.dispose();
    _selectionPlayer.dispose();
    _falseStartPlayer.dispose();
    super.dispose();
  }

  void _playSound(String sound) async {
    try {
      switch (sound) {
        case 'countdown':
          await _countdownPlayer.play(AssetSource('sounds/countdown.mp3'));
          break;
        case 'selection':
          await _selectionPlayer.play(AssetSource('sounds/selection.mp3'));
          HapticFeedback.heavyImpact();
          break;
        case 'falseStart':
          await _falseStartPlayer.play(AssetSource('sounds/false_start.mp3'));
          HapticFeedback.vibrate();
          break;
      }
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chooserState = ref.watch(chooserStateProvider(widget.filterCriteria));
    final chooserNotifier = ref.read(chooserStateProvider(widget.filterCriteria).notifier);
    final localizations = AppLocalizations.of(context)!;

    // Handle state changes
    ref.listen<ChooserScreenState>(chooserStateProvider(widget.filterCriteria), (previous, next) {
      if (previous?.gamePhase != next.gamePhase) {
        switch (next.gamePhase) {
          case GamePhase.countdownActive:
            _pulseController.repeat(reverse: true);
            _playSound('countdown');
            break;
          case GamePhase.selectionComplete:
            _pulseController.forward();
            _confettiController.play();
            _playSound('selection');
            if (!widget.isQuickPlayMode && next.selectedDare != null) {
              Future.delayed(const Duration(milliseconds: 2000), () {
                if (mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DareDisplayScreen(
                        selectedFinger: next.selectedFinger,
                        selectedDare: next.selectedDare,
                      ),
                    ),
                  );
                }
              });
            }
            break;
          case GamePhase.falseStart:
            _playSound('falseStart');
            HapticFeedback.heavyImpact();
            break;
          default:
            _pulseController.stop();
            _pulseController.reset();
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isQuickPlayMode ? "Quick Pick" : "Party Play",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0C29),
              const Color(0xFF302B63),
              const Color(0xFF24243E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleController.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Status header with fixed height
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: _buildStatusHeader(chooserState, localizations),
                    ),
                  ),

                  // Countdown display with fixed height container
                  SizedBox(
                    height: 160,
                    child: Center(
                      child: chooserState.gamePhase == GamePhase.countdownActive
                          ? _buildCountdownDisplay(chooserState)
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Main touch area
                  Expanded(
                    child: _buildTouchArea(chooserState, chooserNotifier),
                  ),

                  // Action buttons
                  _buildActionButtons(chooserState, chooserNotifier, localizations),
                ],
              ),
            ),

            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
                colors: const [
                  Colors.purple,
                  Colors.pink,
                  Colors.blue,
                  Colors.cyan,
                  Colors.yellow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ChooserScreenState state, AppLocalizations localizations) {
    String statusText;
    Color statusColor;

    switch (state.gamePhase) {
      case GamePhase.waitingForFingers:
        statusText = state.activeFingers.length < kMinFingersToStart
            ? "Place ${kMinFingersToStart - state.activeFingers.length} more finger${kMinFingersToStart - state.activeFingers.length > 1 ? 's' : ''}"
            : "Ready! Tap to start";
        statusColor = Colors.cyanAccent;
        break;
      case GamePhase.countdownActive:
        statusText = "Hold steady...";
        statusColor = Colors.orangeAccent;
        break;
      case GamePhase.selectionComplete:
        statusText = "Winner Selected! 🎉";
        statusColor = Colors.greenAccent;
        break;
      case GamePhase.falseStart:
        statusText = "False Start! Keep fingers down";
        statusColor = Colors.redAccent;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(state.gamePhase),
            color: statusColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .shimmer(duration: 2000.ms, color: statusColor.withOpacity(0.3));
  }

  IconData _getStatusIcon(GamePhase phase) {
    switch (phase) {
      case GamePhase.waitingForFingers:
        return Icons.touch_app_rounded;
      case GamePhase.countdownActive:
        return Icons.timer_rounded;
      case GamePhase.selectionComplete:
        return Icons.emoji_events_rounded;
      case GamePhase.falseStart:
        return Icons.warning_rounded;
    }
  }

  Widget _buildCountdownDisplay(ChooserScreenState state) {
    final progress = state.countdownSecondsRemaining / kCountdownSeconds;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.8),
                  Colors.purple.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(Colors.red, Colors.green, 1 - progress)!,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${state.countdownSecondsRemaining}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.purpleAccent,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.5, 0.5));
  }

  Widget _buildTouchArea(ChooserScreenState state, ChooserStateNotifier notifier) {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return Container(
          key: _touchAreaKey, // Add key here for position tracking
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05 + (_breatheController.value * 0.02)),
                Colors.white.withOpacity(0.02 + (_breatheController.value * 0.01)),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: notifier.addFinger,
                onPointerMove: notifier.moveFinger,
                onPointerUp: notifier.removeFinger,
                onPointerCancel: notifier.removeFinger,
                child: CustomPaint(
                  painter: UltraFingerPainter(
                    fingers: state.activeFingers,
                    selectedFinger: state.selectedFinger,
                    animationValue: _pulseController.value,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    ChooserScreenState state,
    ChooserStateNotifier notifier,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (state.gamePhase == GamePhase.waitingForFingers &&
              state.activeFingers.length >= kMinFingersToStart)
            Expanded(
              child: _buildGlassButton(
                label: "START",
                icon: Icons.play_arrow_rounded,
                onPressed: notifier.startCountdown,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                ),
              ),
            ),
          if (state.gamePhase == GamePhase.selectionComplete ||
              state.gamePhase == GamePhase.falseStart) ...[
            Expanded(
              child: _buildGlassButton(
                label: "PLAY AGAIN",
                icon: Icons.refresh_rounded,
                onPressed: () {
                  notifier.resetGame();
                  _confettiController.stop();
                },
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGlassButton(
                label: "EXIT",
                icon: Icons.home_rounded,
                onPressed: () => Navigator.of(context).pop(),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

// Ultra modern finger painter with glow effects
class UltraFingerPainter extends CustomPainter {
  final List<Finger> fingers;
  final Finger? selectedFinger;
  final double animationValue;

  UltraFingerPainter({
    required this.fingers,
    this.selectedFinger,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var finger in fingers) {
      final isSelected = selectedFinger?.id == finger.id;
      final baseRadius = isSelected ? 50.0 + (animationValue * 20) : 35.0;

      // Glow effect
      final glowPaint = Paint()
        ..color = (isSelected ? Colors.yellow : finger.color).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(finger.position, baseRadius + 20, glowPaint);

      // Outer ring
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(finger.position, baseRadius + 10, ringPaint);

      // Main circle with gradient effect
      final rect = Rect.fromCircle(center: finger.position, radius: baseRadius);
      final gradient = RadialGradient(
        colors: isSelected
            ? [Colors.yellow, Colors.orange, Colors.deepOrange]
            : [finger.color.withOpacity(0.8), finger.color.withOpacity(0.5)],
      );

      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawCircle(finger.position, baseRadius, paint);

      // Inner highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(finger.position.dx - 10, finger.position.dy - 10),
        baseRadius * 0.3,
        highlightPaint,
      );

      // Winner crown
      if (isSelected) {
        _drawCrown(canvas, finger.position, baseRadius);
      }
    }
  }

  void _drawCrown(Canvas canvas, Offset center, double radius) {
    final crownPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final crownPath = Path();
    final crownY = center.dy - radius - 20;
    final crownX = center.dx;

    crownPath.moveTo(crownX - 20, crownY + 10);
    crownPath.lineTo(crownX - 15, crownY - 5);
    crownPath.lineTo(crownX - 10, crownY + 5);
    crownPath.lineTo(crownX, crownY - 10);
    crownPath.lineTo(crownX + 10, crownY + 5);
    crownPath.lineTo(crownX + 15, crownY - 5);
    crownPath.lineTo(crownX + 20, crownY + 10);
    crownPath.close();

    canvas.drawPath(crownPath, crownPaint);
  }

  @override
  bool shouldRepaint(UltraFingerPainter oldDelegate) =>
      fingers != oldDelegate.fingers ||
      selectedFinger != oldDelegate.selectedFinger ||
      animationValue != oldDelegate.animationValue;
}

// Particle painter for background animation
class ParticlePainter extends CustomPainter {
  final double animationValue;
  final List<Particle> particles;

  ParticlePainter(this.animationValue)
      : particles = List.generate(
          50,
          (i) => Particle(
            index: i,
            seed: i * 0.618033988749895,
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = (particle.seed * size.width +
              animationValue * size.width * particle.speed) %
          size.width;
      final y = (particle.seed * size.height * 2) % size.height;
      final opacity = (math.sin(animationValue * math.pi * 2 + particle.seed * 10) + 1) / 2;

      paint.color = particle.color.withOpacity(opacity * 0.3);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class Particle {
  final int index;
  final double seed;
  final double size;
  final Color color;
  final double speed;

  Particle({
    required this.index,
    required this.seed,
  })  : size = 2 + (seed * 4),
        color = [
          Colors.purple,
          Colors.blue,
          Colors.cyan,
          Colors.pink,
        ][index % 4],
        speed = 0.1 + (seed * 0.3);
}
