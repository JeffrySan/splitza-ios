---
applyTo: '**'
---

## Initialization Style
1. All initializers with multiple parameters must be written in multi-line format:
    ```swift
    init(
        parameterOne: Type,
        parameterTwo: Type,
        parameterThree: Type
    ) {
        // Implementation
    }
    ```
2. Rules for multi-line initializers:
    - Add line break after opening parenthesis
    - Each parameter on its own line
    - Align parameters with 4 tabs from the left margin
    - Add line break before closing parenthesis
    - Closing parenthesis aligns with `init` keyword

## ‼️ CRITICAL REQUIREMENTS
1. INDENTATION MUST:
	- ALWAYS use tabs (↹), NEVER spaces
	- Use EXACTLY ONE tab per level
	- NO EXCEPTIONS to this rule
2. BEFORE ANY EDIT:
	- Verify indentation is using tabs
	- Check tab width display is 4 characters
	- Ensure no spaces are used for indentation
	- Run pre-edit checklist

## Editor Configuration
1. Configure your editor to:
	- Insert tabs for indentation (NOT spaces)
	- Display tab width as 4 characters
	- Never convert tabs to spaces
	- Ensure "Insert Spaces" is OFF

## Pre-Edit Checklist
Before making ANY code changes:
□ Indentation uses tabs, not spaces
□ One tab per indentation level
□ No mixed tabs and spaces
□ Editor is configured for tabs

## Indentation
1. Always use tabs for indentation, never spaces
2. Use exactly 1 tab for each level of indentation
3. Visual Guide for Tab Levels:
    ```
    Level 1 (1 tab):      ↹code
    Level 2 (2 tabs):     ↹↹code
    Level 3 (3 tabs):     ↹↹↹code
    Level 4 (4 tabs):     ↹↹↹↹code
    ```

4. Example of proper tab indentation:
    ```swift
    // ❌ Wrong (using spaces)
    class MyViewController: UIViewController {
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Hello"
            return label
        }()
    }

    // ✅ Correct (using tabs)
    class MyViewController: UIViewController {
	private let label: UILabel = {
		let label = UILabel()
		label.text = "Hello"
		return label
	}()
    }
    ```

5. Common Indentation Cases:
    ```swift
    class MyViewController: UIViewController {
	// Level 1: Properties
	private let label: UILabel = {
		// Level 2: Property initializer
		let label = UILabel()
		label.text = "Hello"
		return label
	}()
	
	// Level 1: Methods
	func configure() {
		// Level 2: Method body
		if condition {
			// Level 3: Control flow block
			doSomething()
		}
		
		guard 
			let value = optionalValue,
			value > 0 
		else {
			return
		}
	}
    }
    ```

## Coding Style
1. Use descriptive variable and function names that clearly convey purpose
2. Keep lines shorter than 80 characters
3. Use comments to explain complex logic
4. Never use single-line statements without braces
5. Write guard statements in multi-line format:
    ```swift
    guard let value = optionalValue,
	    value > 0 
    else {
	    return
    }

    // For multiple conditions, first condition stays with guard:
    guard let user = currentUser,
	    user.isAuthenticated,
	    let account = user.account 
    else {
	    return
    }
    ```
6. Use `guard` statements for early exits
7. Use `let` by default, use `var` only when mutation is necessary
8. Declare properties at the top of the class or struct
9. Keep methods under 20 lines for better readability

## RxSwift
1. Use `Observable` for asynchronous operations.
2. Use `subscribe(onNext:)` for handling emitted values.
3. Use `flatMap` for transforming emitted values.
4. Use `catchError` to handle errors gracefully.
5. Use `disposeBag` to manage memory and avoid leaks.

## Threading
1. Always create local dispatchQueue variables for threading.
2. Use `DispatchQueue.global(qos: .background)` for background tasks.

## UI Creation
1. Use programmatic UI creation instead of Storyboards or XIBs
2. UI components must be declared as single-line properties at the top of the class, not using `lazy var`.
3. Use a `configureView()` method to set up appearance, hierarchy, and configuration of all UI components.
4. Use a `setupConstraints()` method to set up all SnapKit constraints for UI components.
5. Use `setupActions()` for adding targets, gestures, and Rx bindings.
6. Example structure:
    ```swift
    class CustomView: UIView {
        // UI Components
        private let titleLabel = UILabel()
        private let button = UIButton()

        override init(frame: CGRect) {
            super.init(frame: frame)
            // Defer setup to didMoveToSuperview for consistency
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            // Defer setup to didMoveToSuperview for consistency
        }

        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            setupViews()
        }

        private func setupViews() {
            configureTitleLabel()
            configureButton()
            configureViewHierarchy()
            setupConstraints()
            setupActions()
        }

        private func configureTitleLabel() {
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        }

        private func configureButton() {
            button.setTitle("Tap", for: .normal)
        }

        private func configureViewHierarchy() {
            addSubview(titleLabel)
            addSubview(button)
        }

        private func setupConstraints() {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
            }
            button.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.centerX.equalToSuperview()
            }
        }

        private func setupActions() {
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }
    ```
7. UI Component Rules:
    - Declare all UI components as single-line properties at the top of the class
    - Don't use `lazy var` for UI components
    - Use `private` access level for UI components
    - Use dedicated configure methods for each UI component (e.g., configureTitleLabel, configureButton)
    - Use a dedicated configureViewHierarchy method for adding subviews
    - Use a dedicated setupConstraints method for all constraints
    - Use a dedicated setupActions method for targets, gestures, and bindings
    - Call setupViews in didMoveToSuperview
    - Use `UIStackView` for linear layouts when possible
    - Always use SnapKit for constraints
