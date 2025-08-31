//
//  AddBillParticipantsView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillParticipantsView: UIView {
	
	var didSelectParticipants: ((Int) -> Void)?
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	
	// Observables
	let participantsRelay = BehaviorRelay<[ParticipantInput]>(value: [])
	let currencyRelay = BehaviorRelay<String>(value: "USD")
	
	// MARK: - UI Components
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.text = "Participants"
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		return label
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.isScrollEnabled = false
		tableView.clipsToBounds = false
		tableView.rowHeight = UITableView.automaticDimension
		tableView.register(ImprovedParticipantInputCell.self, forCellReuseIdentifier: ImprovedParticipantInputCell.identifier)
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
		return button
	}()
	
	private lazy var autoDistributeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("⚡ Auto Distribute Equally", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
		button.setTitleColor(.systemBlue, for: .normal)
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.systemBlue.cgColor
		return button
	}()
	
	private lazy var buttonStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8 // HIG spacing
		stack.distribution = .fillEqually
		return stack
	}()
	
	private let viewModel: AddBillViewModel
	
	// MARK: - Initialization
	
	init(frame: CGRect, viewModel: AddBillViewModel) {
		
		self.viewModel = viewModel
		
		super.init(frame: frame)
		setupUI()
		setupTableView()
	}
	
	required init?(coder: NSCoder) {
		
		viewModel = AddBillViewModel()
		
		super.init(coder: coder)
		setupUI()
		setupTableView()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		addSubview(headerLabel)
		addSubview(tableView)
		addSubview(buttonStackView)
		
		buttonStackView.addArrangedSubview(addParticipantButton)
		buttonStackView.addArrangedSubview(autoDistributeButton)
		
		setupConstraints()
		setupActions()
		setupBindings()
	}
	
	private func setupConstraints() {
		headerLabel.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		tableView.snp.makeConstraints { make in
			make.top.equalTo(headerLabel.snp.bottom).offset(12)
			make.leading.trailing.equalToSuperview()
			make.height.equalTo(120)
		}
		
		buttonStackView.snp.makeConstraints { make in
			make.top.equalTo(tableView.snp.bottom).offset(20) // Adequate spacing
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview()
		}
		
		// Set consistent height for buttons following HIG
		addParticipantButton.snp.makeConstraints { make in
			make.top.equalTo(tableView.snp.bottom).offset(20)
			make.height.equalTo(44)
		}
		
		autoDistributeButton.snp.makeConstraints { make in
			make.top.equalTo(addParticipantButton.snp.bottom).offset(8)
			make.height.equalTo(44)
		}
	}
	
	private func setupTableView() {
		tableView.dataSource = self
	}
	
	private func setupBindings() {
		// Participants changes - update table height
		participantsRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] participants in
				self?.updateTableViewSafely(with: participants)
			})
			.disposed(by: disposeBag)
		
		// Currency changes - update cell placeholders
		currencyRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] currency in
				self?.updateCurrencyInCells(currency)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupActions() {
		addParticipantButton.addTarget(self, action: #selector(addParticipantTapped), for: .touchUpInside)
		autoDistributeButton.addTarget(self, action: #selector(autoDistributeTapped), for: .touchUpInside)
	}
	
	@objc private func addParticipantTapped() {
		viewModel.addParticipant()
	}
	
	@objc private func autoDistributeTapped() {
		autoDistributeAmount()
	}
	
	// MARK: - Private Methods
	private func autoDistributeAmount() {
		let totalAmount = viewModel.manualTotalAmountRelay.value
		let participants = viewModel.participantsRelay.value
		
		guard totalAmount > 0 && !participants.isEmpty else {
			return
		}
		
		let amountPerPerson = totalAmount / Double(participants.count)
		let formattedAmount = String(format: "%.2f", amountPerPerson)
		
		// Update all participants with equal amounts
		var updatedParticipants = participants
		for i in 0..<updatedParticipants.count {
			updatedParticipants[i] = ParticipantInput(
				name: updatedParticipants[i].name,
				email: updatedParticipants[i].email,
				amount: formattedAmount
			)
		}
		
		viewModel.participantsRelay.accept(updatedParticipants)
		
		// Show feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
		impactFeedback.impactOccurred()
	}
	
	private func updateTableViewSafely(with participants: [ParticipantInput]) {
		print("[Debug] Updating table with \(participants.count) participants")
		
		// Always use simple reloadData - it's the safest approach
		tableView.reloadData()
		
		// Option 1: Force layout immediately (synchronous)
		tableView.layoutIfNeeded()
		updateTableViewHeight(for: participants.count)
		
		// Option 2: Use async for smoother performance (asynchronous)
		// DispatchQueue.main.async { [weak self] in
		//     self?.updateTableViewHeight(for: participants.count)
		// }
	}

	private func updateTableViewHeight(for participantCount: Int) {
		let cellHeight: CGFloat = 120
		
		tableView.snp.updateConstraints { make in
			make.height.equalTo(max(tableView.contentSize.height, cellHeight))
		}
		
		// Animate the height change
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
			self.superview?.layoutIfNeeded()
		}
	}
	
	private func updateCurrencyInCells(_ currency: String) {
		for case let cell as ImprovedParticipantInputCell in tableView.visibleCells {
			cell.updateCurrency(currency)
		}
	}
	
	// MARK: - Public Methods
	
	func updateParticipants(_ participants: [ParticipantInput]) {
		participantsRelay.accept(participants)
	}
	
	func updateCurrency(_ currency: String) {
		currencyRelay.accept(currency)
	}
}

// MARK: - UITableViewDataSource

extension AddBillParticipantsView: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return participantsRelay.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: ImprovedParticipantInputCell.identifier, for: indexPath) as! ImprovedParticipantInputCell
		
		let participant = participantsRelay.value[indexPath.row]
		cell.configure(with: participant)
		cell.updateCurrency(currencyRelay.value)
		cell.delegate = self
		
		return cell
	}
}

// MARK: - ImprovedParticipantInputCellDelegate
extension AddBillParticipantsView: ImprovedParticipantInputCellDelegate {
	func participantCell(_ cell: ImprovedParticipantInputCell, didUpdateName name: String, email: String, amount: String) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		
		var participants = participantsRelay.value
		guard indexPath.row < participants.count else { return }
		participants[indexPath.row] = ParticipantInput(name: name, email: email, amount: amount)
		
		// Update without full reload to prevent keyboard dismissal
		participantsRelay.accept(participants)
	}
	
	func participantCellDidRequestRemoval(_ cell: ImprovedParticipantInputCell) {
		
		guard let indexPath = tableView.indexPath(for: cell) else {
			return
		}
		
		guard viewModel.participantsRelay.value.count > 1 else {
			let alert = UIAlertController(
				title: "Cannot Remove",
				message: "At least one participant is required.",
				preferredStyle: .alert
			)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			parentViewController()?.present(alert, animated: true)
			return
		}
		
		viewModel.removeParticipant(at: indexPath.row)
	}
	
	func participantCellDidRequestSelection(_ cell: ImprovedParticipantInputCell) {
		
		guard let indexPath = tableView.indexPath(for: cell) else {
			return
		}
		
		didSelectParticipants?(indexPath.row)
	}
}
