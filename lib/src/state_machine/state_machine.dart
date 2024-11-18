// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:dart_fsm/src/state_machine/graph/graph.dart';
import 'package:dart_fsm/src/state_machine/implementation/state_machine_impl.dart';
import 'package:dart_fsm/src/state_machine/side_effect/side_effect_creator_interface.dart';
import 'package:dart_fsm/src/state_machine/side_effect/side_effect_interface.dart';
import 'package:meta/meta.dart';

part './side_effect/side_effect_creators.dart';
part './side_effect/side_effects.dart';
part './subscription/subscription.dart';
part './graph/graph_builder.dart';
part './graph/transition.dart';
part 'state_machine_creator.dart';

/// A state machine.
abstract interface class StateMachine<STATE extends Object,
    ACTION extends Object> {
  const StateMachine(); // coverage:ignore-line

  /// The current state of the state machine.
  STATE get state;

  /// A stream of the state machine's state.
  Stream<STATE> get stateStream;

  /// Dispatches an action to the state machine.
  void dispatch(ACTION action);

  /// Closes the state machine and releases resources.
  void close();
}
