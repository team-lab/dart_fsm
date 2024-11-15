import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

import 'test_state_machine/test_state_graph.dart';
import 'test_state_machine/test_state_machine_action.dart';
import 'test_state_machine/test_state_machine_state.dart';

/*
    ┌─────ActionB──────┐
    │                  │
    │  ┌──ActionA───►StateB
    │  │                  ┌───┐
    ▼  │                  │   │
 StateA┼──ActionC───►StateC  ActionD
    ▲  │                  ▲   │
    │  │                  └───┘
    │  └──ActionD───►StateD
    │                  │
    └─────AnyAction────┘
 */

void main() {
  group('Transition Test', () {
    test('transition to next state when valid transition', () {
      final stateMachine = createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
      );

      expect(stateMachine.state, const TestStateA());

      stateMachine.dispatch(const TestActionA());

      expect(stateMachine.state, const TestStateB());
    });
    test('not transition to next state when invalid action', () {
      final stateMachine = createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
      );

      expect(stateMachine.state, const TestStateA());

      stateMachine.dispatch(const TestActionB());

      expect(stateMachine.state, const TestStateA());
    });
    test('not transition to next state when no transition', () {
      final stateMachine = createStateMachine(
        initialState: const TestStateC(),
        graphBuilder: testStateGraph,
      );

      expect(stateMachine.state, const TestStateC());

      stateMachine.dispatch(const TestActionD());

      expect(stateMachine.state, const TestStateC());
    });
    test('transition to next state when any action', () {
      final actions = [
        const TestActionA(),
        const TestActionB(),
        const TestActionC(),
        const TestActionD(),
      ];
      for (final action in actions) {
        final stateMachine = createStateMachine(
          initialState: const TestStateD(),
          graphBuilder: testStateGraph,
        );

        expect(stateMachine.state, const TestStateD());

        stateMachine.dispatch(action);

        expect(stateMachine.state, const TestStateA());
      }
    });
  });
}
