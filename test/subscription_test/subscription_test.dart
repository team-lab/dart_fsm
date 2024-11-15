import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

import '../test_state_graph.dart';
import '../test_state_machine_action.dart';
import '../test_state_machine_state.dart';

final class SampleSubscription
    implements Subscription<SampleState, SampleAction> {
  const SampleSubscription({
    required this.testSubscribe,
    required this.testDispose,
  });

  final void Function(StateMachine<SampleState, SampleAction> stateMachine)
      testSubscribe;
  final void Function() testDispose;

  @override
  void subscribe(StateMachine<SampleState, SampleAction> stateMachine) {
    testSubscribe(stateMachine);
  }

  @override
  void dispose() {
    testDispose();
  }
}

void main() {
  group('Subscription Test', () {
    test('subscribe method called when state machine created', () {
      var isSubscriptionCalled = false;

      final subscription = SampleSubscription(
        testSubscribe: (stateMachine) {
          expect(stateMachine.state, const SampleStateA());
          isSubscriptionCalled = true;
        },
        testDispose: () {},
      );

      createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: testStateGraph,
        subscriptions: [subscription],
      );

      expect(isSubscriptionCalled, isTrue);
    });

    test('dispose method called when valid transition', () {
      var isDisposeCalled = false;

      final subscription = SampleSubscription(
        testSubscribe: (stateMachine) {},
        testDispose: () {
          isDisposeCalled = true;
        },
      );

      final stateMachine = createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: testStateGraph,
        subscriptions: [subscription],
      );

      expect(isDisposeCalled, isFalse);

      stateMachine.close();

      expect(isDisposeCalled, isTrue);
    });
  });
}
