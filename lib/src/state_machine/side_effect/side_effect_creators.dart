// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
part of '../state_machine.dart';

/// Interface of the class that generates SideEffect after the transition
abstract interface class AfterSideEffectCreator<STATE extends Object,
        ACTION extends Object, SIDE_EFFECT extends AfterSideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const AfterSideEffectCreator._(); // coverage:ignore-line
}

/// Interface of the class that generates SideEffect before the transition
abstract interface class BeforeSideEffectCreator<STATE extends Object,
        ACTION extends Object, SIDE_EFFECT extends BeforeSideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const BeforeSideEffectCreator._(); // coverage:ignore-line
}

/// Interface of the class that generates SideEffect that is executed at the
/// end of the process when an Action is dispatched regardless of whether
/// a transition is made
abstract interface class FinallySideEffectCreator<STATE extends Object,
        ACTION extends Object, SIDE_EFFECT extends FinallySideEffect>
    implements SideEffectCreator<STATE, ACTION, SIDE_EFFECT> {
  const FinallySideEffectCreator._(); // coverage:ignore-line
}
