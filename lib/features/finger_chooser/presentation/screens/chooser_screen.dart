// lib/features/finger_chooser/presentation/screens/chooser_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../dare_display/presentation/screens/dare_display_screen.dart'; 

import '../../../../providers/locale_provider.dart'; // For language switching
import '../provider/chooser_state_provider.dart'; // Our new state provider
import '../provider/chooser_models.dart';      // For GamePhase, ChooserScreenState
import '../../../../models/finger_model.dart';  // For Finger model

class ChooserScreen extends ConsumerStatefulWidget {
 // const ChooserScreen({super.key});
  final bool isQuickPlayMode; 

  const ChooserScreen({
    super.key,
    this.isQuickPlayMode = false, // Default to false (Party Play with dares)
  });


  @override
  ConsumerState<ChooserScreen> createState() => _ChooserScreenState();

}

class _ChooserScreenState extends ConsumerState<ChooserScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _instructionAnimController;
  late Animation<double> _instructionFadeAnimation;
  late Animation<Offset> _instructionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animation for instruction text
    _instructionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _instructionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _instructionAnimController, curve: Curves.easeOut),
    );

    _instructionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _instructionAnimController, curve: Curves.easeOutCubic),
    );

    _instructionAnimController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _instructionAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final chooserState = ref.watch(chooserStateProvider);
    final chooserNotifier = ref.read(chooserStateProvider.notifier); // <<< DEFINED HERE
    final bool currentIsQuickPlayMode = widget.isQuickPlayMode; // Access mode


    ref.listen<ChooserScreenState>(chooserStateProvider, (previous, next) {
      if (next.gamePhase == GamePhase.selectionComplete && next.selectedFinger != null) {
        _animationController.repeat(reverse: true); 

        // Only navigate to DareDisplayScreen if NOT in Quick Play mode
        if (!currentIsQuickPlayMode) { // <<< CHECK MODE HERE
          Future.delayed(const Duration(milliseconds: 2000), () { 
            _animationController.stop(); 
            _animationController.reset(); 


              if (ModalRoute.of(context)?.isCurrent ?? false) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DareDisplayScreen(
                      selectedFinger: next.selectedFinger,
                      selectedDare: next.selectedDare,
                    ),
                  ),
                ).then((_) {
                  chooserNotifier.resetGame();
                });
              }
            });
          } else {
            // In Quick Play mode, just show the result on ChooserScreen
            // The animation will play. The "Play Again" button will allow reset.
            // We might want to stop the animation after a shorter period if not navigating
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted && _animationController.isAnimating) { // Check if widget is still mounted
                  _animationController.stop();
                  _animationController.reset(); // Optionally reset or just let it sit at end of pulse
              }
            });
          }
        } else if (previous?.gamePhase == GamePhase.selectionComplete && 
                  next.gamePhase != GamePhase.selectionComplete) {
          _animationController.stop();
          _animationController.reset();
        } else if (next.gamePhase == GamePhase.falseStart) {
          _animationController.stop();
          _animationController.reset();
        }
        
        // Animate instruction changes
        if (previous?.gamePhase != next.gamePhase) {
          _instructionAnimController.reset();
          _instructionAnimController.forward();
        }
      });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentIsQuickPlayMode ? "Quick Pick" : localizations.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => ref.read(localeNotifierProvider.notifier).setLocale(const Locale('en', '')),
              child: const Text('EN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => ref.read(localeNotifierProvider.notifier).setLocale(const Locale('ar', '')),
              child: const Text('AR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(chooserState.gamePhase),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Instruction section with animation
              SlideTransition(
                position: _instructionSlideAnimation,
                child: FadeTransition(
                  opacity: _instructionFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPhaseIcon(chooserState.gamePhase),
                        const SizedBox(height: 12),
                        Text(
                          _getInstructionText(chooserState, localizations, currentIsQuickPlayMode),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Countdown indicator
              if (chooserState.gamePhase == GamePhase.countdownActive)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: chooserState.countdownSecondsRemaining / kCountdownSeconds,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        Center(
                          child: Text(
                            '${chooserState.countdownSecondsRemaining}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Finger interaction area
              Expanded(
                child: Listener(
                  onPointerDown: chooserNotifier.addFinger,
                  onPointerMove: chooserNotifier.moveFinger,
                  onPointerUp: chooserNotifier.removeFinger,
                  onPointerCancel: chooserNotifier.removeFinger,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: chooserState.gamePhase == GamePhase.falseStart
                          ? Colors.red.withOpacity(0.15)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: FingerPainter(
                              chooserState.activeFingers,
                              chooserState.selectedFinger,
                              (chooserState.gamePhase == GamePhase.selectionComplete &&
                                      chooserState.selectedFinger != null)
                                  ? _pulseAnimation.value
                                  : 1.0,
                            ),
                            size: Size.infinite,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Action buttons with improved styling
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildActionButton(chooserState, chooserNotifier, localizations),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(GamePhase phase) {
    switch (phase) {
      case GamePhase.waitingForFingers:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ];
      case GamePhase.countdownActive:
        return [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ];
      case GamePhase.selectionComplete:
        return [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ];
      case GamePhase.falseStart:
        return [
          const Color(0xFFfa709a),
          const Color(0xFFfee140),
        ];
    }
  }

  Widget _buildPhaseIcon(GamePhase phase) {
    IconData icon;
    Color color = Colors.white;
    
    switch (phase) {
      case GamePhase.waitingForFingers:
        icon = Icons.touch_app;
        break;
      case GamePhase.countdownActive:
        icon = Icons.timer;
        break;
      case GamePhase.selectionComplete:
        icon = Icons.celebration;
        break;
      case GamePhase.falseStart:
        icon = Icons.warning_rounded;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 32,
        color: color,
      ),
    );
  }

  Widget _buildActionButton(
    ChooserScreenState state,
    ChooserStateNotifier notifier,
    AppLocalizations localizations,
  ) {
    if (state.gamePhase == GamePhase.selectionComplete) {
      return _StyledButton(
        onPressed: () {
          _animationController.stop();
          _animationController.reset();
          notifier.resetGame();
        },
        icon: Icons.refresh_rounded,
        label: "Play Again",
        backgroundColor: Colors.white,
        textColor: const Color(0xFF667eea),
      );
    } else if (state.gamePhase == GamePhase.falseStart) {
      return _StyledButton(
        onPressed: notifier.resetGame,
        icon: Icons.replay,
        label: "Try Again",
        backgroundColor: Colors.white,
        textColor: const Color(0xFFfa709a),
      );
    } else {
      return _StyledButton(
        onPressed: state.canStartCountdown && state.gamePhase == GamePhase.waitingForFingers
            ? notifier.startCountdown
            : null,
        icon: Icons.play_arrow_rounded,
        label: localizations.selectButton,
        backgroundColor: Colors.white,
        textColor: const Color(0xFF667eea),
      );
    }
  }

  String _getInstructionText(
    ChooserScreenState state,
    AppLocalizations localizations,
    bool isQuickPlayMode,
  ) {
    switch (state.gamePhase) {
      case GamePhase.waitingForFingers:
        return state.activeFingers.isEmpty
            ? localizations.placeFingersPrompt
            : "${state.activeFingers.length} ${state.activeFingers.length == 1 ? 'finger' : 'fingers'} on screen. Need at least $kMinFingersToStart.";
      case GamePhase.countdownActive:
        return "Get ready! Choosing in ${state.countdownSecondsRemaining}...";
      case GamePhase.selectionComplete:
        if (state.selectedFinger != null) {
          if (isQuickPlayMode) {
            return "🎉 Finger ${state.selectedFinger!.id} wins!";
          } else {
            return "🎊 ${localizations.appTitle}: Finger ${state.selectedFinger!.id} is chosen!";
          }
        }
        return "Selection complete!";
      case GamePhase.falseStart:
        return "⚠️ False Start! Keep all fingers down!";
    }
  }
}

// Styled button widget for consistent button design
class _StyledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StyledButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: onPressed != null ? 8 : 2,
      borderRadius: BorderRadius.circular(30),
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Opacity(
          opacity: onPressed != null ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: textColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// FingerPainter class (at the bottom of chooser_screen.dart)
class FingerPainter extends CustomPainter {
  final List<Finger> fingers;
  final Finger? selectedFinger;
  final double selectionScale;
  
  // Pre-calculated particle angles for better performance
  static const List<double> _particleAngles = [
    0.0,
    math.pi / 4,
    math.pi / 2,
    3 * math.pi / 4,
    math.pi,
    5 * math.pi / 4,
    3 * math.pi / 2,
    7 * math.pi / 4,
  ];

  FingerPainter(this.fingers, this.selectedFinger, this.selectionScale);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fingerPaint = Paint()..style = PaintingStyle.fill;
    
    final Paint highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
    
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    const double baseRadius = 35.0;
    const double baseHighlightStrokeWidth = 6.0;

    // Draw non-selected fingers first
    for (final finger in fingers) {
      if (selectedFinger != null && finger.id == selectedFinger!.id) continue;
      
      fingerPaint.color = finger.color;
      
      // Draw shadow/glow
      glowPaint.color = finger.color.withOpacity(0.3);
      canvas.drawCircle(finger.position, baseRadius + 8, glowPaint);
      
      // Draw main finger circle
      canvas.drawCircle(finger.position, baseRadius, fingerPaint);
      
      // Draw inner highlight
      final Paint innerHighlight = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(finger.position.dx - 8, finger.position.dy - 8),
        baseRadius * 0.3,
        innerHighlight,
      );
    }

    // Draw selected finger last (on top)
    if (selectedFinger != null) {
      final fingerIndex = fingers.indexWhere((f) => f.id == selectedFinger!.id);
      if (fingerIndex == -1) return; // Safety check: finger not found
      
      final finger = fingers[fingerIndex];
      fingerPaint.color = finger.color;
      
      final double currentDisplayRadius = baseRadius * selectionScale;
      
      // Draw pulsing glow
      glowPaint.color = finger.color.withOpacity(0.4 * selectionScale);
      canvas.drawCircle(finger.position, currentDisplayRadius + 20 * selectionScale, glowPaint);
      
      // Draw highlight ring
      final double currentHighlightRadius = currentDisplayRadius + (baseHighlightStrokeWidth / 2);
      final double currentHighlightStroke = baseHighlightStrokeWidth * selectionScale;
      
      canvas.drawCircle(
        finger.position,
        currentHighlightRadius,
        highlightPaint..strokeWidth = currentHighlightStroke,
      );
      
      // Draw main finger circle
      canvas.drawCircle(finger.position, currentDisplayRadius, fingerPaint);
      
      // Draw inner highlight
      final Paint innerHighlight = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(finger.position.dx - 10 * selectionScale, finger.position.dy - 10 * selectionScale),
        currentDisplayRadius * 0.3,
        innerHighlight,
      );
      
      // Draw particle effects around selected finger
      for (int i = 0; i < _particleAngles.length; i++) {
        final angle = _particleAngles[i] + (selectionScale * math.pi / 4);
        final distance = currentDisplayRadius + 25 * selectionScale;
        final particleX = finger.position.dx + math.cos(angle) * distance;
        final particleY = finger.position.dy + math.sin(angle) * distance;
        
        final Paint particlePaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(particleX, particleY),
          3 * selectionScale,
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FingerPainter oldDelegate) {
    return oldDelegate.fingers != fingers || 
           oldDelegate.selectedFinger != selectedFinger || 
           oldDelegate.selectionScale != selectionScale;
  }
}