part of '../state_machine.dart';

/// Interface of the class that generates SideEffect
abstract interface class SideEffectCreator<STATE extends StateMachineState,
    ACTION extends StateMachineAction, SIDE_EFFECT extends SideEffect> {
  const SideEffectCreator._();

  /// Create a [SIDE_EFFECT] from the [STATE] and [ACTION] before the transition
  /// [prevState] The state before the transition
  /// [action] The action that was executed
  /// [SIDE_EFFECT] The generated side effect
  SIDE_EFFECT? create(STATE prevState, ACTION action);
}

/// Interface of the class that generates SideEffect after the transition
abstract interface class AfterSideEffectCreator<STATE extends StateMachineState,
        ACTION extends StateMachineAction, SIDE_EFFECT extends AfterSideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const AfterSideEffectCreator._();
}

/// Interface of the class that generates SideEffect before the transition
abstract interface class BeforeSideEffectCreator<
        STATE extends StateMachineState,
        ACTION extends StateMachineAction,
        SIDE_EFFECT extends BeforeSideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const BeforeSideEffectCreator._();
}

/// Interface of the class that generates SideEffect that is executed at the
/// end of the process when an Action is dispatched regardless of whether
/// a transition is made
abstract interface class FinallySideEffectCreator<
        STATE extends StateMachineState,
        ACTION extends StateMachineAction,
        SIDE_EFFECT extends FinallySideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const FinallySideEffectCreator._();
}
