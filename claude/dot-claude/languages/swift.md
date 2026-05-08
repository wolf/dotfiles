# Swift / SwiftUI / SwiftData conventions

Conventions for Swift projects. Add entries as patterns solidify across projects.

## General

* Use `guard` over nested `if` for early exits.
* Prefer `let` everywhere; `var` only when mutation is actually needed.
* Mark types and members `private` or `fileprivate` by default; open access only at boundaries.
* Avoid `!` force-unwraps except in tests. Use `guard let` or `??` with a sensible default.

## SwiftUI

* Keep `View` bodies slim — extract sub-views and view models rather than stacking logic inside `body`.
* Use `@Observable` (Swift 5.9+) for view models in preference to `@ObservableObject` / `@Published`.
* Preview with `#Preview` macro; seed with in-memory SwiftData container.

## SwiftData

* `@Model` classes are the schema. Keep them focused — no view logic, no computed properties that hit the database.
* Use `@Relationship(deleteRule:)` explicitly to document cascade behavior; don't rely on defaults.
* For derived/computed values (e.g., $/round, lifetime round count), compute at read time in the model or a view model, not via extra stored properties, unless the computation is expensive enough to cache.
* Schema migrations: add new attributes with defaults, never remove or rename without a `SchemaMigrationPlan`. CloudKit sync means schema changes are hard to roll back.

## Testing

* Unit tests for domain logic (derivations, rollups, business rules) — these don't need UI or SwiftData.
* Integration tests for persistence (use `ModelConfiguration(isStoredInMemoryOnly: true)`).
* UI tests sparingly; prefer unit tests for logic.

## Project structure (ios-shooters-log specific)

```
Sources/
  Models/       — SwiftData @Model types
  Views/        — SwiftUI views, organized by feature
  ViewModels/   — @Observable view model classes
  Services/     — CloudKit, export, audio parsing
watchOS/        — Watch-only views and complications
```
