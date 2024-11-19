// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_fsm/dart_fsm.dart';

/// The abstract class of side effects generated by the transition of
/// [StateMachine]
/// [SideEffect] can be one of:
/// [AfterSideEffect] - executed after the transition,
/// [BeforeSideEffect] - executed before the transition,
/// [FinallySideEffect] - executed regardless of whether a transition is made
/// after an Action is dispatched.
abstract interface class SideEffect {
  const SideEffect(); // coverage:ignore-line
}
