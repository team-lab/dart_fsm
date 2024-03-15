import 'dart:async';
import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';

/// This is a mock implementation of [StateMachine] that can be used for testing
class MockStateMachine<STATE extends StateMachineState,
    ACTION extends StateMachineAction> implements StateMachine<STATE, ACTION> {
  /// Creates a mock state machine.
  MockStateMachine(STATE initialState) : _state = initialState {
    _controller.close();
  }

  /// The actions that have been dispatched to the state machine.
  List<ACTION> get dispatchedActions => _dispatchedActions;

  /// The latest action that was dispatched to the state machine.
  void expectLatestDispatch(ACTION action) {
    expect(_dispatchedActions.last, action);
  }

  final _dispatchedActions = <ACTION>[];

  final STATE _state;

  final _controller = StreamController<STATE>.broadcast();

  @override
  void close() {
    _controller.close();
  }

  @override
  void dispatch(ACTION action) {
    _dispatchedActions.add(action);
  }

  @override
  STATE get state => _state;

  @override
  Stream<STATE> get stateStream => _controller.stream.asBroadcastStream();
}
