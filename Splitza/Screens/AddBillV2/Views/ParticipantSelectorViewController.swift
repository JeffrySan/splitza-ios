//
//  ParticipantSelectorViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

protocol ParticipantSelectorDelegate: AnyObject {
	func participantSelector(_ controller: ParticipantSelectorViewController, didUpdateAssignments assignments: [String: Int])
}

final class ParticipantSelectorViewController: UIViewController {
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	weak var delegate: ParticipantSelectorDelegate?
	
	let participants: [BillParticipant]
	let menuItem: MenuItem
	var participantAssignments: [String: Int]
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGroupedBackground
		view.layer.cornerRadius = 16
		view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		return view
	}()
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}()
	
	private lazy var dragIndicator: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray3
		view.layer.cornerRadius = 2
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var doneButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Done", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		button.setTitleColor(.systemBlue, for: .normal)
		return button
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .clear
		tableView.register(ParticipantSelectorCell.self, forCellReuseIdentifier: ParticipantSelectorCell.identifier)
		tableView.showsVerticalScrollIndicator = false
		return tableView
	}()
	
	// MARK: - Initialization
	
	init(participants: [BillParticipant], menuItem: MenuItem) {
		self.participants = participants
		self.menuItem = menuItem
		self.participantAssignments = menuItem.participantAssignments
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
		updateUI()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		view.addSubview(containerView)
		containerView.addSubview(headerView)
		containerView.addSubview(tableView)
		
		headerView.addSubview(dragIndicator)
		headerView.addSubview(titleLabel)
		headerView.addSubview(subtitleLabel)
		headerView.addSubview(doneButton)
		
		setupConstraints()
		setupTableView()
		setupActions()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalToSuperview()
			make.height.equalTo(500)
		}
		
		headerView.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview()
			make.height.equalTo(80)
		}
		
		dragIndicator.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.centerX.equalToSuperview()
			make.width.equalTo(36)
			make.height.equalTo(4)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(20)
			make.top.equalToSuperview().offset(24)
		}
		
		subtitleLabel.snp.makeConstraints { make in
			make.leading.equalTo(titleLabel)
			make.top.equalTo(titleLabel.snp.bottom).offset(4)
		}
		
		doneButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-20)
			make.centerY.equalTo(titleLabel)
		}
		
		tableView.snp.makeConstraints { make in
			make.top.equalTo(headerView.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
		}
	}
	
	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	private func setupActions() {
		doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
		
		// Add pan gesture for dismissal
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
		containerView.addGestureRecognizer(panGesture)
	}
	
	private func setupBindings() {
		// Any reactive bindings if needed
	}
	
	// MARK: - Actions
	
	@objc private func doneTapped() {
		delegate?.participantSelector(self, didUpdateAssignments: participantAssignments)
		dismiss(animated: true)
	}
	
	@objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: view)
		
		switch gesture.state {
		case .changed:
			if translation.y > 0 {
				containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
			}
		case .ended:
			let velocity = gesture.velocity(in: view)
			if translation.y > 100 || velocity.y > 500 {
				dismiss(animated: true)
			} else {
				UIView.animate(withDuration: 0.3) {
					self.containerView.transform = .identity
				}
			}
		default:
			break
		}
	}
	
	// MARK: - Private Methods
	
	private func updateUI() {
		titleLabel.text = "Who's sharing?"
		subtitleLabel.text = "\(menuItem.title) • $\(String(format: "%.2f", menuItem.price))"
	}
	
	private func updateParticipantShares(_ participantId: String, shares: Int) {
		if shares > 0 {
			participantAssignments[participantId] = shares
		} else {
			participantAssignments.removeValue(forKey: participantId)
		}
		
		// Reload the affected row
		if let index = participants.firstIndex(where: { $0.id == participantId }) {
			let indexPath = IndexPath(row: index, section: 0)
			tableView.reloadRows(at: [indexPath], with: .none)
		}
	}
}

// MARK: - UITableViewDataSource

extension ParticipantSelectorViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return participants.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantSelectorCell.identifier, for: indexPath) as! ParticipantSelectorCell
		
		let participant = participants[indexPath.row]
		let shares = participantAssignments[participant.id] ?? 0
		
		cell.configure(with: participant, shares: shares)
		cell.delegate = self
		
		return cell
	}
}

// MARK: - UITableViewDelegate

extension ParticipantSelectorViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
}

// MARK: - ParticipantSelectorCellDelegate

extension ParticipantSelectorViewController: ParticipantSelectorCellDelegate {
	func participantSelectorCell(_ cell: ParticipantSelectorCell, didChangeShares shares: Int, for participantId: String) {
		updateParticipantShares(participantId, shares: shares)
	}
}
