// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../state_machine.dart';

/// A builder for building the [Graph]
@immutable
class GraphBuilder<STATE extends Object, ACTION extends Object> {
  ///
  final Map<Matcher<STATE>, GraphState<STATE, ACTION>> _stateConfigMap = {};

  /// Used to define actions that can be taken in a specific state.
  /// When ACTION is dispatched while it's ON_STATE, the transition to the
  /// specified state will happen.
  void state<ON_STATE extends STATE>(
    StateConfigBuilderFunction<STATE, ACTION, ON_STATE> stateConfigBuilder,
  ) {
    assert(
      !_stateConfigMap.containsKey(Matcher<ON_STATE>()),
      'Duplicate state: $ON_STATE',
    );
    // Generate a StateConfigBuilder here and register it in the Map
    _stateConfigMap[Matcher<ON_STATE>()] =
        stateConfigBuilder(StateConfigBuilder<STATE, ACTION, ON_STATE>())
            .build();
  }

  /// Builds a Graph
  Graph<STATE, ACTION> build() {
    return Graph<STATE, ACTION>(_stateConfigMap);
  }
}
