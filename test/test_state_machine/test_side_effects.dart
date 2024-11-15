// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/dart_fsm.dart';

import 'test_state_machine_action.dart';
import 'test_state_machine_state.dart';

final class TestBeforeSideEffect
    implements BeforeSideEffect<TestState, TestAction> {
  const TestBeforeSideEffect(this.testExecute);

  final Future<void> Function(TestState currentState, TestAction action)
      testExecute;

  @override
  Future<void> execute(TestState currentState, TestAction action) async {
    await testExecute(currentState, action);
  }
}

final class TestAfterSideEffect
    implements AfterSideEffect<TestState, TestAction> {
  const TestAfterSideEffect(this.testExecute);

  final Future<void> Function(
    StateMachine<TestState, TestAction> stateMachine,
  ) testExecute;

  @override
  Future<void> execute(
    StateMachine<TestState, TestAction> stateMachine,
  ) async {
    await testExecute(stateMachine);
  }
}

final class TestFinallySideEffect
    implements FinallySideEffect<TestState, TestAction> {
  const TestFinallySideEffect(this.testExecute);

  final Future<void> Function(
    StateMachine<TestState, TestAction> stateMachine,
    Transition<TestState, TestAction> transition,
  ) testExecute;

  @override
  Future<void> execute(
    StateMachine<TestState, TestAction> stateMachine,
    Transition<TestState, TestAction> transition,
  ) async {
    await testExecute(stateMachine, transition);
  }
}
