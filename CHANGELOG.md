## 1.3.0
- feat: Add `runStateMachineTestCases`, a declarative Given-When-Then test DSL with exhaustive state/action coverage
- feat: Deprecate `StateMachineTester`, `SMAssertObject`, and `TesterStateMachine` in favor of the new test DSL; the legacy APIs remain available for migration
- fix: Support asynchronous arrange, verification, and lifecycle hooks, and ensure teardown runs after every generated test

## 1.2.4
- docs: Correct side effect description (thanks @ParkJong-Hun !)

## 1.2.3
- docs: Fix `createStateMachine` argument names (thanks @djoeressen !)

## 1.2.2
- fix: Prevent dispatching actions after state machine is closed

## 1.2.1
- chore: Relax version constraint for test package to ensure forward compatibility

## 1.2.0
- chore: Control class visibility from outside the package

## 1.1.1
- chore: downgrade meta package version to 1.15.0

## 1.1.0
- fix: Fixed that AfterSideEffectCreator and FinallySideEffectCreator was treating the state after transition as prevState.
- fix: Block duplicate call state and on method logic

## 1.0.0
- Initial release.
### Changes from 0.0.1
- Updated the version to 1.0.0.
- Removed `validTransition` from the arguments of the `execute` method of `AfterSideEffect`.
  - This is because `validTransition` is no longer needed as it is received via the constructor from `SideEffectCreator`.
- Improved documentation and other maintenance tasks.


## 0.0.1

- Initial version.
