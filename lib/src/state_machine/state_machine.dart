import 'dart:async';

import 'package:dart_fsm/src/state_machine/implementation/state_machine_impl.dart';

part './side_effect/side_effect_creators.dart';
part './side_effect/side_effects.dart';
part './subscription/subscription.dart';
part 'graph.dart';
part 'state_machine_creator.dart';

/// A state machine.
abstract interface class StateMachine<STATE extends Object,
    ACTION extends Object> {
  const StateMachine();

  /// The current state of the state machine.
  STATE get state;

  /// A stream of the state machine's state.
  Stream<STATE> get stateStream;

  /// Dispatches an action to the state machine.
  void dispatch(ACTION action);

  /// Closes the state machine and releases resources.
  void close();
}
