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
