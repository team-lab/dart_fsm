// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../state_machine.dart';

/// [SideEffect] executed after the [ACTION] is dispatched and the [STATE] is
/// changed. This [SideEffect] is executed only when the transition is made.
abstract interface class AfterSideEffect<STATE extends Object,
    ACTION extends Object> implements SideEffect {
  const AfterSideEffect(); // coverage:ignore-line

  /// The method executed after the instance of [AfterSideEffect] is generated
  /// by [AfterSideEffectCreator].
  /// The current [StateMachine] and the [Transition] when this [SideEffect] was
  /// generated are passed as arguments.
  Future<void> execute(
    StateMachine<STATE, ACTION> stateMachine,
  );
}

/// [SideEffect] executed after the [ACTION] is dispatched, executed before the
/// [STATE] is changed, and executed regardless of whether the transition is
/// made.
abstract interface class BeforeSideEffect<STATE extends Object,
    ACTION extends Object> implements SideEffect {
  const BeforeSideEffect(); // coverage:ignore-line

  /// The method executed after the instance of [BeforeSideEffect] is generated
  /// by [BeforeSideEffectCreator].
  /// The current [STATE] and the [ACTION] when this [SideEffect] was generated
  /// are passed as arguments.
  Future<void> execute(
    STATE currentState,
    ACTION action,
  );
}

/// [SideEffect] executed after the [ACTION] is dispatched, executed after the
/// all other processes are finished, and executed regardless of whether the
/// transition is made.
abstract interface class FinallySideEffect<STATE extends Object,
    ACTION extends Object> implements SideEffect {
  const FinallySideEffect(); // coverage:ignore-line

  /// The method executed after the instance of [FinallySideEffect] is generated
  /// by [FinallySideEffectCreator].
  /// The current [STATE] and the [ACTION] when this [SideEffect] was generated
  /// are passed as arguments.
  Future<void> execute(
    StateMachine<STATE, ACTION> stateMachine,
    Transition<STATE, ACTION> transition,
  );
}
