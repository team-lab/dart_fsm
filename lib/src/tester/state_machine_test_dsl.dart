// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dart_fsm/dart_fsm.dart' as fsm;
import 'package:test/test.dart';

/// Creates a real StateMachine for one transition test case.
///
/// The runner passes a fresh mock bundle and the source state for the case.
/// Implementations should return the production StateMachine with that source
/// state as its initial state.
typedef StateMachineFactory<STATE extends Object, ACTION extends Object,
        MOCKS extends Object>
    = fsm.StateMachine<STATE, ACTION> Function(
  MOCKS mocks,
  STATE initialState,
);

/// A list of transition specifications for a StateMachine.
///
/// Each entry describes all action expectations for one source state.
typedef StateMachineTestCases<STATE extends Object, ACTION extends Object,
        MOCKS extends Object>
    = List<StateCase<STATE, ACTION, MOCKS>>;

/// Arranges external dependencies before an action is dispatched.
///
/// Keep repository stubbing here so that the transition expectation remains
/// separate from dependency setup. The runner waits for asynchronous setup to
/// complete before creating the StateMachine.
typedef MockArrange<MOCKS extends Object> = FutureOr<void> Function(
  MOCKS mocks,
);

/// Verifies external dependency interactions after a transition settles.
///
/// Keep repository verification here so that side effects are asserted
/// separately from state transitions. The runner waits for asynchronous
/// verification to complete before cleaning up the test case.
typedef MockVerify<MOCKS extends Object> = FutureOr<void> Function(
  MOCKS mocks,
);

/// Runs custom setup or teardown around each generated test case.
typedef StateMachineTestHook = FutureOr<void> Function();

/// Registers exhaustive Given-When-Then transition tests for a StateMachine.
///
/// The runner creates a fresh real StateMachine for each state/action pair,
/// dispatches the action, verifies the first emitted state, waits for the
/// expected final state to be emitted, and finally verifies the settled state.
/// Invalid transitions are also checked to ensure that they emit no state.
/// Intermediate stateStream emissions for valid transitions are intentionally
/// ignored so chained side effects can be tested through their immediate and
/// final states.
///
/// It also registers a coverage test that fails when any `states x actions`
/// pair is missing from [cases], or when unexpected cases exist.
///
/// [afterEach] is invoked for every generated transition test even when setup,
/// execution, or earlier cleanup fails.
void runStateMachineTestCases<STATE extends Object, ACTION extends Object,
    MOCKS extends Object>({
  required String name,
  required MOCKS Function() createMocks,
  required StateMachineFactory<STATE, ACTION, MOCKS> createStateMachine,
  required List<STATE> states,
  required List<ACTION> actions,
  required StateMachineTestCases<STATE, ACTION, MOCKS> cases,
  StateMachineTestHook? beforeEach,
  StateMachineTestHook? afterEach,
}) {
  group(name, () {
    test('covers every state/action pair', () {
      _expectAllTransitionsCovered(
        states: states,
        actions: actions,
        cases: cases,
      );
    });

    for (final stateCase in cases) {
      group(_stateLabel(stateCase._initial), () {
        for (final actionCase in stateCase._actions) {
          final description = actionCase._describe(stateCase._initial);
          test(description, () async {
            fsm.StateMachine<STATE, ACTION>? stateMachine;
            Future<STATE>? transitionStateWait;
            Future<void>? noStateEmissionWait;

            try {
              await beforeEach?.call();
              final mocks = createMocks();
              await actionCase._arrange?.call(mocks);
              stateMachine = createStateMachine(mocks, stateCase._initial);
              final context = _failureContext(
                beforeState: stateCase._initial,
                action: actionCase._dispatch,
                description: description,
              );
              if (actionCase._isInvalidTransition) {
                noStateEmissionWait = _expectNoStateEmission(
                  stateMachine.stateStream,
                  context,
                );
              } else {
                transitionStateWait = _waitForFirstAndFinalState(
                  stateMachine.stateStream,
                  actionCase._finallyState(stateCase._initial),
                  context,
                );
              }
              stateMachine.dispatch(actionCase._dispatch);

              if (transitionStateWait != null) {
                final firstState = await transitionStateWait;
                expect(
                  firstState,
                  actionCase._afterState(stateCase._initial),
                  reason: context,
                );
              } else {
                await noStateEmissionWait!;
              }
              expect(
                stateMachine.state,
                actionCase._finallyState(stateCase._initial),
                reason: context,
              );
              await actionCase._verify?.call(mocks);
            } finally {
              try {
                stateMachine?.close();
              } finally {
                await afterEach?.call();
              }
            }
          });
        }
      });
    }
  });
}

