import 'package:dart_fsm/dart_fsm.dart';

// State
sealed class SampleState implements StateMachineState {
  const SampleState();
}

final class SampleStateA extends SampleState {
  const SampleStateA();
}

final class SampleStateB extends SampleState {
  const SampleStateB();
}

// Action
sealed class SampleAction implements StateMachineAction {
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

  print(stateMachine.state); // SampleStateA

  stateMachine.dispatch(const SampleActionA());

  print(stateMachine.state); // SampleStateB
}
