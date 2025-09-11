---
applyTo: '**'
---

## Coding Style
1. Use consistent indentation (4 spaces using tabs instead of spaces).
2. Use descriptive variable and function names.
3. Keep lines shorter than 80 characters.
4. Use comments to explain complex logic.
5. Prevent using single line statements without braces.
6. Prevent using single line guard statements without braces.
7. Use `guard` statements for early exits.
8. Initiate variables with `let` by default, use `var` only when mutation is necessary.
9. Initiate variables on top of the class or struct.
10 Don't create method longer than 20 lines.

## RxSwift
1. Use `Observable` for asynchronous operations.
2. Use `subscribe(onNext:)` for handling emitted values.
3. Use `flatMap` for transforming emitted values.
4. Use `catchError` to handle errors gracefully.
5. Use `disposeBag` to manage memory and avoid leaks.

## Threading
1. Always create local dispatchQueue variables for threading.
2. Use `DispatchQueue.global(qos: .background)` for background tasks.