/// Starts a transition specification from the given source state.
///
/// Use this as the Given part of a StateMachine test case. The [actions] list
/// should include every action that belongs to the public action set under
/// test, including invalid transitions.
StateCase<STATE, ACTION, MOCKS> whenInitialStateIs<STATE extends Object,
    ACTION extends Object, MOCKS extends Object>(
  STATE initial, {
  required List<ActionCase<STATE, ACTION, MOCKS>> actions,
}) {
  return StateCase._(
    initial: initial,
    actions: actions,
  );
}

/// Describes the expectation for dispatching one action.
///
/// Use this as the When part of a StateMachine test case. [then] describes the
/// state transition expectation, [arrange] arranges external dependencies, and
/// [verify] checks side-effect interactions after the transition has settled.
ActionCase<STATE, ACTION, MOCKS> ifDispatched<STATE extends Object,
    ACTION extends Object, MOCKS extends Object>(
  ACTION action, {
  required TransitionExpectation<STATE> then,
  MockArrange<MOCKS>? arrange,
  MockVerify<MOCKS>? verify,
}) {
  return ActionCase._(
    dispatch: action,
    expectation: then,
    arrange: arrange,
    verify: verify,
  );
}

/// Expects a valid transition to [after], and optionally to [eventually].
///
/// [after] is asserted against the first state emitted by dispatch.
/// [eventually] is asserted after asynchronous side effects have emitted their
/// follow-up state.
TransitionExpectation<STATE> transitionExpectationIs<STATE extends Object>({
  required STATE after,
  STATE? eventually,
}) {
  return TransitionExpectation._transitionTo(
    afterState: after,
    finallyState: eventually,
  );
}

/// Expects the dispatched action to be invalid for the source state.
///
/// Invalid transitions must emit no states and must leave the StateMachine in
/// the original source state.
TransitionExpectation<STATE> expectInvalidTransition<STATE extends Object>() =>
    TransitionExpectation<STATE>._invalid();

void _expectAllTransitionsCovered<STATE extends Object, ACTION extends Object,
    MOCKS extends Object>({
  required List<STATE> states,
  required List<ACTION> actions,
  required StateMachineTestCases<STATE, ACTION, MOCKS> cases,
}) {
  final errors = <String>[];
  final expectedStates = states.toSet();
  final expectedActions = actions.toSet();
  final stateCasesByState = <STATE, StateCase<STATE, ACTION, MOCKS>>{};

  for (final stateCase in cases) {
    stateCasesByState[stateCase._initial] = stateCase;
  }

  for (final state in states) {
    final stateCase = stateCasesByState[state];
    if (stateCase == null) {
      errors.add('missing state case: $state');
      continue;
    }

    final actionCases = <ACTION>{};
    for (final actionCase in stateCase._actions) {
      actionCases.add(actionCase._dispatch);
      if (!expectedActions.contains(actionCase._dispatch)) {
        errors.add('unexpected action case: $state + ${actionCase._dispatch}');
      }
    }

    for (final action in actions) {
      if (!actionCases.contains(action)) {
        errors.add('missing action case: $state + $action');
      }
    }
  }

  for (final stateCase in cases) {
    if (!expectedStates.contains(stateCase._initial)) {
      errors.add('unexpected state case: ${stateCase._initial}');
    }
  }

  if (errors.isEmpty) {
    return;
  }

  fail(
    '''
StateMachine transition test cases are not exhaustive.
${errors.join('\n')}
''',
  );
}

/// Opaque transition specifications for one source state.
///
/// Prefer creating instances through [whenInitialStateIs] so that tests keep a
/// consistent Given-When-Then shape.
final class StateCase<STATE extends Object, ACTION extends Object,
    MOCKS extends Object> {
  const StateCase._({
    required STATE initial,
    required List<ActionCase<STATE, ACTION, MOCKS>> actions,
  })  : _initial = initial,
        _actions = actions;

  final STATE _initial;
  final List<ActionCase<STATE, ACTION, MOCKS>> _actions;
}

