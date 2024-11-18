// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_fsm/dart_fsm.dart';

import 'test_side_effects.dart';
import 'test_state_machine_action.dart';
import 'test_state_machine_state.dart';

final class TestBeforeSideEffectCreator
    implements
        BeforeSideEffectCreator<TestState, TestAction, TestBeforeSideEffect> {
  const TestBeforeSideEffectCreator(this.testCreate);

  final TestBeforeSideEffect? Function(
    TestState prevState,
    TestAction action,
  ) testCreate;

  @override
  TestBeforeSideEffect? create(TestState prevState, TestAction action) {
    return testCreate(prevState, action);
  }
}

final class TestAfterSideEffectCreator
    implements
        AfterSideEffectCreator<TestState, TestAction, TestAfterSideEffect> {
  const TestAfterSideEffectCreator(this.testCreate);

  final TestAfterSideEffect? Function(
    TestState prevState,
    TestAction action,
  ) testCreate;

  @override
  TestAfterSideEffect? create(TestState prevState, TestAction action) {
    return testCreate(prevState, action);
  }
}

final class TestFinallySideEffectCreator
    implements
        FinallySideEffectCreator<TestState, TestAction, TestFinallySideEffect> {
  const TestFinallySideEffectCreator(this.testCreate);

  final TestFinallySideEffect? Function(
    TestState prevState,
    TestAction action,
  ) testCreate;

  @override
  TestFinallySideEffect? create(TestState prevState, TestAction action) {
    return testCreate(prevState, action);
  }
}
