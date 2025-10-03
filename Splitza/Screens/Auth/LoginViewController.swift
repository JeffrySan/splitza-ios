import UIKit
import SnapKit

final class LoginViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel: LoginViewModel
	
	// MARK: - UI Components
	private let scrollView = UIScrollView()
	private let contentView = UIView()
	private let headerView = UIView()
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let formView = UIView()
	private let emailTextField = UITextField()
	private let passwordTextField = UITextField()
	private let loginButton = UIButton(type: .system)
	private let signUpButton = UIButton(type: .system)
	private let formStackView = UIStackView()
	private let errorLabel = UILabel()
	
	// MARK: - Initialization
	init(viewModel: LoginViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		setupViewModelClosure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		viewModel.setProvider(.manual)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide navigation bar for custom header
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	// MARK: - Setup Views
	private func setupViews() {
		configureScrollView()
		configureHeaderView()
		configureTitleLabel()
		configureSubtitleLabel()
		configureFormView()
		configureEmailTextField()
		configurePasswordTextField()
		configureLoginButton()
		configureSignUpButton()
		configureErrorLabel()
		configureFormStackView()
		configureViewHierarchy()
		setupConstraints()
		setupActions()
	}
	
	private func configureScrollView() {
		scrollView.backgroundColor = .systemGroupedBackground
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
	}
	
	private func configureHeaderView() {
		headerView.backgroundColor = .clear
	}
	
	private func configureTitleLabel() {
		titleLabel.text = "Welcome to Splitza"
		titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
		titleLabel.textColor = .label
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
	}
	
	private func configureSubtitleLabel() {
		subtitleLabel.text = "Split bills easily with friends"
		subtitleLabel.font = .systemFont(ofSize: 18, weight: .regular)
		subtitleLabel.textColor = .secondaryLabel
		subtitleLabel.textAlignment = .center
		subtitleLabel.numberOfLines = 0
	}
	
	private func configureFormView() {
		formView.backgroundColor = .systemBackground
		formView.layer.cornerRadius = 12
		formView.layer.shadowColor = UIColor.black.cgColor
		formView.layer.shadowOffset = CGSize(width: 0, height: 1)
		formView.layer.shadowRadius = 3
		formView.layer.shadowOpacity = 0.1
	}
	
	private func configureEmailTextField() {
		emailTextField.placeholder = "Email"
		emailTextField.keyboardType = .emailAddress
		emailTextField.autocapitalizationType = .none
		emailTextField.autocorrectionType = .no
		emailTextField.backgroundColor = .systemGray6
		emailTextField.borderStyle = .none
		emailTextField.layer.cornerRadius = 8
		emailTextField.font = .systemFont(ofSize: 16)
		
		// Add padding
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		emailTextField.leftView = paddingView
		emailTextField.leftViewMode = .always
	}
	
	private func configurePasswordTextField() {
		passwordTextField.placeholder = "Password"
		passwordTextField.isSecureTextEntry = true
		passwordTextField.autocapitalizationType = .none
		passwordTextField.autocorrectionType = .no
		passwordTextField.backgroundColor = .systemGray6
		passwordTextField.borderStyle = .none
		passwordTextField.layer.cornerRadius = 8
		passwordTextField.font = .systemFont(ofSize: 16)
		
		// Add padding
		let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		passwordTextField.leftView = paddingView
		passwordTextField.leftViewMode = .always
	}
	
	private func configureLoginButton() {
		loginButton.setTitle("Log In", for: .normal)
		loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
		loginButton.backgroundColor = .systemBlue
		loginButton.setTitleColor(.white, for: .normal)
		loginButton.layer.cornerRadius = 12
		loginButton.layer.shadowColor = UIColor.black.cgColor
		loginButton.layer.shadowOffset = CGSize(width: 0, height: 1)
		loginButton.layer.shadowRadius = 3
		loginButton.layer.shadowOpacity = 0.1
	}
	
	private func configureSignUpButton() {
		signUpButton.setTitle("Don't have an account? Sign Up", for: .normal)
		signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		signUpButton.setTitleColor(.systemBlue, for: .normal)
		signUpButton.backgroundColor = .clear
	}
	
	private func configureErrorLabel() {
		errorLabel.textColor = .systemRed
		errorLabel.font = .systemFont(ofSize: 14, weight: .medium)
		errorLabel.numberOfLines = 0
		errorLabel.textAlignment = .center
		errorLabel.isHidden = true
	}
	
	private func configureFormStackView() {
		formStackView.axis = .vertical
		formStackView.spacing = 16
		formStackView.alignment = .fill
		formStackView.distribution = .fill
	}
	
	private func configureViewHierarchy() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		// Header components
		headerView.addSubview(titleLabel)
		headerView.addSubview(subtitleLabel)
		
		// Form components
		formView.addSubview(formStackView)
		formStackView.addArrangedSubview(emailTextField)
		formStackView.addArrangedSubview(passwordTextField)
		formStackView.addArrangedSubview(errorLabel)
		formStackView.addArrangedSubview(loginButton)
		formStackView.addArrangedSubview(signUpButton)
		
		// Content view components
		contentView.addSubview(headerView)
		contentView.addSubview(formView)
	}
	
	private func setupConstraints() {
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		// Header constraints
		headerView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(100)
			make.leading.trailing.equalToSuperview().inset(24)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.trailing.equalToSuperview()
		}
		
		subtitleLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		// Form constraints
		formView.snp.makeConstraints { make in
			make.top.equalTo(headerView.snp.bottom).offset(48)
			make.leading.trailing.equalToSuperview().inset(24)
			make.bottom.lessThanOrEqualToSuperview().offset(-40)
		}
		
		formStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(24)
		}
		
		// Text field constraints
		emailTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
		}
		
		passwordTextField.snp.makeConstraints { make in
			make.height.equalTo(50)
		}
		
		// Button constraints
		loginButton.snp.makeConstraints { make in
			make.height.equalTo(50)
		}
		
		signUpButton.snp.makeConstraints { make in
			make.height.equalTo(44)
		}
	}
	
	private func setupActions() {
		loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
		signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
		
		// Add tap gesture to dismiss keyboard
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
	}
	
	// MARK: - View Model Setup
	private func setupViewModelClosure() {
		viewModel.showPopupMessage = { [weak self] title, subtitle in
			DispatchQueue.main.async {
				self?.showError("\(title)\n\(subtitle)")
			}
		}
	}
	
	// MARK: - Actions
	@objc private func loginTapped() {
		hideError()
		
		guard let email = emailTextField.text,
			  !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  let password = passwordTextField.text,
			  !password.isEmpty else {
			showError("Please enter email and password")
			return
		}
		
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
		
		Task {
			await viewModel.signIn(email: email, password: password)
		}
	}
	
	@objc private func signUpTapped() {
		hideError()
		
		guard let email = emailTextField.text,
			  !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  let password = passwordTextField.text,
			  password.count >= 6 else {
			showError("Please enter a valid email and a password with at least 6 characters")
			return
		}
		
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
		
		Task {
			await viewModel.signUp(email: email, password: password)
		}
	}
	
	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	// MARK: - Helpers
	private func showError(_ message: String) {
		errorLabel.text = message
		errorLabel.isHidden = false
	}
	
	private func hideError() {
		errorLabel.text = ""
		errorLabel.isHidden = true
	}
}
