import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

import 'test_state_machine/test_state_graph.dart';
import 'test_state_machine/test_state_machine_state.dart';
import 'test_state_machine/test_subscription.dart';

void main() {
  group('Subscription Test', () {
    test('subscribe method called when state machine created', () {
      var isSubscriptionCalled = false;

      final subscription = TestSubscription(
        testSubscribe: (stateMachine) {
          expect(stateMachine.state, const TestStateA());
          isSubscriptionCalled = true;
        },
        testDispose: () {},
      );

      createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        subscriptions: [subscription],
      );

      expect(isSubscriptionCalled, isTrue);
    });

    test('dispose method called when valid transition', () {
      var isDisposeCalled = false;

      final subscription = TestSubscription(
        testSubscribe: (stateMachine) {},
        testDispose: () {
          isDisposeCalled = true;
        },
      );

      final stateMachine = createStateMachine(
        initialState: const TestStateA(),
        graphBuilder: testStateGraph,
        subscriptions: [subscription],
      );

      expect(isDisposeCalled, isFalse);

      stateMachine.close();

      expect(isDisposeCalled, isTrue);
    });
  });
}
