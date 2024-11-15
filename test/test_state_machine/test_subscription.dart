import 'package:dart_fsm/dart_fsm.dart';

import 'test_state_machine_action.dart';
import 'test_state_machine_state.dart';

final class TestSubscription implements Subscription<TestState, TestAction> {
  const TestSubscription({
    required this.testSubscribe,
    required this.testDispose,
  });

  final void Function(StateMachine<TestState, TestAction> stateMachine)
  testSubscribe;
  final void Function() testDispose;

  @override
  void subscribe(StateMachine<TestState, TestAction> stateMachine) {
    testSubscribe(stateMachine);
  }

  @override
  void dispose() {
    testDispose();
  }
}