import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

sealed class SampleState {
  const SampleState();
}

final class SampleStateA extends SampleState {
  const SampleStateA();
}

final class SampleStateB extends SampleState {
  const SampleStateB();
}

sealed class SampleAction {
  const SampleAction();
}

final class SampleActionA extends SampleAction {
  const SampleActionA();
}

void main() {
  final stateMachineGraph = GraphBuilder<SampleState, SampleAction>()
    ..state<SampleStateA>(
          (b) => b
        ..on<SampleActionA>(
              (state, action) => b.transitionTo(const SampleStateB()),
        ),
    );

  final stateMachine = createStateMachine(
    initialState: const SampleStateA(),
    graphBuilder: stateMachineGraph,
  );

  test('transition test', () {
    expect(stateMachine.state, const SampleStateA());

    stateMachine.dispatch(const SampleActionA());

    expect(stateMachine.state, const SampleStateB());
  });
}