/// Opaque transition expectation for one dispatched action.
///
/// Prefer creating instances through [ifDispatched] so that arrangement,
/// transition expectations, and verification remain in the same order in every
/// test case.
final class ActionCase<STATE extends Object, ACTION extends Object,
    MOCKS extends Object> {
  const ActionCase._({
    required ACTION dispatch,
    required TransitionExpectation<STATE> expectation,
    MockArrange<MOCKS>? arrange,
    MockVerify<MOCKS>? verify,
  })  : _dispatch = dispatch,
        _expectation = expectation,
        _arrange = arrange,
        _verify = verify;

  final ACTION _dispatch;
  final TransitionExpectation<STATE> _expectation;
  final MockArrange<MOCKS>? _arrange;
  final MockVerify<MOCKS>? _verify;

  String _describe(STATE beforeState) {
    return switch (_expectation) {
      _InvalidTransitionExpectation<STATE>() =>
        '$_dispatch -> invalid transition',
      _TransitionToExpectation<STATE>() =>
        '$_dispatch -> ${_stateLabel(_afterState(beforeState))}'
            '${_eventuallyDescription(beforeState)}',
    };
  }

  STATE _afterState(STATE beforeState) {
    return _expectation._resolveAfterState(beforeState);
  }

  STATE _finallyState(STATE beforeState) {
    return _expectation._resolveFinallyState(beforeState);
  }

  bool get _isInvalidTransition {
    return _expectation is _InvalidTransitionExpectation<STATE>;
  }

  String _eventuallyDescription(STATE beforeState) {
    final after = _afterState(beforeState);
    final eventually = _finallyState(beforeState);
    if (after == eventually) {
      return '';
    }

    return ' -> ${_stateLabel(eventually)}';
  }
}

/// Opaque expected transition result for a dispatched action.
///
/// Use [transitionExpectationIs] for valid transitions and
/// [expectInvalidTransition] for invalid transitions. The concrete expectation
/// variants are private so tests do not depend on runner internals.
sealed class TransitionExpectation<STATE extends Object> {
  const TransitionExpectation._();

  const factory TransitionExpectation._invalid() =
      _InvalidTransitionExpectation<STATE>;

  const factory TransitionExpectation._transitionTo({
    required STATE afterState,
    STATE? finallyState,
  }) = _TransitionToExpectation<STATE>;

  STATE _resolveAfterState(STATE beforeState) {
    return switch (this) {
      _InvalidTransitionExpectation<STATE>() => beforeState,
      _TransitionToExpectation<STATE>(:final afterState) => afterState,
    };
  }

  STATE _resolveFinallyState(STATE beforeState) {
    return switch (this) {
      _InvalidTransitionExpectation<STATE>() => beforeState,
      _TransitionToExpectation<STATE>(
        :final afterState,
        :final finallyState,
      ) =>
        finallyState ?? afterState,
    };
  }
}

final class _InvalidTransitionExpectation<STATE extends Object>
    extends TransitionExpectation<STATE> {
  const _InvalidTransitionExpectation() : super._();
}

final class _TransitionToExpectation<STATE extends Object>
    extends TransitionExpectation<STATE> {
  const _TransitionToExpectation({
    required this.afterState,
    this.finallyState,
  }) : super._();

  final STATE afterState;
  final STATE? finallyState;
}

const _stateStreamExpectationTimeout = Duration(milliseconds: 100);

Future<STATE> _waitForFirstAndFinalState<STATE extends Object>(
  Stream<STATE> stateStream,
  STATE expectedFinalState,
  String context,
) async {
  final emittedStates = <STATE>[];
  final finalState = Completer<void>();
  late final StreamSubscription<STATE> subscription;
  subscription = stateStream.listen((state) {
    emittedStates.add(state);
    if (state == expectedFinalState && !finalState.isCompleted) {
      finalState.complete();
    }
  });

  try {
    await finalState.future.timeout(
      _stateStreamExpectationTimeout,
      onTimeout: () {
        fail(
          '''
$context
expected final emitted state: $expectedFinalState
actual emitted states: $emittedStates
''',
        );
      },
    );
    return emittedStates.first;
  } finally {
    await subscription.cancel();
  }
}

Future<void> _expectNoStateEmission<STATE extends Object>(
  Stream<STATE> stateStream,
  String context,
) async {
  final emittedStates = <STATE>[];
  late final StreamSubscription<STATE> subscription;
  subscription = stateStream.listen(emittedStates.add);

  try {
    await Future<void>.delayed(Duration.zero);
    expect(emittedStates, isEmpty, reason: context);
  } finally {
    await subscription.cancel();
  }
}

String _failureContext<STATE extends Object, ACTION extends Object>({
  required STATE beforeState,
  required ACTION action,
  required String description,
}) {
  return '''
StateMachine test failed.
case: $description
before: $beforeState
action: $action
''';
}

String _stateLabel(Object state) => state.toString();
