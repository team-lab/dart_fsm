import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

import 'test_state_machine/test_state_machine_action.dart';
import 'test_state_machine/test_state_machine_state.dart';
import 'test_state_machine/test_subscription.dart';

void main() {
  group('StateMachine Close Test', () {
    final simpleTestStateGraph = GraphBuilder<TestState, TestAction>()
      ..state<TestStateA>(
        (b) => b
          ..on<TestActionA>(
            (state, action) => b.transitionTo(const TestStateB()),
          ),
      );

    test('close method called when state machine state is end', () {
      var isCloseCalled = false;

      final subscription = TestSubscription(
        testSubscribe: (stateMachine) {},
        testDispose: () {
          isCloseCalled = true;
        },
      );

      final stateMachine = createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: simpleTestStateGraph,
        subscriptions: [subscription],
      );

      expect(isCloseCalled, isFalse);

      stateMachine.dispatch(const TestActionA());

      expect(isCloseCalled, isTrue);
    });

    test('close method called when state machine initial state is end', () {
      var isCloseCalled = false;

      final subscription = TestSubscription(
        testSubscribe: (stateMachine) {},
        testDispose: () {
          isCloseCalled = true;
        },
      );

      createStateMachine(
        initialState: const TestStateB(),
        graphBuilder: simpleTestStateGraph,
        subscriptions: [subscription],
      );

      expect(isCloseCalled, isTrue);
    });
  });
}
