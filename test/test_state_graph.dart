import 'package:dart_fsm/dart_fsm.dart';

import 'test_state_machine_action.dart';
import 'test_state_machine_state.dart';

final testStateGraph = GraphBuilder<SampleState, SampleAction>()
  ..state<SampleStateA>(
    (b) => b
      ..on<SampleActionA>(
        (state, action) => b.transitionTo(const SampleStateB()),
      )
      ..on<SampleActionC>(
        (state, action) => b.transitionTo(const SampleStateC()),
      )
      ..on<SampleActionD>(
        (state, action) => b.transitionTo(const SampleStateD()),
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
  )
  ..state<SampleStateD>(
    (b) => b
      ..onAny(
        (state, action) => b.transitionTo(const SampleStateA()),
      ),
  );
