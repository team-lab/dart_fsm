// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/dart_fsm.dart';

import 'test_state_machine_action.dart';
import 'test_state_machine_state.dart';

/*
    ┌─────ActionB──────┐
    │                  │
    │  ┌──ActionA───►StateB
    │  │                  ┌───┐
    ▼  │                  │   │
 StateA┼──ActionC───►StateC  ActionD
    ▲  │                  ▲   │
    │  │                  └───┘
    │  └──ActionD───►StateD
    │                  │
    └─────AnyAction────┘
 */

final testStateGraph = GraphBuilder<TestState, TestAction>()
  ..state<TestStateA>(
    (b) => b
      ..on<TestActionA>(
        (state, action) => b.transitionTo(const TestStateB()),
      )
      ..on<TestActionC>(
        (state, action) => b.transitionTo(const TestStateC()),
      )
      ..on<TestActionD>(
        (state, action) => b.transitionTo(const TestStateD()),
      ),
  )
  ..state<TestStateB>(
    (b) => b
      ..on<TestActionB>(
        (state, action) => b.transitionTo(const TestStateA()),
      ),
  )
  ..state<TestStateC>(
    (b) => b..noTransitionOn<TestActionD>(),
  )
  ..state<TestStateD>(
    (b) => b
      ..onAny(
        (state, action) => b.transitionTo(const TestStateA()),
      ),
  );
