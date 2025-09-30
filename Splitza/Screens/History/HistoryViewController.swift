//
//  HistoryViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit
import Combine

final class HistoryViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel: HistoryViewModel
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - UI Components
	private var headerView: HistoryHeaderView!
	private var tableView: UITableView!
	private lazy var emptyStateView: HistoryEmptyStateView = HistoryEmptyStateView()
	
	// MARK: - Initialization
	
	init(viewModel: HistoryViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		Task {
			await setupHistoryHeaderView()
			await setupTableView()
			
			await MainActor.run {
				setupUI()
				observeViewModel()
			}
		}
	}

	required init?(coder: NSCoder) {
		self.viewModel = HistoryViewModel()
		super.init(coder: coder)
		Task {
			await setupHistoryHeaderView()
			await setupTableView()
			
			await MainActor.run {
				setupUI()
				observeViewModel()
			}
		}
	}

	// MARK: - UI Creation

	private func setupHistoryHeaderView() async {
		
		let headerView = HistoryHeaderView()
		await headerView.setupHeaderView()
		
		await MainActor.run {
			self.headerView = headerView
			self.headerView.searchBar.delegate = self
		}
	}
	
	private func setupTableView() async {
		let tableView = UITableView()
		tableView.backgroundColor = .systemGroupedBackground
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(SplitBillTableViewCell.self, forCellReuseIdentifier: SplitBillTableViewCell.identifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		await MainActor.run {
			self.tableView = tableView
		}
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Load data asynchronously
//		Task {
//			await viewModel.loadData()
//		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide navigation bar for custom header
		navigationController?.setNavigationBarHidden(true, animated: animated)
		
		// Setup navigation bar items when needed
		setupNavigationBar()
	}
	
	// MARK: - Navigation Setup
	
	private func setupNavigationBar() {
		// Create add button
		let addButton = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonTapped)
		)
		addButton.tintColor = .systemBlue
		
		// You can add this to a navigation controller if needed
		// For now, we'll add it as a floating action button
		setupFloatingActionButton()
	}
	
	private func setupFloatingActionButton() {
		let addButton = UIButton(type: .system)
		addButton.setImage(UIImage(systemName: "plus"), for: .normal)
		addButton.backgroundColor = .systemBlue
		addButton.tintColor = .white
		addButton.layer.cornerRadius = 28
		addButton.layer.shadowColor = UIColor.black.cgColor
		addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
		addButton.layer.shadowRadius = 4
		addButton.layer.shadowOpacity = 0.3
		addButton.translatesAutoresizingMaskIntoConstraints = false
		
		addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
		
		view.addSubview(addButton)
		
		NSLayoutConstraint.activate([
			addButton.widthAnchor.constraint(equalToConstant: 56),
			addButton.heightAnchor.constraint(equalToConstant: 56),
			addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
	}
	
	@objc private func addButtonTapped() {
		presentAddBillViewController()
	}
	
	private func presentAddBillViewController() {
		
		let addBillViewController = AddBillViewController()
		let addBillNavigationController = UINavigationController(rootViewController: addBillViewController)
		addBillNavigationController.modalTransitionStyle = .coverVertical
		addBillNavigationController.modalPresentationStyle = .fullScreen
		
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
		
		present(addBillNavigationController, animated: true)
	}
	
	// MARK: - Setup Data Layer
	private func observeViewModel() {
		observeDataSourceChanges()
		observeViewStateChanges()
	}
	
	private func observeDataSourceChanges() {
		// Observe split bills changes
		viewModel.$splitBills
			.combineLatest(viewModel.$filteredSplitBills, viewModel.$isSearching)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _, _, _ in
				self?.updateUI()
			}
			.store(in: &cancellables)
	}
	
	private func observeViewStateChanges() {
		viewModel.$viewState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] viewState in
				if case .error(let error) = viewState {
					self?.showErrorAlert(error: error)
					return
				}
				
				self?.updateUI()
			}
			.store(in: &cancellables)
	}
	
	// MARK: - Setup UI Components
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		
		// Add subviews
		view.addSubview(headerView)
		view.addSubview(tableView)
		view.addSubview(emptyStateView)
		
		setupConstraints()
		setupKeyboardHandling()
	}
	
	private func setupConstraints() {
		setupHeaderConstraints()
		setupTableViewConstraints()
		setupEmptyStateConstraints()
	}
	
	private func setupHeaderConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
			headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	private func setupTableViewConstraints() {
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	private func setupEmptyStateConstraints() {
		NSLayoutConstraint.activate([
			emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	private func setupKeyboardHandling() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		
		// Add tap to dismiss keyboard
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
	}
	
	// MARK: - UI Updates
	
	private func updateUI() {
		let isEmpty = viewModel.isEmpty
		let emptyStateInfo = viewModel.emptyStateInfo
		
		emptyStateView.isHidden = !isEmpty
		tableView.isHidden = isEmpty
		
		if !emptyStateInfo.title.isEmpty {
			emptyStateView.configure(
				title: emptyStateInfo.title,
				subtitle: emptyStateInfo.subtitle,
				imageName: emptyStateInfo.imageName
			)
		}
		
		tableView.reloadData()
	}
	
	// MARK: - Keyboard Handling
	
	@objc private func keyboardWillShow(_ notification: Notification) {
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		let keyboardHeight = keyboardFrame.cgRectValue.height
		
		UIView.animate(withDuration: duration) {
			self.tableView.contentInset.bottom = keyboardHeight
			self.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight
		}
	}
	
	@objc private func keyboardWillHide(_ notification: Notification) {
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
			return
		}
		
		UIView.animate(withDuration: duration) {
			self.tableView.contentInset.bottom = 20
			self.tableView.verticalScrollIndicatorInsets.bottom = 0
		}
	}
	
	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SplitBillTableViewCell.identifier, for: indexPath) as? SplitBillTableViewCell,
			  let splitBill = viewModel.splitBill(at: indexPath.row) else {
			return UITableViewCell()
		}
		
		cell.configure(with: splitBill)
		
		return cell
	}
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let splitBill = viewModel.splitBill(at: indexPath.row) else { return }
		
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
		
		// TODO: Navigate to split bill detail view
		print("Selected split bill: \(splitBill.title)")
		
		// For now, let's show a simple alert
		showSplitBillDetail(splitBill)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
	// Add swipe to delete functionality
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
			self?.confirmDeleteSplitBill(at: indexPath, completion: completion)
		}
		
		deleteAction.image = UIImage(systemName: "trash")
		
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let splitBill = viewModel.splitBill(at: indexPath.row), !splitBill.isSettled else {
			return nil
		}
		
		let settleAction = UIContextualAction(style: .normal, title: "Settle") { [weak self] _, _, completion in
			self?.settleSplitBill(at: indexPath, completion: completion)
		}
		
		settleAction.image = UIImage(systemName: "checkmark.circle")
		settleAction.backgroundColor = .systemGreen
		
		return UISwipeActionsConfiguration(actions: [settleAction])
	}
	
	private func confirmDeleteSplitBill(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
		guard let splitBill = viewModel.splitBill(at: indexPath.row) else {
			completion(false)
			return
		}
		
		let alert = UIAlertController(
			title: "Delete Split Bill",
			message: "Are you sure you want to delete \"\(splitBill.title)\"? This action cannot be undone.",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
			completion(false)
		})
		
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			Task {
				await self?.viewModel.deleteSplitBill(at: indexPath.row)
			}
			completion(true)
		})
		
		present(alert, animated: true)
	}
	
	private func settleSplitBill(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
		guard let splitBill = viewModel.splitBill(at: indexPath.row) else {
			completion(false)
			return
		}
		
		let alert = UIAlertController(
			title: "Settle Split Bill",
			message: "Mark \"\(splitBill.title)\" as settled? All participants will be marked as paid.",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
			completion(false)
		})
		
		alert.addAction(UIAlertAction(title: "Settle", style: .default) { [weak self] _ in
			Task {
				await self?.viewModel.settleSplitBill(at: indexPath.row)
			}
			completion(true)
		})
		
		present(alert, animated: true)
	}
	
	private func showSplitBillDetail(_ splitBill: SplitBill) {
		let alert = UIAlertController(
			title: splitBill.title,
			message: """
   Amount: \(splitBill.formattedAmount)
   Date: \(splitBill.formattedDate)
   Location: \(splitBill.location ?? "No location")
   Participants: \(splitBill.participantCount)
   Status: \(splitBill.isSettled ? "Settled" : "Pending")
   """,
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - CustomSearchBarDelegate

extension HistoryViewController: CustomSearchBarDelegate {
	func searchBar(_ searchBar: CustomSearchBar, textDidChange searchText: String) {
		viewModel.updateSearchQuery(searchText)
		
		// Add subtle haptic feedback for search
		if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			let selectionFeedback = UISelectionFeedbackGenerator()
			selectionFeedback.selectionChanged()
		}
	}
	
	func searchBarDidBeginEditing(_ searchBar: CustomSearchBar) {
		// Optional: Add any additional behavior when search begins
	}
	
	func searchBarDidEndEditing(_ searchBar: CustomSearchBar) {
		// Optional: Add any additional behavior when search ends
	}
	
	private func showErrorAlert(error: Error) {
		let alert = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
			Task {
				await self?.viewModel.loadData()
			}
		})
		
		present(alert, animated: true)
	}
}
