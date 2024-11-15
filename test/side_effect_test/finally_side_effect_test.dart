import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';
import '../test_state_machine_action.dart';
import '../test_state_machine_state.dart';

final class SampleFinallySideEffectCreator
    implements
        FinallySideEffectCreator<SampleState, SampleAction,
            SampleFinallySideEffect> {
  const SampleFinallySideEffectCreator(this.testCreate);

  final SampleFinallySideEffect? Function(
    SampleState prevState,
    SampleAction action,
  ) testCreate;

  @override
  SampleFinallySideEffect? create(SampleState prevState, SampleAction action) {
    return testCreate(prevState, action);
  }
}

final class SampleFinallySideEffect
    implements FinallySideEffect<SampleState, SampleAction> {
  const SampleFinallySideEffect(this.testExecute);

  final Future<void> Function(
    StateMachine<SampleState, SampleAction> stateMachine,
    Transition<SampleState, SampleAction> transition,
  ) testExecute;

  @override
  Future<void> execute(
    StateMachine<SampleState, SampleAction> stateMachine,
    Transition<SampleState, SampleAction> transition,
  ) async {
    await testExecute(stateMachine, transition);
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

  group('FinallySideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = SampleFinallySideEffectCreator(
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

    test('create method called when invalid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = SampleFinallySideEffectCreator(
        (prevState, action) {
          expect(prevState, const SampleStateA());
          expect(action, const SampleActionB());
          isSideEffectCreatorCalled = true;
          return null;
        },
      );

      createStateMachine(
        initialState: const SampleStateA(),
        graphBuilder: stateMachineGraph,
        sideEffectCreators: [sideEffectCreator],
      ).dispatch(const SampleActionB());

      expect(isSideEffectCreatorCalled, isTrue);
    });

    // ignore: lines_longer_than_80_chars
    test(
        'execute method called when create method returns side effect and transition was valid',
        () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = SampleFinallySideEffectCreator(
        (prevState, action) {
          return SampleFinallySideEffect(
            (stateMachine, transition) {
              // state transition is done
              expect(stateMachine.state, const SampleStateB());
              expect(
                (transition as Valid<SampleState, SampleAction>).fromState,
                const SampleStateA(),
              );
              expect(transition.toState, const SampleStateB());
              expect(transition.action, const SampleActionA());
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

    // ignore: lines_longer_than_80_chars
    test(
        'execute method called when create method returns side effect and transition was invalid',
        () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = SampleFinallySideEffectCreator(
        (prevState, action) {
          return SampleFinallySideEffect(
            (stateMachine, transition) {
              // state transition is done
              expect(stateMachine.state, const SampleStateA());
              expect(
                (transition as Invalid<SampleState, SampleAction>).fromState,
                const SampleStateA(),
              );
              expect(transition.action, const SampleActionB());
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
      ).dispatch(const SampleActionB());

      expect(isSideEffectExecuteCalled, isTrue);
    });
  });
}
