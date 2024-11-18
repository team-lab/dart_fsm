// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

import 'test_state_machine/test_side_effect_creators.dart';
import 'test_state_machine/test_side_effects.dart';
import 'test_state_machine/test_state_graph.dart';
import 'test_state_machine/test_state_machine_action.dart';
import 'test_state_machine/test_state_machine_state.dart';

void main() {
  group('FinallySideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestFinallySideEffectCreator(
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

      final sideEffectCreator = TestFinallySideEffectCreator(
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

    test(
        // ignore: lines_longer_than_80_chars
        'execute method called when create method returns side effect and transition was valid',
        () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = TestFinallySideEffectCreator(
        (prevState, action) {
          return TestFinallySideEffect(
            (stateMachine, transition) {
              // state transition is done
              expect(stateMachine.state, const TestStateB());
              expect(
                (transition as Valid<TestState, TestAction>).fromState,
                const TestStateA(),
              );
              expect(transition.toState, const TestStateB());
              expect(transition.action, const TestActionA());
              isSideEffectExecuteCalled = true;
              return Future.value();
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

    test(
        // ignore: lines_longer_than_80_chars
        'execute method called when create method returns side effect and transition was invalid',
        () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = TestFinallySideEffectCreator(
        (prevState, action) {
          return TestFinallySideEffect(
            (stateMachine, transition) {
              // state transition is done
              expect(stateMachine.state, const TestStateA());
              expect(
                (transition as Invalid<TestState, TestAction>).fromState,
                const TestStateA(),
              );
              expect(transition.action, const TestActionB());
              isSideEffectExecuteCalled = true;
              return Future.value();
            },
          );
        },
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionB());

      expect(isSideEffectExecuteCalled, isTrue);
    });
  });
}
