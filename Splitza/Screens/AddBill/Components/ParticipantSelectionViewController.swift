//
//  ParticipantSelectionViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ParticipantSelectionViewController: UIViewController {
	
	// MARK: - Properties
	private let participantManager: ParticipantManagerProtocol
	private let disposeBag = DisposeBag()
	private var savedParticipants: [SavedParticipant] = []
	
	// MARK: - UI Components
	
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "Search participants"
		searchBar.searchBarStyle = .minimal
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .systemGroupedBackground
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ParticipantCell")
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private lazy var emptyStateLabel: UILabel = {
		let label = UILabel()
		label.text = "No saved participants"
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		return label
	}()
	
	private let viewModel: AddBillViewModel
	private let indexCaller: Int
	
	// MARK: - Initialization
	init(participantManager: ParticipantManagerProtocol = ParticipantManager(), viewModel: AddBillViewModel, indexCaller: Int) {
		self.participantManager = participantManager
		self.viewModel = viewModel
		self.indexCaller = indexCaller
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupBindings()
		loadParticipants()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = .systemGroupedBackground
		title = "Select Participant"
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelTapped)
		)
		
		view.addSubview(searchBar)
		view.addSubview(tableView)
		view.addSubview(emptyStateLabel)
		
		NSLayoutConstraint.activate([
			// Search bar
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			// Table view
			tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			// Empty state label
			emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}
	
	private func setupBindings() {
		searchBar.rx.text.orEmpty
			.distinctUntilChanged()
			.debounce(.milliseconds(300), scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak self] query in
				self?.searchParticipants(query: query)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Actions
	
	@objc private func cancelTapped() {
		dismiss(animated: true)
	}
	
	// MARK: - Data Management
	
	private func loadParticipants() {
		savedParticipants = participantManager.getAllParticipants()
		updateUI()
	}
	
	private func searchParticipants(query: String) {
		savedParticipants = participantManager.searchParticipants(with: query)
		updateUI()
	}
	
	private func updateUI() {
		tableView.reloadData()
		emptyStateLabel.isHidden = !savedParticipants.isEmpty
	}
}

// MARK: - UITableViewDataSource

extension ParticipantSelectionViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return savedParticipants.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath)
		let participant = savedParticipants[indexPath.row]
		
		cell.textLabel?.text = participant.name
		cell.detailTextLabel?.text = participant.email
		cell.accessoryType = .disclosureIndicator
		
		return cell
	}
}

// MARK: - UITableViewDelegate

extension ParticipantSelectionViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let participant = savedParticipants[indexPath.row]
		
		viewModel.updateParticipant(
			at: indexCaller,
			name: participant.name,
			email: participant.email,
			amount: ""
		)
		
		dismiss(animated: true)
	}
}
