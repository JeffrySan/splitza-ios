//
//  HistoryViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit
import RxSwift
import RxRelay

final class HistoryViewController: UIViewController {
	
	// MARK: - Properties
	
	private let viewModel: HistoryViewModel
	
	// MARK: - UI Components
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Split History"
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Track all your shared expenses"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var searchBar: CustomSearchBar = {
		let searchBar = CustomSearchBar()
		searchBar.delegate = self
		searchBar.placeholder = "Search bills, locations, people..."
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.backgroundColor = .systemGroupedBackground
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(SplitBillTableViewCell.self, forCellReuseIdentifier: SplitBillTableViewCell.identifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var emptyStateView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.isHidden = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var emptyStateImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
		imageView.tintColor = .systemGray3
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private lazy var emptyStateLabel: UILabel = {
		let label = UILabel()
		label.text = "No split bills found"
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.textColor = .systemGray
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var emptyStateSubLabel: UILabel = {
		let label = UILabel()
		label.text = "Your split bill history will appear here"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .systemGray2
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Initialization
	
	init(viewModel: HistoryViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		self.viewModel = HistoryViewModel()
		super.init(coder: coder)
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		observeViewModel()
		
		setupUI()
		
		viewModel.loadData()
		animateTableViewEntrance()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide navigation bar for custom header
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	// MARK: - Setup Data Layer
	private func observeViewModel() {
		observeDataSourceChanges()
		observeViewStateChanges()
	}
	
	private func observeDataSourceChanges() {
		lazy var allSplitBillObservable = viewModel.splitBillsRelay
			.asObservable()
			.distinctUntilChanged()
		
		lazy var filteredSplitBillsObservable = viewModel.filteredSplitBillsRelay
			.asObservable()
			.distinctUntilChanged()
		
		viewModel.isSearchingRelay
			.asObservable()
			.distinctUntilChanged()
			.map { isSearchingState -> Observable<[SplitBill]> in
				return isSearchingState ? filteredSplitBillsObservable : allSplitBillObservable
			}
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] _ in
				self?.updateUI()
			})
			.disposed(by: viewModel.disposeBag)
	}
	
	private func observeViewStateChanges() {
		viewModel.viewStateRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] viewState in
				
				if case .error(let error) = viewState {
					self?.showErrorAlert(error: error)
					return
				}
				
				self?.updateUI()
			})
			.disposed(by: viewModel.disposeBag)
	}
	
	private func animateTableViewEntrance() {
		let cells = tableView.visibleCells
		let tableViewHeight = tableView.bounds.height
		
		for (index, cell) in cells.enumerated() {
			cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
			
			UIView.animate(
				withDuration: 0.8,
				delay: Double(index) * 0.1,
				usingSpringWithDamping: 0.8,
				initialSpringVelocity: 0.5,
				options: [.curveEaseInOut]
			) {
				cell.transform = .identity
			}
		}
	}
	
	// MARK: - Setup UI Components
	
	private func setupUI() {
		view.backgroundColor = .systemBackground
		
		// Add subviews
		view.addSubview(headerView)
		headerView.addSubview(titleLabel)
		headerView.addSubview(subtitleLabel)
		headerView.addSubview(searchBar)
		
		view.addSubview(tableView)
		view.addSubview(emptyStateView)
		
		emptyStateView.addSubview(emptyStateImageView)
		emptyStateView.addSubview(emptyStateLabel)
		emptyStateView.addSubview(emptyStateSubLabel)
		
		setupConstraints()
		setupKeyboardHandling()
	}
	
	private func setupConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			// Header view
			headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
			headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			// Title label
			titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
			
			// Subtitle label
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
			subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
			
			// Search bar
			searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
			searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
			searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
			searchBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
			
			// Table view
			tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			// Empty state view
			emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
			emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
			
			// Empty state image
			emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
			emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
			emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
			emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
			
			// Empty state label
			emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 20),
			emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
			emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
			
			// Empty state sub label
			emptyStateSubLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
			emptyStateSubLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
			emptyStateSubLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
			emptyStateSubLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
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
		let emptyStateInfo = viewModel.emptyStateInfo
		let isEmpty = viewModel.isEmpty
		
		emptyStateView.isHidden = !isEmpty
		tableView.isHidden = isEmpty
		
		if !emptyStateInfo.title.isEmpty {
			emptyStateLabel.text = emptyStateInfo.title
			emptyStateSubLabel.text = emptyStateInfo.subtitle
			emptyStateImageView.image = UIImage(systemName: emptyStateInfo.imageName)
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
			self?.viewModel.deleteSplitBill(at: indexPath.row)
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
			self?.viewModel.settleSplitBill(at: indexPath.row)
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
			self?.viewModel.loadData()
		})
		
		present(alert, animated: true)
	}
}
