import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:finger_chooser_app/models/dare_model.dart';
import 'package:finger_chooser_app/models/finger_model.dart';
import 'package:finger_chooser_app/services/dare_service.dart';
import 'package:finger_chooser_app/features/finger_chooser/presentation/provider/chooser_models.dart';
import 'package:finger_chooser_app/features/finger_chooser/presentation/provider/chooser_state_provider.dart';

// Generate mocks for DareService
@GenerateMocks([DareService])
import 'chooser_state_provider_test.mocks.dart'; // Generated file

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized() is called to use SystemChannels
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChooserStateNotifier notifier;
  late MockDareService mockDareService;
  
  // For HapticFeedback mocking
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    mockDareService = MockDareService();
    // Provide the mockDareService to the notifier if it were injected.
    // Since it's instantiated directly, we can't easily inject a mock without refactoring the notifier.
    // For now, we'll test logic that doesn't strictly depend on DareService output where possible,
    // or accept that DareService calls will go to the real one unless we refactor.
    // For a robust test, DareService should be injectable.
    // However, the _selectWinner method directly instantiates DareService.
    // We will focus on testing other aspects and how it handles custom dares.
    
    notifier = ChooserStateNotifier();

    // Mock HapticFeedback
    SystemChannels.platform.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return null; // Return null for most haptic feedback calls
    });
    log.clear();
  });

  group('ChooserStateNotifier Tests', () {
    test('Initial state is correct', () {
      expect(notifier.debugState.gamePhase, GamePhase.waitingForFingers);
      expect(notifier.debugState.activeFingers, isEmpty);
      expect(notifier.debugState.selectedFinger, isNull);
      expect(notifier.debugState.selectedDare, isNull);
      expect(notifier.debugState.countdownSecondsRemaining, kCountdownSeconds);
      expect(notifier.debugState.canStartCountdown, isFalse);
      expect(notifier.debugState.customDares, isNull);
    });

    group('Finger Manipulation:', () {
      test('addFinger adds a finger and updates state', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        expect(notifier.debugState.activeFingers.length, 1);
        expect(notifier.debugState.activeFingers.first.id, 1);
        expect(notifier.debugState.gamePhase, GamePhase.waitingForFingers);
        expect(notifier.debugState.canStartCountdown, isFalse); // Need kMinFingersToStart

        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        expect(notifier.debugState.activeFingers.length, 2);
        expect(notifier.debugState.canStartCountdown, isTrue);
      });

      test('moveFinger updates finger position', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.moveFinger(const PointerMoveEvent(pointer: 1, position: Offset(15, 15)));
        expect(notifier.debugState.activeFingers.first.position, const Offset(15, 15));
      });
      
      test('moveFinger does nothing if game phase is countdownActive', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        notifier.startCountdown(); // Phase is now countdownActive
        
        notifier.moveFinger(const PointerMoveEvent(pointer: 1, position: Offset(100, 100)));
        // Expect original position because moveFinger should return early
        expect(notifier.debugState.activeFingers.firstWhere((f) => f.id == 1).position, isNot(const Offset(100,100)));
      });


      test('removeFinger removes a finger and updates state', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        
        notifier.removeFinger(const PointerUpEvent(pointer: 1, position: Offset(10, 10)));
        expect(notifier.debugState.activeFingers.length, 1);
        expect(notifier.debugState.activeFingers.first.id, 2);
        expect(notifier.debugState.canStartCountdown, isFalse);
      });
    });

    group('Countdown Logic:', () {
      test('startCountdown changes game phase and starts timer (indirectly)', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        
        notifier.startCountdown();
        expect(notifier.debugState.gamePhase, GamePhase.countdownActive);
        expect(notifier.debugState.countdownSecondsRemaining, kCountdownSeconds);
        // Haptic feedback for countdown start is in ChooserScreen listening to this phase
      });

      test('startCountdown does not start if not enough fingers', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.startCountdown();
        expect(notifier.debugState.gamePhase, GamePhase.waitingForFingers);
      });

      test('_tickCountdown reduces remaining seconds, then selects winner', () async {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        
        // Mock getRandomDare for _selectWinner part
        when(mockDareService.getRandomDare(criteria: anyNamed('criteria')))
            .thenAnswer((_) async => const Dare(id: 'd1', textEn: 'Test Dare', category: 'test', gender: [], groupType: [], place: [], intensity: "mild", minPlayers: 1));

        notifier.startCountdown();
        
        // Wait for countdown to finish
        // Due to the direct instantiation of DareService, we can't mock it for THIS notifier instance easily.
        // The test for _selectWinner will be limited.
        await Future.delayed(Duration(seconds: kCountdownSeconds + 1));

        expect(notifier.debugState.gamePhase, GamePhase.selectionComplete);
        expect(notifier.debugState.selectedFinger, isNotNull);
        // Dare selection part is harder to test without injecting DareService mock
      });
    });

    group('Winner Selection:', () {
      test('_selectWinner selects a finger and sets game phase to selectionComplete', () async {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        
        // Directly call _selectWinner (making it public for test or using a helper)
        // This is tricky as _selectWinner is private. We test it via countdown completion.
        // As noted, DareService interaction is hard to mock here.
        // We'll focus on the custom dare aspect.
        
        notifier.startCountdown();
        await Future.delayed(Duration(seconds: kCountdownSeconds + 1));

        expect(notifier.debugState.gamePhase, GamePhase.selectionComplete);
        expect(notifier.debugState.selectedFinger, isNotNull);
        expect(log.where((call) => call.method == 'HapticFeedback.vibrate' && call.arguments == 'HapticFeedbackType.heavyImpact'), isEmpty); //This is now done in the Notifier.
      });

      test('_selectWinner uses custom dares if available', () async {
        notifier.setCustomDares(['Custom Dare 1', 'Custom Dare 2']);
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));

        notifier.startCountdown();
        await Future.delayed(Duration(seconds: kCountdownSeconds + 1));
        
        expect(notifier.debugState.gamePhase, GamePhase.selectionComplete);
        expect(notifier.debugState.selectedFinger, isNotNull);
        expect(notifier.debugState.selectedDare, isNotNull);
        expect(['Custom Dare 1', 'Custom Dare 2'].contains(notifier.debugState.selectedDare!.textEn), isTrue);
        expect(notifier.debugState.selectedDare!.category, 'Custom');
      });
    });
    
    group('False Start Logic:', () {
      test('_handleFalseStart sets game phase to falseStart and clears selection', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.addFinger(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
        notifier.startCountdown();
        
        // Simulate removing a finger during countdown
        notifier.removeFinger(const PointerUpEvent(pointer: 1, position: Offset(10,10)));

        expect(notifier.debugState.gamePhase, GamePhase.falseStart);
        expect(notifier.debugState.selectedFinger, isNull);
        expect(notifier.debugState.selectedDare, isNull);
        // Haptic feedback for false start is in ChooserScreen listening to this phase
      });
    });

    group('Reset Game Logic:', () {
      test('resetGame resets the state to initial values', () {
        notifier.addFinger(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
        notifier.setCustomDares(['Dare']);
        notifier.startCountdown();
        // Let it select a winner
        return Future.delayed(Duration(seconds: kCountdownSeconds + 1), () {
          notifier.resetGame();
          expect(notifier.debugState.gamePhase, GamePhase.waitingForFingers);
          expect(notifier.debugState.activeFingers, isEmpty);
          expect(notifier.debugState.selectedFinger, isNull);
          expect(notifier.debugState.selectedDare, isNull);
          expect(notifier.debugState.customDares, isNull);
          expect(notifier.debugState.canStartCountdown, isFalse);
        });
      });
    });
    
    group('setCustomDares', () {
      test('setCustomDares updates the customDares in state', () {
        final testDares = ['Test Dare 1', 'Test Dare 2'];
        notifier.setCustomDares(testDares);
        expect(notifier.debugState.customDares, testDares);
      });
    });

  });
}
