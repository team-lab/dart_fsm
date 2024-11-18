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
  group('AfterSideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestAfterSideEffectCreator(
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

    test('create method called when noTransition valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestAfterSideEffectCreator(
        (prevState, action) {
          expect(prevState, const TestStateC());
          expect(action, const TestActionD());
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const TestStateC(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionD());

      expect(isSideEffectCreatorCalled, isTrue);
    });

    test('not create method called when invalid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = TestAfterSideEffectCreator(
        (prevState, action) {
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionB());

      expect(isSideEffectCreatorCalled, isFalse);
    });

    test('execute method called when create method returns side effect', () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = TestAfterSideEffectCreator(
        (prevState, action) {
          return TestAfterSideEffect(
            (stateMachine) {
              // state transition is done
              expect(stateMachine.state, const TestStateB());
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
        'execute method called when create method returns side effect and noTransition valid transition',
        () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = TestAfterSideEffectCreator(
        (prevState, action) {
          return TestAfterSideEffect(
            (stateMachine) {
              // state transition is done
              expect(stateMachine.state, const TestStateC());
              isSideEffectExecuteCalled = true;
              return Future.value();
            },
          );
        },
      );

      createStateMachine(
        initialState: const TestStateC(),
        graphBuilder: testStateGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const TestActionD());

      expect(isSideEffectExecuteCalled, isTrue);
    });
  });
}
