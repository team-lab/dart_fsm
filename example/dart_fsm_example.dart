// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/dart_fsm.dart';

// State
sealed class SampleState
{
  const SampleState();
}

final class SampleStateA extends SampleState {
  const SampleStateA();
}

final class SampleStateB extends SampleState {
  const SampleStateB();
}

// Action
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

  print(stateMachine.state); // SampleStateA

  stateMachine.dispatch(const SampleActionA());

  print(stateMachine.state); // SampleStateB
}
