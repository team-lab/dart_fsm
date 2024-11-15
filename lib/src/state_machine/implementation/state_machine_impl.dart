// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dart_fsm/dart_fsm.dart';

/// A state machine implementation.
class StateMachineImpl<STATE extends Object, ACTION extends Object>
    implements StateMachine<STATE, ACTION> {
  /// Creates a state machine.
  /// [graphBuilder] is a builder for the state machine's graph.
  /// [initialState] is the initial state of the state machine.
  /// [sideEffectCreators] is a list of side effect creators.
  /// [subscriptions] is a list of subscriptions.
  StateMachineImpl({
    required GraphBuilder<STATE, ACTION> graphBuilder,
    required STATE initialState,
    List<SideEffectCreator<Object, Object, SideEffect>> sideEffectCreators =
        const [],
    List<Subscription<STATE, ACTION>> subscriptions = const [],
  })  : _initialState = initialState,
        _graph = graphBuilder.build(),
        _state = initialState,
        _sideEffectCreators = sideEffectCreators,
        _subscriptions = subscriptions {
    _controller.add(_initialState);
    if (_isEnd(_initialState)) {
      close();
    }
    for (final subscription in subscriptions) {
      subscription.subscribe(this);
    }
  }

  final Graph<STATE, ACTION> _graph;

  final STATE _initialState;

  final List<SideEffectCreator<Object, Object, SideEffect>> _sideEffectCreators;

  final List<Subscription<STATE, ACTION>> _subscriptions;

  final StreamController<STATE> _controller =
      StreamController<STATE>.broadcast();

  @override
  Stream<STATE> get stateStream => _controller.stream.asBroadcastStream();

  @override
  STATE get state => _state;

  STATE _state;

  @override
  void close() {
    _controller.close();
    for (final subscription in _subscriptions) {
      subscription.dispose();
    }
  }

  @override
  void dispatch(ACTION action) {
    beforeJob(action);
    final transition = findTransition(_state, action);
    if (transition is Valid) {
      _state = (transition as Valid).toState as STATE;
      _controller.add(_state);
      afterJob(action, transition as Valid<STATE, ACTION>);
    }
    finallyJob(transition);
  }

  /// Finds a [Transition] corresponding to [currentState] and [action] from the
  /// [Graph] of the [StateMachine].
  /// If found, it returns the destination [STATE] as [Valid], and if not found,
  /// it returns [Invalid].
  Transition<STATE, ACTION> findTransition(STATE currentState, ACTION action) {
    final stateConfig =
        _graph.transitionPatternMap.entries.firstWhereOrNull((element) {
      if (element.key.matches(currentState)) {
        return element.value.transitionMap.entries
                .firstWhereOrNull((element) => element.key.matches(action)) !=
            null;
      } else {
        return false;
      }
    });
    if (stateConfig == null) {
      return Invalid(currentState, action);
    }

    final transition = stateConfig.value.transitionMap.entries
        .firstWhere((element) => element.key.matches(action))
        .value(currentState, action);

    return Valid<STATE, ACTION>(currentState, action, transition.toState);
  }

  /// Create [BeforeSideEffect] from [BeforeSideEffectCreator]
  List<BeforeSideEffect> findBeforeJob(ACTION action) {
    final sideEffects = <BeforeSideEffect>[];
    for (final sideEffectCreator
        in _sideEffectCreators.whereType<BeforeSideEffectCreator>()) {
      final sideEffect = sideEffectCreator.create(_state, action);
      if (sideEffect != null) {
        sideEffects.add(sideEffect);
      }
    }
    return sideEffects;
  }

  /// Execute [BeforeSideEffect]
  Future<void> beforeJob(ACTION action) async {
    findBeforeJob(action).forEach((sideEffect) {
      unawaited(sideEffect.execute(_state, action));
    });
  }

  /// Create [AfterSideEffect] from [AfterSideEffectCreator]
  List<AfterSideEffect> findAfterJob(
    ACTION action,
    Valid<STATE, ACTION> validTransition,
  ) {
    final sideEffects = <AfterSideEffect>[];
    for (final sideEffectCreator
        in _sideEffectCreators.whereType<AfterSideEffectCreator>()) {
      final sideEffect =
          sideEffectCreator.create(validTransition.fromState, action);
      if (sideEffect != null) {
        sideEffects.add(sideEffect);
      }
    }
    return sideEffects;
  }

  /// Execute [AfterSideEffect]
  Future<void> afterJob(
    ACTION action,
    Valid<STATE, ACTION> validTransition,
  ) async {
    findAfterJob(action, validTransition).forEach((sideEffect) {
      unawaited(sideEffect.execute(this));
    });
    if (_isEnd(validTransition.toState)) {
      close();
    }
  }

  /// Create [FinallySideEffect] from [FinallySideEffectCreator]
  List<FinallySideEffect> findFinallyJob(
    Transition<STATE, ACTION> transition,
  ) {
    final sideEffects = <FinallySideEffect>[];
    for (final sideEffectCreator
        in _sideEffectCreators.whereType<FinallySideEffectCreator>()) {
      final sideEffect =
          sideEffectCreator.create(transition.fromState, transition.action);
      if (sideEffect != null) {
        sideEffects.add(sideEffect);
      }
    }
    return sideEffects;
  }

  /// Execute [FinallySideEffect]
  Future<void> finallyJob(Transition<STATE, ACTION> transition) async {
    findFinallyJob(transition).forEach((sideEffect) {
      unawaited(sideEffect.execute(this, transition));
    });
  }

  /// Is the state end of [Graph]?
  bool _isEnd(STATE state) {
    return _graph.transitionPatternMap.entries
        .where((element) => element.key.matches(state))
        .map((e) => e.value.transitionMap.entries)
        .expand((element) => element)
        .isEmpty;
  }
}
