//
//  AddBillV2ViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillV2ViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel = AddBillV2ViewModel()
	private let disposeBag = DisposeBag()
	
	// MARK: - UI Components
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.backgroundColor = .systemGroupedBackground
		scrollView.showsVerticalScrollIndicator = false
		scrollView.keyboardDismissMode = .none
		scrollView.delaysContentTouches = false
		scrollView.canCancelContentTouches = true
		
		return scrollView
	}()
	
	private lazy var contentView: UIView = UIView()
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var titleTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Bill title (e.g., Lunch at Restaurant)"
		textField.font = .systemFont(ofSize: 18, weight: .semibold)
		textField.textColor = .label
		textField.borderStyle = .none
		textField.returnKeyType = .next
		return textField
	}()
	
	private lazy var locationTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Location (optional)"
		textField.font = .systemFont(ofSize: 14, weight: .regular)
		textField.textColor = .secondaryLabel
		textField.borderStyle = .none
		textField.returnKeyType = .next
		return textField
	}()
	
	private lazy var participantsPoolView: ParticipantsPoolView = ParticipantsPoolView(viewModel: viewModel)
	
	private lazy var menuItemsHeaderView: UIView = UIView()
	
	private lazy var menuItemsLabel: UILabel = {
		let label = UILabel()
		label.text = "Menu Items"
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		return label
	}()
	
	private lazy var totalAmountLabel: UILabel = {
		let label = UILabel()
		label.text = "Total: \(0.0.formattedCurrency(currencyCode: viewModel.currencyRelay.value))"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .systemBlue
		return label
	}()
	
	private lazy var addMenuItemButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("+ Add Menu Item", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
		button.setTitleColor(.systemBlue, for: .normal)
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.systemBlue.cgColor
		return button
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.isScrollEnabled = false
		tableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.identifier)
		return tableView
	}()
	
	private lazy var summaryView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var summaryLabel: UILabel = {
		let label = UILabel()
		label.text = "Bill Summary"
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.textColor = .label
		return label
	}()
	
	private lazy var summaryStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8
		stack.alignment = .fill
		stack.distribution = .fill
		return stack
	}()
	
	private lazy var saveBarButtonItem: UIBarButtonItem = {
		let button = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
		button.isEnabled = false
		return button
	}()
	
	// MARK: - Lifecycle
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupBindings()
		setupActions()
		setupKeyboardNotifications()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigation()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemGroupedBackground
		
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(headerView)
		contentView.addSubview(participantsPoolView)
		contentView.addSubview(menuItemsHeaderView)
		contentView.addSubview(tableView)
		contentView.addSubview(addMenuItemButton)
		contentView.addSubview(summaryView)
		
		headerView.addSubview(titleTextField)
		headerView.addSubview(locationTextField)
		
		menuItemsHeaderView.addSubview(menuItemsLabel)
		menuItemsHeaderView.addSubview(totalAmountLabel)
		
		summaryView.addSubview(summaryLabel)
		summaryView.addSubview(summaryStackView)
		
		setupConstraints()
		setupTableView()
	}
	
	private func setupConstraints() {
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		contentView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		headerView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(80)
		}
		
		titleTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(24)
		}
		
		locationTextField.snp.makeConstraints { make in
			make.top.equalTo(titleTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(20)
		}
		
		participantsPoolView.snp.makeConstraints { make in
			make.top.equalTo(headerView.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		menuItemsHeaderView.snp.makeConstraints { make in
			make.top.equalTo(participantsPoolView.snp.bottom).offset(24)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(30)
		}
		
		menuItemsLabel.snp.makeConstraints { make in
			make.leading.centerY.equalToSuperview()
		}
		
		totalAmountLabel.snp.makeConstraints { make in
			make.trailing.centerY.equalToSuperview()
		}
		
		tableView.snp.makeConstraints { make in
			make.top.equalTo(menuItemsHeaderView.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(0) // Will be updated dynamically
		}
		
		addMenuItemButton.snp.makeConstraints { make in
			make.top.equalTo(tableView.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(50)
		}
		
		summaryView.snp.makeConstraints { make in
			make.top.equalTo(addMenuItemButton.snp.bottom).offset(24)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		summaryLabel.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview().inset(16)
		}
		
		summaryStackView.snp.makeConstraints { make in
			make.top.equalTo(summaryLabel.snp.bottom).offset(12)
			make.leading.trailing.bottom.equalToSuperview().inset(16)
		}
		
		// Update content view bottom constraint
		summaryView.snp.makeConstraints { make in
			make.bottom.equalToSuperview().offset(-24)
		}
	}
	
	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	private func setupNavigation() {
		title = "Split Bill"
		navigationController?.navigationBar.prefersLargeTitles = false
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelTapped)
		)
		
		navigationItem.rightBarButtonItem = saveBarButtonItem
	}
	
	private func setupActions() {
		addMenuItemButton.addTarget(self, action: #selector(addMenuItemTapped), for: .touchUpInside)
		
		participantsPoolView.onAddParticipant = { [weak self] in
			self?.presentAddParticipantDialog()
		}
	}
	
	private func setupKeyboardNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow(_:)),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide(_:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		
		// Add tap gesture to dismiss keyboard
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
	}
	
	private func setupBindings() {
		// Title binding
		titleTextField.rx.text.orEmpty
			.bind(to: viewModel.titleRelay)
			.disposed(by: disposeBag)
		
		// Location binding
		locationTextField.rx.text.orEmpty
			.bind(to: viewModel.locationRelay)
			.disposed(by: disposeBag)
		
		// Menu items changes
		viewModel.menuItemsRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] menuItems in
				self?.updateMenuItemsUI(menuItems)
			})
			.disposed(by: disposeBag)
		
		// Total amount changes
		viewModel.totalAmountObservable
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] totalAmount in
				self?.updateTotalAmount(totalAmount)
			})
			.disposed(by: disposeBag)
		
		// Participant totals changes
		viewModel.participantTotalsObservable
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] totals in
				self?.updateSummary(totals)
			})
			.disposed(by: disposeBag)
		
		// Save button state
		Observable.combineLatest(
			viewModel.titleRelay.asObservable(),
			viewModel.menuItemsRelay.asObservable()
		) { title, menuItems in
			return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
				   !menuItems.isEmpty &&
				   menuItems.allSatisfy { !$0.title.isEmpty && $0.price > 0 && !$0.assignedParticipantIds.isEmpty }
		}
		.observe(on: MainScheduler.instance)
		.subscribe(onNext: { [weak self] canSave in
			self?.updateSaveButtonState(canSave)
		})
		.disposed(by: disposeBag)
	}
	
	// MARK: - Actions
	
	@objc private func cancelTapped() {
		dismiss(animated: true)
	}
	
	@objc private func addMenuItemTapped() {
		viewModel.addMenuItem()
		
		// Haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
	}
	
	@objc private func saveTapped() {
		// TODO: Implement save functionality
		print("Save bill tapped")
		
		// For now, just dismiss
		dismiss(animated: true)
	}
	
	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc private func keyboardWillShow(_ notification: Notification) {
		
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		
		let keyboardHeight = keyboardFrame.cgRectValue.height
		let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
		
		DispatchQueue.main.async {
			self.scrollView.contentInset = contentInsets
			self.scrollView.scrollIndicatorInsets = contentInsets
		}
	}
	
	@objc private func keyboardWillHide(_ notification: Notification) {
		
		DispatchQueue.main.async {
			self.scrollView.contentInset = .zero
			self.scrollView.scrollIndicatorInsets = .zero
		}
	}
	
	// MARK: - Private Methods
	
	private func updateMenuItemsUI(_ menuItems: [MenuItem]) {
		
		// Always use simple reloadData - it's the safest approach
		tableView.reloadData()
		
		// Option 1: Force layout immediately (synchronous)
		tableView.layoutIfNeeded()
		
		let cellHeight: CGFloat = 88
		
		tableView.snp.updateConstraints { make in
			make.height.equalTo(max(tableView.contentSize.height, cellHeight))
		}
		
		// Animate the height change
		UIView.animate(
			withDuration: 0.3,
			delay: 0,
			usingSpringWithDamping: 0.8,
			initialSpringVelocity: 0.5,
			options: .curveEaseInOut
		) { [weak self] in
			self?.tableView.setNeedsLayout()
			self?.tableView.layoutIfNeeded()
		}
	}
	
	private func updateTotalAmount(_ amount: Double) {
		totalAmountLabel.text = "Total: \(amount.formattedCurrency(currencyCode: viewModel.currencyRelay.value))"
	}
	
	private func updateSummary(_ totals: [String: Double]) {
		// Clear existing summary
		summaryStackView.arrangedSubviews.forEach { view in
			summaryStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		
		// Add participant summaries
		let participants = viewModel.participantsRelay.value
		for participant in participants {
			let amount = totals[participant.id] ?? 0.0
			if amount > 0 {
				let summaryRow = createSummaryRow(participant: participant, amount: amount)
				summaryStackView.addArrangedSubview(summaryRow)
			}
		}
		
		// Show empty state if no participants have amounts
		if summaryStackView.arrangedSubviews.isEmpty {
			let emptyLabel = UILabel()
			emptyLabel.text = "Add menu items and assign participants"
			emptyLabel.font = .systemFont(ofSize: 14, weight: .regular)
			emptyLabel.textColor = .secondaryLabel
			emptyLabel.textAlignment = .center
			summaryStackView.addArrangedSubview(emptyLabel)
		}
	}
	
	private func createSummaryRow(participant: BillParticipant, amount: Double) -> UIView {
		let containerView = UIView()
		
		let nameLabel = UILabel()
		nameLabel.text = participant.name
		nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
		nameLabel.textColor = .label
		
		let amountLabel = UILabel()
		amountLabel.text = "$\(String(format: "%.2f", amount))"
		amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
		amountLabel.textColor = .systemBlue
		
		containerView.addSubview(nameLabel)
		containerView.addSubview(amountLabel)
		
		nameLabel.snp.makeConstraints { make in
			make.leading.top.bottom.equalToSuperview()
		}
		
		amountLabel.snp.makeConstraints { make in
			make.trailing.top.bottom.equalToSuperview()
		}
		
		containerView.snp.makeConstraints { make in
			make.height.equalTo(24)
		}
		
		return containerView
	}
	
	private func updateSaveButtonState(_ canSave: Bool) {
		saveBarButtonItem.isEnabled = canSave
	}
	
	private func presentAddParticipantDialog() {
		let alert = UIAlertController(title: "Add Participant", message: "Enter participant details", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "Name"
			textField.returnKeyType = .next
		}
		
		alert.addTextField { textField in
			textField.placeholder = "Email (optional)"
			textField.keyboardType = .emailAddress
			textField.returnKeyType = .done
		}
		
		let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
			guard let nameField = alert.textFields?[0],
				  let emailField = alert.textFields?[1],
				  let name = nameField.text,
				  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
				return
			}
			
			let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
			let participant = BillParticipant(name: name, email: email)
			self?.viewModel.addParticipant(participant)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		alert.addAction(addAction)
		alert.addAction(cancelAction)
		
		present(alert, animated: true)
	}
	
	private func presentParticipantSelector(for menuItem: MenuItem, at indexPath: IndexPath) {
		let participants = viewModel.participantsRelay.value
		let selectorVC = ParticipantSelectorViewController(participants: participants, menuItem: menuItem)
		
		selectorVC.onAssignmentsUpdated = { [weak self] assignments in
			guard let self = self else { return }
			
			// Find the menu item and update its assignments
			let menuItems = self.viewModel.menuItemsRelay.value
			
			// For simplicity, let's find by comparing attributes (in a real app, you'd pass the menu item ID)
			if let index = menuItems.firstIndex(where: { $0.title == menuItem.title && $0.price == menuItem.price }) {
				var updatedMenuItem = menuItems[index]
				updatedMenuItem.participantAssignments = assignments
				self.viewModel.updateMenuItem(at: index, with: updatedMenuItem)
			}
		}
		
		selectorVC.modalPresentationStyle = .overFullScreen
		selectorVC.modalTransitionStyle = .crossDissolve
		
		present(selectorVC, animated: true)
	}
}

