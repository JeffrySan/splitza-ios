//
//  AddBillViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import RxSwift
import RxRelay

final class AddBillViewController: UIViewController {
	
	// MARK: - Properties
	
	private let viewModel: AddBillViewModel
	private let disposeBag = DisposeBag()
	
	// MARK: - UI Components
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private lazy var contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var dragIndicator: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiaryLabel
		view.layer.cornerRadius = 2.5
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Add New Bill"
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Cancel", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Save", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		button.backgroundColor = .systemBlue
		button.setTitleColor(.white, for: .normal)
		button.setTitleColor(.systemBackground, for: .disabled)
		button.layer.cornerRadius = 10
		button.isEnabled = false
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// Form Fields
	private lazy var billTitleTextField: UITextField = {
		let textField = createTextField(placeholder: "Bill title", returnKeyType: .next)
		return textField
	}()
	
	private lazy var amountTextField: UITextField = {
		let textField = createTextField(placeholder: "0.00", returnKeyType: .next)
		textField.keyboardType = .decimalPad
		return textField
	}()
	
	private lazy var locationTextField: UITextField = {
		let textField = createTextField(placeholder: "Location (optional)", returnKeyType: .next)
		return textField
	}()
	
	private lazy var descriptionTextField: UITextField = {
		let textField = createTextField(placeholder: "Description (optional)", returnKeyType: .done)
		return textField
	}()
	
