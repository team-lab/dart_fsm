// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/dart_fsm.dart';
import 'package:dart_fsm/src/state_machine/implementation/state_machine_impl.dart';

/// A state machine for testing.
class TesterStateMachine<STATE extends Object, ACTION extends Object>
    extends StateMachineImpl<STATE, ACTION> {
  /// Creates a state machine for testing.
  TesterStateMachine({
    required super.graphBuilder,
    required super.initialState,
    List<SideEffectCreator<STATE, ACTION, SideEffect>>
        super.sideEffectCreators = const [],
    super.subscriptions,
  });

  /// The created side effects.
  List<SideEffect> get createdSideEffect => _createdSideEffect;

  final List<SideEffect> _createdSideEffect = [];

  /// Whether the previous transition is valid.
  bool get isPrevTransitionValid => _isPrevTransitionValid;

  bool _isPrevTransitionValid = false;

  @override
  void dispatch(ACTION action) {
    _createdSideEffect.clear();
    _isPrevTransitionValid = findTransition(state, action) is Valid;
    super.dispatch(action);
  }

  @override
  Future<void> beforeJob(ACTION action) async {
    findBeforeJob(action).forEach(_createdSideEffect.add);
  }

  @override
  Future<void> afterJob(
    ACTION action,
    Valid<STATE, ACTION> validTransition,
  ) async {
    findAfterJob(action, validTransition).forEach(_createdSideEffect.add);
  }

  @override
  Future<void> finallyJob(Transition<STATE, ACTION> transition) async {
    findFinallyJob(transition).forEach(_createdSideEffect.add);
  }
}
