part of 'state_machine.dart';

/// This function creates a [StateMachine] with the given [graphBuilder],
/// [initialState], [sideEffectCreators], and [subscriptions].
/// This function exists to hide [StateMachineImpl].
StateMachine<STATE, ACTION> createStateMachine<STATE extends StateMachineState,
    ACTION extends StateMachineAction>({
  required GraphBuilder<STATE, ACTION> graphBuilder,
  required STATE initialState,
  List<SideEffectCreator<StateMachineState, StateMachineAction, SideEffect>>
      sideEffectCreators = const [],
  List<Subscription<STATE, ACTION>> subscriptions = const [],
}) {
  return StateMachineImpl<STATE, ACTION>(
    graphBuilder: graphBuilder,
    initialState: initialState,
    sideEffectCreators: sideEffectCreators,
    subscriptions: subscriptions,
  );
}
