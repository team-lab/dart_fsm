// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:dart_fsm/src/state_machine/side_effect/side_effect_interface.dart';

/// Interface of the class that generates SideEffect
// ignore: one_member_abstracts
abstract interface class SideEffectCreator<STATE extends Object,
    ACTION extends Object, SIDE_EFFECT extends SideEffect> {
  const SideEffectCreator._(); // coverage:ignore-line

  /// Create a [SIDE_EFFECT] from the [STATE] and [ACTION] before the transition
  /// [prevState] The state before the transition
  /// [action] The action that was executed
  /// [SIDE_EFFECT] The generated side effect
  SIDE_EFFECT? create(STATE prevState, ACTION action);
}
