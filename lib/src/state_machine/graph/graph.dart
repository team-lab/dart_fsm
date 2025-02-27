// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// A class representing state transitions
/// It has a map representing the pattern of state transitions
@immutable
final class Graph<STATE extends Object, ACTION extends Object> {
  /// Creates a new graph with the given transition pattern map
  const Graph(this.transitionPatternMap);

  /// A map of [Matcher<STATE>] and [GraphState<STATE, ACTION>]
  /// Specify the transition before the state with [Matcher<STATE>], and
  /// specify the action required for the transition and the state after the
  /// transition with [GraphState<STATE, ACTION>]
  /// Typically instantiated by GraphBuilder
  final Map<Matcher<STATE>, GraphState<STATE, ACTION>> transitionPatternMap;
}

/// A class representing the information of which state to transition to when a
/// particular action is dispatched
/// As for the information of the state before the transition, it is specified
/// in the transitionPatternMap of Graph, so here, it holds the information of
/// the action required for the transition and the state after the transition
/// Typically instantiated by StateConfigBuilder
final class GraphState<STATE extends Object, ACTION extends Object> {
  /// Creates a new graph state with the given transition map
  const GraphState(this.transitionMap);

  /// A map of [Matcher<ACTION>] and
  /// [StateTransitionFunction<STATE, ACTION, STATE>]. Specify the action
  /// required for the transition with [Matcher<ACTION>], and specify the state
  /// after the transition with [StateTransitionFunction<STATE, ACTION, STATE>]
  /// Typically instantiated by StateConfigBuilder.
  /// The state before the transition is specified in the transitionPatternMap
  /// of Graph so here, it holds the information of the action required for the
  /// transition and the state after the transition.
  final Map<Matcher<ACTION>, StateTransitionFunction<STATE, ACTION, STATE>>
      transitionMap;
}

/// A function that takes the state before the transition and the action and
/// returns the new state after the transition in the form of [TransitionTo]
typedef StateTransitionFunction<STATE extends Object, ACTION extends Object,
        ON_STATE extends STATE>
    = TransitionTo<STATE> Function(ON_STATE currentState, ACTION action);

/// A class representing the state after the
@immutable
final class TransitionTo<STATE extends Object> {
  /// Creates a new transition to with the given state
  const TransitionTo(this.toState);

  /// The state after the transition
  final STATE toState;
}

/// A class that performs type matching.
/// By specifying this as the key of a Map, you can write branching logic that
@immutable
final class Matcher<T> {
  /// Creates a new matcher
  const Matcher();

  @override
  bool operator ==(Object other) {
    return other is Matcher<T>;
  }

  @override
  int get hashCode => T.hashCode;

  /// Returns true if the given value matches the type T
  bool matches(dynamic value) {
    final result = value is T;
    return result;
  }
}

/// The type of function that the Builder for building the Graph receives
typedef StateConfigBuilderFunction<STATE extends Object, ACTION extends Object,
        ON_STATE extends STATE>
    = StateConfigBuilder<STATE, ACTION, ON_STATE> Function(
  StateConfigBuilder<STATE, ACTION, ON_STATE>,
);

/// Builder for building [GraphState]
@immutable
class StateConfigBuilder<STATE extends Object, ACTION extends Object,
    ON_STATE extends STATE> {
  final GraphState<STATE, ACTION> _stateFactor = GraphState<STATE, ACTION>({});

  /// When a specific Action is dispatched, transition to the State specified in
  /// transition.
  void on<ON_ACTION extends ACTION>(
    StateTransitionFunction<STATE, ON_ACTION, ON_STATE> transition,
  ) {
    assert(
      _stateFactor.transitionMap[Matcher<ON_ACTION>()] == null,
      'Duplicate action: $ON_ACTION',
    );
    _stateFactor.transitionMap[Matcher<ON_ACTION>()] = (currentState, action) {
      return transition(currentState as ON_STATE, action as ON_ACTION);
    };
  }

  /// Use this when you want to execute AfterSideEffect without transitioning
  void noTransitionOn<ON_ACTION extends ACTION>() {
    _stateFactor.transitionMap[Matcher<ON_ACTION>()] = (currentState, action) {
      return TransitionTo(currentState as ON_STATE);
    };
  }

  /// When any Action is dispatched, transition to the State specified in
  /// transition.
  void onAny(StateTransitionFunction<STATE, ACTION, ON_STATE> transition) {
    on(transition);
  }

  /// Builds a GraphState
  GraphState<STATE, ACTION> build() {
    return _stateFactor;
  }

  /// A function to specify the state after the transition
  TransitionTo<STATE> transitionTo(STATE newState) {
    return TransitionTo(newState);
  }
}
