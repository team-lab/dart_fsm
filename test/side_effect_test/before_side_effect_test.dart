import 'package:dart_fsm/dart_fsm.dart';
import 'package:test/test.dart';
import '../test_state_machine_action.dart';
import '../test_state_machine_state.dart';

final class SampleBeforeSideEffectCreator
    implements
        BeforeSideEffectCreator<SampleState, SampleAction,
            SampleBeforeSideEffect> {
  const SampleBeforeSideEffectCreator(this.testCreate);

  final SampleBeforeSideEffect? Function(
    SampleState prevState,
    SampleAction action,
  ) testCreate;

  @override
  SampleBeforeSideEffect? create(SampleState prevState, SampleAction action) {
    return testCreate(prevState, action);
  }
}

final class SampleBeforeSideEffect
    implements BeforeSideEffect<SampleState, SampleAction> {
  const SampleBeforeSideEffect(this.testExecute);

  final Future<void> Function(SampleState currentState, SampleAction action)
      testExecute;

  @override
  Future<void> execute(SampleState currentState, SampleAction action) async {
    await testExecute(currentState, action);
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

  group('BeforeSideEffectCreator test', () {
    test('create method called when valid transition', () {
      var isSideEffectCreatorCalled = false;

      final sideEffectCreator = SampleBeforeSideEffectCreator(
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

      final sideEffectCreator = SampleBeforeSideEffectCreator(
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

    test('execute method called when create method returns side effect', () {
      var isSideEffectExecuteCalled = false;

      final sideEffectCreator = SampleBeforeSideEffectCreator(
        (prevState, action) {
          return SampleBeforeSideEffect(
            (currentState, action) async {
              expect(currentState, const SampleStateA());
              expect(action, const SampleActionA());
              isSideEffectExecuteCalled = true;
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
