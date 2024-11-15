// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:collection/collection.dart';
import 'package:dart_fsm/dart_fsm.dart';
import 'package:dart_fsm/src/tester/tester_state_machine.dart';
import 'package:test/test.dart';

/// This class is used to test the state machine.
class StateMachineTester<STATE extends Object, ACTION extends Object> {
  /// Creates a state machine tester.
  StateMachineTester({
    required GraphBuilder<STATE, ACTION> graphBuilder,
    List<SideEffectCreator<STATE, ACTION, SideEffect>> sideEffectCreators =
        const [],
  })  : _sideEffectCreators = sideEffectCreators,
        _graphBuilder = graphBuilder;

  final List<SideEffectCreator<STATE, ACTION, SideEffect>> _sideEffectCreators;
  final GraphBuilder<STATE, ACTION> _graphBuilder;

  final Map<STATE, List<SMAssertObject<STATE, ACTION>>> _testCases = {};

  /// Sets the test case.
  void setTestCase({
    required STATE beforeState,
    required List<SMAssertObject<STATE, ACTION>> testCases,
  }) {
    _testCases[beforeState] = testCases;
  }

  TesterStateMachine<STATE, ACTION> _createStateMachine(
    STATE beforeState,
  ) {
    return TesterStateMachine(
      graphBuilder: _graphBuilder,
      initialState: beforeState,
      sideEffectCreators: _sideEffectCreators,
    );
  }

  /// Runs the test.
  void runTest() {
    for (final entry in _testCases.entries) {
      for (final obj in entry.value) {
        final stateMachine = _createStateMachine(entry.key)
          ..dispatch(obj.action);
        test(
          'When ${entry.key.runtimeType} dispatch ${obj.action.runtimeType}',
          () {
            if (stateMachine.isPrevTransitionValid) {
              if (stateMachine.state != obj.afterState) {
                fail(
                  // ignore: lines_longer_than_80_chars
                  'The state after the transition is different from the expected value'
                  '\n${obj.createFailMessage(stateMachine)}',
                );
              }
              for (final e in stateMachine.createdSideEffect) {
                final matchedSideEffect =
                    obj.createdSideEffect.firstWhereOrNull(
                  (element) => element.runtimeType == e.runtimeType,
                );
                if (matchedSideEffect == null) {
                  fail(
                    // ignore: lines_longer_than_80_chars
                    'A different side effect was generated from the expected value'
                    '\n${obj.createFailMessage(stateMachine)}',
                  );
                }
              }
            }
          },
        );
        stateMachine.close();
      }
    }
  }
}

/// This class is used to store the test case information.
final class SMAssertObject<S extends Object, A extends Object> {
  /// Creates a test case object.
  const SMAssertObject({
    required this.action,
    this.afterState,
    this.createdSideEffect = const [],
  });

  /// The action to be dispatched.
  final A action;

  /// The expected state after the action is dispatched.
  final S? afterState;

  /// The expected side effect after the action is dispatched.
  final List<SideEffect> createdSideEffect;

  /// Create a fail message.
  String createFailMessage(TesterStateMachine stateMachine) {
    final message = StringBuffer()
      ..writeln('Expected State: ${afterState.runtimeType}')
      ..writeln('Actual State: ${stateMachine.state.runtimeType}')
      ..write('Expected SideEffect: ')
      ..writeln(createdSideEffect.map((e) => e.runtimeType).toList())
      ..write('Actual SideEffect: ')
      ..writeln(
        stateMachine.createdSideEffect.map((e) => e.runtimeType).toList(),
      );
    return message.toString();
  }
}
