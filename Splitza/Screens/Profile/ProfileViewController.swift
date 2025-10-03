//
//  ProfileViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit
import SnapKit
import RxSwift

final class ProfileViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel: ProfileViewModel
	private let disposeBag = DisposeBag()
	
	// MARK: - UI Components
	private let scrollView = UIScrollView()
	private let contentView = UIView()
	private let headerView = UIView()
	private let avatarView = UIView()
	private let avatarLabel = UILabel()
	private let nameLabel = UILabel()
	private let emailLabel = UILabel()
	private let profileStackView = UIStackView()
	private let userInfoView = UIView()
	private let userIdLabel = UILabel()
	private let createdAtLabel = UILabel()
	private let lastSignInLabel = UILabel()
	private let logoutButton = UIButton(type: .system)
	
	// MARK: - Initialization
	init(
		viewModel: ProfileViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
		setupBindings()
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
		configureAvatarView()
		configureNameLabel()
		configureEmailLabel()
		configureUserInfoView()
		configureUserIdLabel()
		configureCreatedAtLabel()
		configureLastSignInLabel()
		configureLogoutButton()
		configureProfileStackView()
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
		headerView.backgroundColor = .systemBackground
		headerView.layer.cornerRadius = 12
		headerView.layer.shadowColor = UIColor.black.cgColor
		headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
		headerView.layer.shadowRadius = 3
		headerView.layer.shadowOpacity = 0.1
	}
	
	private func configureAvatarView() {
		avatarView.backgroundColor = .systemBlue
		avatarView.layer.cornerRadius = 40
		avatarView.layer.masksToBounds = true
	}
	
	private func configureNameLabel() {
		nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
		nameLabel.textColor = .label
		nameLabel.textAlignment = .center
		nameLabel.numberOfLines = 1
	}
	
	private func configureEmailLabel() {
		emailLabel.font = .systemFont(ofSize: 16, weight: .regular)
		emailLabel.textColor = .secondaryLabel
		emailLabel.textAlignment = .center
		emailLabel.numberOfLines = 1
	}
	
	private func configureUserInfoView() {
		userInfoView.backgroundColor = .systemBackground
		userInfoView.layer.cornerRadius = 12
		userInfoView.layer.shadowColor = UIColor.black.cgColor
		userInfoView.layer.shadowOffset = CGSize(width: 0, height: 1)
		userInfoView.layer.shadowRadius = 3
		userInfoView.layer.shadowOpacity = 0.1
	}
	
	private func configureUserIdLabel() {
		userIdLabel.font = .systemFont(ofSize: 14, weight: .medium)
		userIdLabel.textColor = .label
		userIdLabel.numberOfLines = 0
		userIdLabel.text = "User ID: Loading..."
	}
	
	private func configureCreatedAtLabel() {
		createdAtLabel.font = .systemFont(ofSize: 14, weight: .medium)
		createdAtLabel.textColor = .label
		createdAtLabel.numberOfLines = 0
		createdAtLabel.text = "Member since: Loading..."
	}
	
	private func configureLastSignInLabel() {
		lastSignInLabel.font = .systemFont(ofSize: 14, weight: .medium)
		lastSignInLabel.textColor = .label
		lastSignInLabel.numberOfLines = 0
		lastSignInLabel.text = "Last sign in: Loading..."
	}
	
	private func configureLogoutButton() {
		logoutButton.setTitle("Logout", for: .normal)
		logoutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
		logoutButton.backgroundColor = .systemRed
		logoutButton.setTitleColor(.white, for: .normal)
		logoutButton.layer.cornerRadius = 12
		logoutButton.layer.shadowColor = UIColor.black.cgColor
		logoutButton.layer.shadowOffset = CGSize(width: 0, height: 1)
		logoutButton.layer.shadowRadius = 3
		logoutButton.layer.shadowOpacity = 0.1
		logoutButton.accessibilityIdentifier = "btn-logout"
	}
	
	private func configureProfileStackView() {
		profileStackView.axis = .vertical
		profileStackView.spacing = 16
		profileStackView.alignment = .fill
		profileStackView.distribution = .fill
	}
	
	private func configureViewHierarchy() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubview(profileStackView)
		
		// Header components
		headerView.addSubview(avatarView)
		headerView.addSubview(nameLabel)
		headerView.addSubview(emailLabel)
		avatarView.addSubview(avatarLabel)
		
		// User info components
		userInfoView.addSubview(userIdLabel)
		userInfoView.addSubview(createdAtLabel)
		userInfoView.addSubview(lastSignInLabel)
		
		// Stack view arrangement
		profileStackView.addArrangedSubview(headerView)
		profileStackView.addArrangedSubview(userInfoView)
		profileStackView.addArrangedSubview(logoutButton)
	}
	
	private func setupConstraints() {
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		contentView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		profileStackView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(60)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-20)
		}
		
		// Header constraints
		avatarView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(24)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(80)
		}
		
		nameLabel.snp.makeConstraints { make in
			make.top.equalTo(avatarView.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		emailLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(4)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-24)
		}
		
		// User info constraints
		userIdLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		createdAtLabel.snp.makeConstraints { make in
			make.top.equalTo(userIdLabel.snp.bottom).offset(12)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		lastSignInLabel.snp.makeConstraints { make in
			make.top.equalTo(createdAtLabel.snp.bottom).offset(12)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-16)
		}
		
		// Logout button constraints
		logoutButton.snp.makeConstraints { make in
			make.height.equalTo(50)
		}
	}
	
	private func setupActions() {
		logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
	}
	
	// MARK: - Bindings
	private func setupBindings() {
		// Observe current user changes
		viewModel.currentUserRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] user in
				self?.updateUserInfo(user)
			})
			.disposed(by: disposeBag)
		
		// Observe logout state
		viewModel.isLoggingOutRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isLoggingOut in
				self?.updateLogoutButtonState(isLoggingOut)
			})
			.disposed(by: disposeBag)
		
		// Setup view model closures
		viewModel.showMessage = { [weak self] title, message in
			DispatchQueue.main.async {
				self?.showMessage(title: title, message: message)
			}
		}
	}
	
	// MARK: - Actions
	@objc private func logoutButtonTapped() {
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
		
		// Show confirmation alert
		showLogoutConfirmation()
	}
	
	// MARK: - Private Methods
	private func updateUserInfo(_ user: User?) {
		guard let user = user else {
			nameLabel.text = "Unknown User"
			emailLabel.text = "No email available"
			avatarLabel.text = "?"
			userIdLabel.text = "User ID: Not available"
			createdAtLabel.text = "Member since: Unknown"
			lastSignInLabel.text = "Last sign in: Never"
			return
		}
		
		nameLabel.text = user.email ?? "Unknown User"
		emailLabel.text = user.email ?? "No email available"
		avatarLabel.text = String(user.email?.prefix(1).uppercased() ?? "?")
		avatarLabel.font = .systemFont(ofSize: 32, weight: .bold)
		avatarLabel.textColor = .white
		avatarLabel.textAlignment = .center
		
		userIdLabel.text = "User ID: \(viewModel.userId)"
		createdAtLabel.text = "Member since: \(viewModel.createdAtFormatted)"
		lastSignInLabel.text = "Last sign in: \(viewModel.lastSignInFormatted)"
	}
	
	private func updateLogoutButtonState(_ isLoggingOut: Bool) {
		logoutButton.isEnabled = !isLoggingOut
		logoutButton.setTitle(isLoggingOut ? "Logging out..." : "Logout", for: .normal)
		logoutButton.alpha = isLoggingOut ? 0.6 : 1.0
	}
	
	private func showLogoutConfirmation() {
		let alert = UIAlertController(
			title: "Logout",
			message: "Are you sure you want to logout?",
			preferredStyle: .alert
		)
		
		let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel)
		cancelAlert.accessibilityIdentifier = "alert-cancel"
		
		let logoutAlert = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
			self?.viewModel.logout()
		}
		logoutAlert.accessibilityIdentifier = "alert-logout"
		
		alert.addAction(cancelAlert)
		alert.addAction(logoutAlert)
		
		present(alert, animated: true)
	}
	
	private func showMessage(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