// MARK: - UITableViewDataSource

extension AddBillV2ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.menuItemsRelay.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.identifier, for: indexPath) as! MenuItemCell
		
		let menuItem = viewModel.menuItemsRelay.value[indexPath.row]
		let participants = viewModel.participantsRelay.value
		let currency = viewModel.currencyRelay.value
		
		cell.configure(with: menuItem, participants: participants, currency: currency)
		
		// Configure closures
		cell.onTitleChanged = { [weak self] title in
			guard let self = self else { return }
			var updatedMenuItem = self.viewModel.menuItemsRelay.value[indexPath.row]
			updatedMenuItem.title = title
			self.viewModel.updateMenuItem(at: indexPath.row, with: updatedMenuItem)
		}
		
		cell.onPriceChanged = { [weak self] price in
			guard let self = self else { return }
			var updatedMenuItem = self.viewModel.menuItemsRelay.value[indexPath.row]
			updatedMenuItem.price = price
			self.viewModel.updateMenuItem(at: indexPath.row, with: updatedMenuItem)
		}
		
		cell.onParticipantSelectionRequested = { [weak self] in
			guard let self = self else { return }
			let menuItem = self.viewModel.menuItemsRelay.value[indexPath.row]
			self.presentParticipantSelector(for: menuItem, at: indexPath)
		}
		
		return cell
	}
}

// MARK: - UITableViewDelegate

extension AddBillV2ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 88
	}

	// Swipe-to-delete support replacing the inline remove button
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
			self?.viewModel.removeMenuItem(at: indexPath.row)
			completion(true)
		}
		deleteAction.backgroundColor = .systemRed
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}