	private lazy var currencySegmentedControl: UISegmentedControl = {
		let control = UISegmentedControl(items: ["USD", "IDR", "EUR", "GBP"])
		control.selectedSegmentIndex = 0
		control.backgroundColor = .systemGroupedBackground
		control.selectedSegmentTintColor = .systemBlue
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()
	
	private lazy var participantsTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.isScrollEnabled = false
		tableView.register(ParticipantInputCell.self, forCellReuseIdentifier: ParticipantInputCell.identifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var addParticipantButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("+ Add Participant", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.backgroundColor = .tertiarySystemGroupedBackground
		button.setTitleColor(.systemBlue, for: .normal)
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.separator.cgColor
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var summaryView: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var summaryLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.text = "Total: $0.00 • 0 participants • $0.00 each"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private var tableViewHeightConstraint: NSLayoutConstraint!
	
	// MARK: - Initialization
	
	init(viewModel: AddBillViewModel = AddBillViewModel()) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		self.viewModel = AddBillViewModel()
		super.init(coder: coder)
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupBindings()
		setupKeyboardHandling()
		
		// Add initial participant
		viewModel.addParticipant()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemGroupedBackground
		
		// Add subviews
		view.addSubview(headerView)
		headerView.addSubview(dragIndicator)
		headerView.addSubview(titleLabel)
		headerView.addSubview(cancelButton)
		headerView.addSubview(saveButton)
		
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(billTitleTextField)
		contentView.addSubview(amountTextField)
		contentView.addSubview(currencySegmentedControl)
		contentView.addSubview(locationTextField)
		contentView.addSubview(descriptionTextField)
		contentView.addSubview(participantsTableView)
		contentView.addSubview(addParticipantButton)
		contentView.addSubview(summaryView)
		summaryView.addSubview(summaryLabel)
		
		setupConstraints()
		setupTableView()
	}
	
	private func setupConstraints() {
		tableViewHeightConstraint = participantsTableView.heightAnchor.constraint(equalToConstant: 200)
		
		NSLayoutConstraint.activate([
			// Header view
			headerView.topAnchor.constraint(equalTo: view.topAnchor),
			headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			headerView.heightAnchor.constraint(equalToConstant: 80),
			
			// Drag indicator
			dragIndicator.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
			dragIndicator.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			dragIndicator.widthAnchor.constraint(equalToConstant: 36),
			dragIndicator.heightAnchor.constraint(equalToConstant: 4),
			
			// Title label
			titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 8),
			
			// Cancel button
			cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
			cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			
			// Save button
			saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
			saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			saveButton.widthAnchor.constraint(equalToConstant: 60),
			saveButton.heightAnchor.constraint(equalToConstant: 32),
			
			// Scroll view
			scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			// Content view
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			// Form fields
			billTitleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			billTitleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			billTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			billTitleTextField.heightAnchor.constraint(equalToConstant: 50),
			
			amountTextField.topAnchor.constraint(equalTo: billTitleTextField.bottomAnchor, constant: 16),
			amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			amountTextField.heightAnchor.constraint(equalToConstant: 50),
			
			currencySegmentedControl.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
			currencySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			currencySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			currencySegmentedControl.heightAnchor.constraint(equalToConstant: 32),
			
			locationTextField.topAnchor.constraint(equalTo: currencySegmentedControl.bottomAnchor, constant: 16),
			locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			locationTextField.heightAnchor.constraint(equalToConstant: 50),
			
			descriptionTextField.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 16),
			descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			descriptionTextField.heightAnchor.constraint(equalToConstant: 50),
			
			// Participants section
			participantsTableView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 24),
			participantsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			participantsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			tableViewHeightConstraint,
			
			addParticipantButton.topAnchor.constraint(equalTo: participantsTableView.bottomAnchor, constant: 8),
			addParticipantButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			addParticipantButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			addParticipantButton.heightAnchor.constraint(equalToConstant: 44),
			
			// Summary view
			summaryView.topAnchor.constraint(equalTo: addParticipantButton.bottomAnchor, constant: 24),
			summaryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			summaryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			summaryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
			
			summaryLabel.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 16),
			summaryLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 16),
			summaryLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -16),
			summaryLabel.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -16)
		])
	}
	
	private func setupTableView() {
		participantsTableView.dataSource = self
		participantsTableView.delegate = self
	}
	
	private func setupBindings() {
		// Form bindings
		billTitleTextField.rx.text.orEmpty
			.bind(to: viewModel.titleRelay)
			.disposed(by: disposeBag)
		
		amountTextField.rx.text.orEmpty
			.bind(to: viewModel.amountRelay)
			.disposed(by: disposeBag)
		
		locationTextField.rx.text.orEmpty
			.bind(to: viewModel.locationRelay)
			.disposed(by: disposeBag)
		
		descriptionTextField.rx.text.orEmpty
			.bind(to: viewModel.descriptionRelay)
			.disposed(by: disposeBag)
		
		currencySegmentedControl.rx.selectedSegmentIndex
			.map { ["USD", "IDR", "EUR", "GBP"][$0] }
			.bind(to: viewModel.currencyRelay)
			.disposed(by: disposeBag)
		
		// Button actions
		cancelButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
		
		saveButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.viewModel.createBill()
			})
			.disposed(by: disposeBag)
		
		addParticipantButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.viewModel.addParticipant()
			})
			.disposed(by: disposeBag)
		
		// Participants changes
		viewModel.participantsRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.updateTableViewHeight()
				self?.participantsTableView.reloadData()
			})
			.disposed(by: disposeBag)
		
		// Form validation
		viewModel.isFormValid
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isValid in
				self?.updateSaveButtonState(isEnabled: isValid)
			})
			.disposed(by: disposeBag)
		
		// Summary updates
		Observable.combineLatest(
			viewModel.totalAmount,
			viewModel.participantCount,
			viewModel.amountPerParticipant,
			viewModel.currencyRelay.asObservable()
		) { amount, count, perPerson, currency in
			let formatter = NumberFormatter()
			formatter.numberStyle = .currency
			formatter.currencyCode = currency
			
			let totalFormatted = formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
			let perPersonFormatted = formatter.string(from: NSNumber(value: perPerson)) ?? "\(currency) \(perPerson)"
			
			return "Total: \(totalFormatted) • \(count) participant\(count == 1 ? "" : "s") • \(perPersonFormatted) each"
		}
		.bind(to: summaryLabel.rx.text)
		.disposed(by: disposeBag)
		
		// Loading state
		viewModel.isLoadingRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isLoading in
				self?.saveButton.isEnabled = !isLoading
				self?.saveButton.setTitle(isLoading ? "Saving..." : "Save", for: .normal)
			})
			.disposed(by: disposeBag)
		
		// Success
		viewModel.successRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.dismiss(animated: true)
			})
			.disposed(by: disposeBag)
		
		// Error handling
		viewModel.errorRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] error in
				self?.showErrorAlert(error: error)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupKeyboardHandling() {
		NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
			.subscribe(onNext: { [weak self] notification in
				self?.handleKeyboardShow(notification)
			})
			.disposed(by: disposeBag)
		
		NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
			.subscribe(onNext: { [weak self] notification in
				self?.handleKeyboardHide(notification)
			})
			.disposed(by: disposeBag)
		
		let tapGesture = UITapGestureRecognizer()
		view.addGestureRecognizer(tapGesture)
		tapGesture.rx.event
			.subscribe(onNext: { [weak self] _ in
				self?.view.endEditing(true)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Helper Methods
	
	private func createTextField(placeholder: String, returnKeyType: UIReturnKeyType) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.borderStyle = .roundedRect
		textField.backgroundColor = .tertiarySystemGroupedBackground
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.separator.cgColor
		textField.layer.cornerRadius = 10
		textField.returnKeyType = returnKeyType
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}
	
	private func updateTableViewHeight() {
		let participantCount = viewModel.participantsRelay.value.count
		let height = max(CGFloat(participantCount * 110), 110) // 110 per cell
		tableViewHeightConstraint.constant = height
	}
	
	private func updateSaveButtonState(isEnabled: Bool) {
		saveButton.isEnabled = isEnabled
		
		UIView.animate(withDuration: 0.3) {
			if isEnabled {
				self.saveButton.backgroundColor = .systemBlue
				self.saveButton.alpha = 1.0
			} else {
				self.saveButton.backgroundColor = .systemGray4
				self.saveButton.alpha = 0.6
			}
		}
	}
	
	private func handleKeyboardShow(_ notification: Notification) {
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		let keyboardHeight = keyboardFrame.cgRectValue.height
		
		UIView.animate(withDuration: duration) {
			self.scrollView.contentInset.bottom = keyboardHeight
			self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
		}
	}
	
	private func handleKeyboardHide(_ notification: Notification) {
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		UIView.animate(withDuration: duration) {
			self.scrollView.contentInset.bottom = 0
			self.scrollView.verticalScrollIndicatorInsets.bottom = 0
		}
	}
	
	private func showErrorAlert(error: Error) {
		let alert = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - UITableViewDataSource

extension AddBillViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.participantsRelay.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantInputCell.identifier, for: indexPath) as! ParticipantInputCell
		
		let participant = viewModel.participantsRelay.value[indexPath.row]
		cell.configure(with: participant)
		cell.delegate = self
		
		return cell
	}
}

// MARK: - UITableViewDelegate

extension AddBillViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 110
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Participants"
	}
}

// MARK: - ParticipantInputCellDelegate

extension AddBillViewController: ParticipantInputCellDelegate {
	func participantCell(_ cell: ParticipantInputCell, didUpdateName name: String, email: String) {
		guard let indexPath = participantsTableView.indexPath(for: cell) else { return }
		viewModel.updateParticipant(at: indexPath.row, name: name, email: email)
	}
	
	func participantCellDidRequestRemoval(_ cell: ParticipantInputCell) {
		guard let indexPath = participantsTableView.indexPath(for: cell) else { return }
		
		// Don't allow removing the last participant
		guard viewModel.participantsRelay.value.count > 1 else {
			let alert = UIAlertController(
				title: "Cannot Remove",
				message: "At least one participant is required.",
				preferredStyle: .alert
			)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}
		
		viewModel.removeParticipant(at: indexPath.row)
	}
}
