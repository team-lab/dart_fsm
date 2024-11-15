// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of 'state_machine.dart';

/// This function creates a [StateMachine] with the given [graphBuilder],
/// [initialState], [sideEffectCreators], and [subscriptions].
/// This function exists to hide [StateMachineImpl].
StateMachine<STATE, ACTION>
    createStateMachine<STATE extends Object, ACTION extends Object>({
  required GraphBuilder<STATE, ACTION> graphBuilder,
  required STATE initialState,
  List<SideEffectCreator<Object, Object, SideEffect>> sideEffectCreators =
      const [],
  List<Subscription<STATE, ACTION>> subscriptions = const [],
}) {
  return StateMachineImpl<STATE, ACTION>(
    graphBuilder: graphBuilder,
    initialState: initialState,
    sideEffectCreators: sideEffectCreators,
    subscriptions: subscriptions,
  );
}
