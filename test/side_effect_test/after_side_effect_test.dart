import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';
import '../test_state_machine_action.dart';
import '../test_state_machine_state.dart';

final class SampleAfterSideEffectCreator
    implements
        AfterSideEffectCreator<SampleState, SampleAction,
            SampleAfterSideEffect> {
  const SampleAfterSideEffectCreator(this.testCreate);

  final SampleAfterSideEffect? Function(
    SampleState prevState,
    SampleAction action,
  ) testCreate;

  @override
  SampleAfterSideEffect? create(SampleState prevState, SampleAction action) {
    return testCreate(prevState, action);
  }
}

final class SampleAfterSideEffect
    implements AfterSideEffect<SampleState, SampleAction> {
  const SampleAfterSideEffect(this.testExecute);

  final Future<void> Function(
    StateMachine<SampleState, SampleAction> stateMachine,
  ) testExecute;

  @override
  Future<void> execute(
    StateMachine<SampleState, SampleAction> stateMachine,
  ) async {
    await testExecute(stateMachine);
  }
}

void main() {
  final stateMachineGraph = GraphBuilder<SampleState, SampleAction>()
    ..state<SampleStateA>(
      (b) => b
        ..on<SampleActionA>(
          (state, action) => b.transitionTo(const SampleStateB()),
        )
        ..on<SampleActionC>(
          (state, action) => b.transitionTo(const SampleStateC()),
        ),
    )
    ..state<SampleStateB>(
      (b) => b
        ..on<SampleActionB>(
          (state, action) => b.transitionTo(const SampleStateA()),
        ),
    )
    ..state<SampleStateC>(
      (b) => b..noTransitionOn<SampleActionD>(),
    );

  group('AfterSideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = SampleAfterSideEffectCreator(
        (prevState, action) {
          expect(prevState, const SampleStateA());
          expect(action, const SampleActionA());
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: stateMachineGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const SampleActionA());

      expect(isSideEffectCreatorCalled, isTrue);
    });

    test('not create method called when invalid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = SampleAfterSideEffectCreator(
        (prevState, action) {
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: stateMachineGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const SampleActionB());

      expect(isSideEffectCreatorCalled, isFalse);
    });

    test('execute method called when create method returns side effect', () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = SampleAfterSideEffectCreator(
        (prevState, action) {
          return SampleAfterSideEffect(
            (stateMachine) {
              // state transition is done
              expect(stateMachine.state, const SampleStateB());
              isSideEffectExecuteCalled = true;
              return Future.value();
            },
          );
        },
      );

      createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: stateMachineGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const SampleActionA());

      expect(isSideEffectExecuteCalled, isTrue);
    });
  });
}
