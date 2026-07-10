// Copyright (c) 2024, teamLab inc.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_fsm/dart_fsm.dart';
import 'package:dart_fsm/dart_fsm_test_tools.dart';
import 'package:test/test.dart';

void main() {
  var isCaseActive = false;
  var hasCompletedAsyncVerify = true;

  runStateMachineTestCases<_State, _Action, _Dependencies>(
    name: 'StateMachine test DSL',
    createMocks: _Dependencies.new,
    createStateMachine: (dependencies, initialState) {
      expect(isCaseActive, isTrue);
      return createStateMachine(
        graphBuilder: _graph,
        initialState: initialState,
        sideEffectCreators: [_LoadSideEffectCreator(dependencies)],
      );
    },
    states: const [
      _Initial(),
      _Loading(),
      _Loaded(),
    ],
    actions: const [
      _Load(),
      _Complete(),
    ],
    cases: [
      whenInitialStateIs(
        const _Initial(),
        actions: [
          ifDispatched(
            const _Load(),
            then: transitionExpectationIs(
              after: const _Loading(),
              eventually: const _Loaded(),
            ),
            arrange: (dependencies) async {
              await Future<void>.delayed(Duration.zero);
              dependencies.loadedValue = 'loaded';
              hasCompletedAsyncVerify = false;
            },
            verify: (dependencies) async {
              await Future<void>.delayed(Duration.zero);
              expect(dependencies.loadedValue, 'loaded');
              expect(dependencies.loadCallCount, 1);
              hasCompletedAsyncVerify = true;
            },
          ),
          ifDispatched(
            const _Complete(),
            then: expectInvalidTransition(),
          ),
        ],
      ),
      whenInitialStateIs(
        const _Loading(),
        actions: [
          ifDispatched(
            const _Load(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _Complete(),
            then: transitionExpectationIs(after: const _Loaded()),
          ),
        ],
      ),
      whenInitialStateIs(
        const _Loaded(),
        actions: [
          ifDispatched(
            const _Load(),
            then: expectInvalidTransition(),
          ),
          ifDispatched(
            const _Complete(),
            then: expectInvalidTransition(),
          ),
        ],
      ),
    ],
    beforeEach: () {
      expect(isCaseActive, isFalse);
      expect(hasCompletedAsyncVerify, isTrue);
      isCaseActive = true;
    },
    afterEach: () {
      expect(isCaseActive, isTrue);
      expect(hasCompletedAsyncVerify, isTrue);
      isCaseActive = false;
    },
  );
}

sealed class _State {
  const _State();
}

final class _Initial extends _State {
  const _Initial();

  @override
  String toString() => 'Initial';
}

final class _Loading extends _State {
  const _Loading();

  @override
  String toString() => 'Loading';
}

final class _Loaded extends _State {
  const _Loaded();

  @override
  String toString() => 'Loaded';
}

sealed class _Action {
  const _Action();
}

final class _Load extends _Action {
  const _Load();

  @override
  String toString() => 'Load';
}

final class _Complete extends _Action {
  const _Complete();

  @override
  String toString() => 'Complete';
}

final _graph = GraphBuilder<_State, _Action>()
  ..state<_Initial>(
    (builder) => builder
      ..on<_Load>(
        (state, action) => builder.transitionTo(const _Loading()),
      ),
  )
  ..state<_Loading>(
    (builder) => builder
      ..on<_Complete>(
        (state, action) => builder.transitionTo(const _Loaded()),
      ),
  );

final class _Dependencies {
  String? loadedValue;
  int loadCallCount = 0;

  Future<void> load() async {
    if (loadedValue == null) {
      throw StateError('load called before arrange completed');
    }
    loadCallCount++;
    await Future<void>.delayed(Duration.zero);
  }
}

final class _LoadSideEffectCreator
    implements AfterSideEffectCreator<_State, _Action, _LoadSideEffect> {
  const _LoadSideEffectCreator(this.dependencies);

  final _Dependencies dependencies;

  @override
  _LoadSideEffect? create(_State prevState, _Action action) {
    return switch (action) {
      _Load() => _LoadSideEffect(dependencies),
      _Complete() => null,
    };
  }
}

final class _LoadSideEffect implements AfterSideEffect<_State, _Action> {
  const _LoadSideEffect(this.dependencies);

  final _Dependencies dependencies;

  @override
  Future<void> execute(StateMachine<_State, _Action> stateMachine) async {
    await dependencies.load();
    stateMachine.dispatch(const _Complete());
  }
}
