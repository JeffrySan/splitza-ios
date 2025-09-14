import UIKit
import SnapKit
import Supabase

final class SupabaseManager {
	static let shared = SupabaseManager()
	let client: SupabaseClient

	private init() {
		// Replace these with your Supabase project URL and anon key
		let urlString = "YOUR_SUPABASE_URL"
		let key = "YOUR_SUPABASE_ANON_KEY"
		client = SupabaseClient(supabaseURL: URL(string: urlString)!, supabaseKey: key)
	}
}

final class LoginViewController: UIViewController {
	// UI Components
	private let emailTextField = UITextField()
	private let passwordTextField = UITextField()
	private let loginButton = UIButton(type: .system)
	private let signUpButton = UIButton(type: .system)
	private let stackView = UIStackView()
	private let errorLabel = UILabel()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
		setupConstraints()
		setupActions()
	}

	// MARK: - View Configuration
	private func configureView() {
		view.backgroundColor = .systemBackground

		configureEmailView()
		configurePasswordView()
		configureButtons()
		configureErrorLabel()
		configureStackView()
		configureViewHierarchy()
	}

	private func configureEmailView() {
		emailTextField.placeholder = "Email"
		emailTextField.keyboardType = .emailAddress
		emailTextField.autocapitalizationType = .none
		emailTextField.borderStyle = .roundedRect
	}

	private func configurePasswordView() {
		passwordTextField.placeholder = "Password"
		passwordTextField.isSecureTextEntry = true
		passwordTextField.borderStyle = .roundedRect
	}

	private func configureButtons() {
		loginButton.setTitle("Log In", for: .normal)
		loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		loginButton.backgroundColor = .systemBlue
		loginButton.setTitleColor(.white, for: .normal)
		loginButton.layer.cornerRadius = 8

		signUpButton.setTitle("Sign Up", for: .normal)
		signUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
	}

	private func configureErrorLabel() {
		errorLabel.textColor = .systemRed
		errorLabel.font = .systemFont(ofSize: 13)
		errorLabel.numberOfLines = 0
		errorLabel.textAlignment = .center
	}

	private func configureStackView() {
		stackView.axis = .vertical
		stackView.spacing = 12
		stackView.alignment = .fill
		stackView.distribution = .fill
	}

	private func configureViewHierarchy() {
		view.addSubview(stackView)
		stackView.addArrangedSubview(emailTextField)
		stackView.addArrangedSubview(passwordTextField)
		stackView.addArrangedSubview(loginButton)
		stackView.addArrangedSubview(signUpButton)
		stackView.addArrangedSubview(errorLabel)
	}
	
	private func setupConstraints() {
		stackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(24)
		}

		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(44)
		}

		passwordTextField.snp.makeConstraints { make in
			make.height.equalTo(44)
		}

		loginButton.snp.makeConstraints { make in
			make.height.equalTo(48)
		}
	}

	private func setupActions() {
		loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
		signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
	}

	// MARK: - Actions
	@objc private func loginTapped() {
		errorLabel.text = ""
		
		guard let email = emailTextField.text,
			  !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  let password = passwordTextField.text,
			  !password.isEmpty else {
			showError("Please enter email and password")
			return
		}

		let backgroundQueue = DispatchQueue.global(qos: .background)
		backgroundQueue.async { [weak self] in
			guard let self = self else { return }
			Task {
				do {
					let _ = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
					DispatchQueue.main.async {
						// Handle successful login (dismiss or notify coordinator)
						self.dismiss(animated: true)
					}
				} catch {
					DispatchQueue.main.async {
						self.showError(error.localizedDescription)
					}
				}
			}
		}
	}

	@objc private func signUpTapped() {
		errorLabel.text = ""

		guard let email = emailTextField.text,
				!email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  let password = passwordTextField.text,
			  password.count >= 6 else {
			showError("Please enter a valid email and a password with at least 6 characters")
			return
		}

		let backgroundQueue = DispatchQueue.global(qos: .background)
		backgroundQueue.async { [weak self] in
			
			guard let self = self else {
				return
			}
			
			Task {
				do {
					let _ = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
					DispatchQueue.main.async {
						// After signup, you may want to verify email or auto-login
						self.showError("Signup successful. Please check your email to confirm.")
					}
				} catch {
					DispatchQueue.main.async {
						self.showError(error.localizedDescription)
					}
				}
			}
		}
	}

	// MARK: - Helpers
	private func showError(_ message: String) {
		errorLabel.text = message
	}
}
