import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';
import 'test_state_machine/test_side_effect_creators.dart';
import 'test_state_machine/test_side_effects.dart';
import 'test_state_machine/test_state_graph.dart';
import 'test_state_machine/test_state_machine_action.dart';
import 'test_state_machine/test_state_machine_state.dart';

void main() {
  group('BeforeSideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestBeforeSideEffectCreator(
        (prevState, action) {
          expect(prevState, const TestStateA());
          expect(action, const TestActionA());
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionA());

      expect(isSideEffectCreatorCalled, isTrue);
    });

    test('create method called when invalid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestBeforeSideEffectCreator(
        (prevState, action) {
          expect(prevState, const TestStateA());
          expect(action, const TestActionB());
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionB());

      expect(isSideEffectCreatorCalled, isTrue);
    });

    test('execute method called when create method returns side effect', () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = TestBeforeSideEffectCreator(
        (prevState, action) {
          return TestBeforeSideEffect(
            (currentState, action) async {
              expect(currentState, const TestStateA());
              expect(action, const TestActionA());
              isSideEffectExecuteCalled = true;
            },
          );
        },
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionA());

      expect(isSideEffectExecuteCalled, isTrue);
    });
  });
}