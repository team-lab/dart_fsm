// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../state_machine.dart';

/// A parent class for representing state transition patterns
/// It is common to have the state before the transition and the action, and
/// this class is inherited by Valid and Invalid to branch.
sealed class Transition<STATE extends Object, ACTION extends Object> {
  const Transition(this.fromState, this.action);

  /// The state before the transition
  final STATE fromState;

  /// The action when the transition is made
  final ACTION action;
}

/// A class representing the state transition pattern when the transition is
/// valid. In addition to the state before the transition and the action, it
/// also holds the state after the transition. The state before the transition
/// and the action are inherited from Transition, and the state after the
/// transition is added.
@immutable
final class Valid<STATE extends Object, ACTION extends Object>
    extends Transition<STATE, ACTION> {
  /// Creates a new valid transition with the given state
  const Valid(super.fromState, super.action, this.toState);

  /// The state after the transition
  final STATE toState;
}

/// A class representing the state transition pattern when the transition is
/// invalid. It has the same state before the transition and the action as
/// Transition, but it does not have the state after the transition.
@immutable
final class Invalid<STATE extends Object, ACTION extends Object>
    extends Transition<STATE, ACTION> {
  /// Creates a new invalid transition
  const Invalid(super.fromState, super.action);
}
