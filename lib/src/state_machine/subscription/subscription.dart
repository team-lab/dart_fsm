// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../state_machine.dart';

/// [Subscription] is a component which can be registered to [StateMachine] to
/// monitor changes of the state.
/// This is mainly used to monitor a change in state and to instruct
/// [StateMachine] to perform some processing based on that change.
/// For example, it is conceivable to monitor the connection status of WebSocket
/// and instruct [StateMachine] to attempt to reconnect if the connection
/// is lost.
// ignore: one_member_abstracts
abstract interface class Subscription<STATE extends Object,
    ACTION extends Object> {
  const Subscription(); // coverage:ignore-line

  /// The method executed after the instance of [Subscription] is registered
  /// with [StateMachine].
  /// The current [StateMachine] is passed as an argument.
  /// This method is used to instruct [StateMachine] to perform some processing
  /// based on the change in state.
  void subscribe(
    StateMachine<STATE, ACTION> stateMachine,
  );

  /// The method executed after the instance of [Subscription] is unregistered
  void dispose();
}
