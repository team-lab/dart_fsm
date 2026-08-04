// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_fsm/dart_fsm.dart';
import 'package:dart_fsm/dart_fsm_test_tools.dart';
import 'package:test/test.dart';

void main() {
  runStateMachineTestCases<_ChainState, _ChainAction, Object>(
    name: 'StateMachine test DSL with chained side effects',
    createMocks: Object.new,
    createStateMachine: (_, initialState) => createStateMachine(
      graphBuilder: _chainGraph,
      initialState: initialState,
      sideEffectCreators: [const _ChainSideEffectCreator()],
    ),
    states: const [
      _ChainInitial(),
      _ChainLoading(),
      _ChainSettling(),
      _ChainLoaded(),
    ],
    actions: const [
      _ChainStart(),
      _ChainAdvance(),
      _ChainComplete(),
    ],
    cases: [
      whenInitialStateIs(
        const _ChainInitial(),
        actions: [
          ifDispatched(
            const _ChainStart(),
            then: transitionExpectationIs(
              after: const _ChainLoading(),
              eventually: const _ChainLoaded(),
            ),
          ),
          ifDispatched(
            const _ChainAdvance(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainComplete(),
            then: expectInvalidTransition(),
          ),
        ],
      ),
      whenInitialStateIs(
        const _ChainLoading(),
        actions: [
          ifDispatched(
            const _ChainStart(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainAdvance(),
            then: transitionExpectationIs(
              after: const _ChainSettling(),
              eventually: const _ChainLoaded(),
            ),
          ),
          ifDispatched(
            const _ChainComplete(),
            then: expectInvalidTransition(),
          ),
        ],
      ),
      whenInitialStateIs(
        const _ChainSettling(),
        actions: [
          ifDispatched(
            const _ChainStart(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainAdvance(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainComplete(),
            then: transitionExpectationIs(after: const _ChainLoaded()),
          ),
        ],
      ),
      whenInitialStateIs(
        const _ChainLoaded(),
        actions: [
          ifDispatched(
            const _ChainStart(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainAdvance(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _ChainComplete(),
            then: expectInvalidTransition(),
          ),
        ],
      ),
    ],
  );
}

sealed class _ChainState {
  const _ChainState();
}

final class _ChainInitial extends _ChainState {
  const _ChainInitial();

  @override
  String toString() => 'ChainInitial';
}

final class _ChainLoading extends _ChainState {
  const _ChainLoading();

  @override
  String toString() => 'ChainLoading';
}

final class _ChainSettling extends _ChainState {
  const _ChainSettling();

  @override
  String toString() => 'ChainSettling';
}

final class _ChainLoaded extends _ChainState {
  const _ChainLoaded();

  @override
  String toString() => 'ChainLoaded';
}

sealed class _ChainAction {
  const _ChainAction();
}

final class _ChainStart extends _ChainAction {
  const _ChainStart();

  @override
  String toString() => 'ChainStart';
}

final class _ChainAdvance extends _ChainAction {
  const _ChainAdvance();

  @override
  String toString() => 'ChainAdvance';
}

final class _ChainComplete extends _ChainAction {
  const _ChainComplete();

  @override
  String toString() => 'ChainComplete';
}

final _chainGraph = GraphBuilder<_ChainState, _ChainAction>()
  ..state<_ChainInitial>(
    (builder) => builder
      ..on<_ChainStart>(
        (state, action) => builder.transitionTo(const _ChainLoading()),
      ),
  )
  ..state<_ChainLoading>(
    (builder) => builder
      ..on<_ChainAdvance>(
        (state, action) => builder.transitionTo(const _ChainSettling()),
      ),
  )
  ..state<_ChainSettling>(
    (builder) => builder
      ..on<_ChainComplete>(
        (state, action) => builder.transitionTo(const _ChainLoaded()),
      ),
  )
  ..state<_ChainLoaded>((builder) => builder);

final class _ChainSideEffectCreator
    implements
        AfterSideEffectCreator<_ChainState, _ChainAction, _ChainSideEffect> {
  const _ChainSideEffectCreator();

  @override
  _ChainSideEffect? create(_ChainState prevState, _ChainAction action) {
    return switch (action) {
      _ChainStart() || _ChainAdvance() => const _ChainSideEffect(),
      _ChainComplete() => null,
    };
  }
}

final class _ChainSideEffect
    implements AfterSideEffect<_ChainState, _ChainAction> {
  const _ChainSideEffect();

  @override
  Future<void> execute(
    StateMachine<_ChainState, _ChainAction> stateMachine,
  ) async {
    if (stateMachine.state is _ChainLoading) {
      // Deliberately dispatch before the first await to expose the immediate
      // state observed by the test DSL.
      stateMachine.dispatch(const _ChainAdvance());
      return;
    }

    await Future<void>.delayed(Duration.zero);
    stateMachine.dispatch(const _ChainComplete());
  }
}
