//
//  ParticipantSelectorCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit
import SnapKit

protocol ParticipantSelectorCellDelegate: AnyObject {
	func participantSelectorCell(_ cell: ParticipantSelectorCell, didChangeShares shares: Int, for participantId: String)
}

final class ParticipantSelectorCell: UITableViewCell {
	
	static let identifier = "ParticipantSelectorCell"
	
	// MARK: - Properties
	weak var delegate: ParticipantSelectorCellDelegate?
	private var participant: BillParticipant?
	private var currentShares: Int = 0
	
	// MARK: - UI Components
	
	private lazy var avatarView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBlue
		view.layer.cornerRadius = 20
		return view
	}()
	
	private lazy var avatarLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .bold)
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()
	
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .label
		return label
	}()
	
	private lazy var emailLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var minusButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		button.tintColor = .systemRed
		button.backgroundColor = .clear
		return button
	}()
	
	private lazy var shareCountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.textColor = .label
		label.textAlignment = .center
		label.backgroundColor = .tertiarySystemGroupedBackground
		label.layer.cornerRadius = 8
		label.clipsToBounds = true
		return label
	}()
	
	private lazy var plusButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
		button.tintColor = .systemGreen
		button.backgroundColor = .clear
		return button
	}()
	
	private lazy var controlsStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = 12
		stack.alignment = .center
		stack.distribution = .fill
		return stack
	}()
	
	// MARK: - Initialization
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		participant = nil
		currentShares = 0
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		selectionStyle = .none
		backgroundColor = .clear
		
		contentView.addSubview(avatarView)
		avatarView.addSubview(avatarLabel)
		contentView.addSubview(nameLabel)
		contentView.addSubview(emailLabel)
		contentView.addSubview(controlsStackView)
		
		controlsStackView.addArrangedSubview(minusButton)
		controlsStackView.addArrangedSubview(shareCountLabel)
		controlsStackView.addArrangedSubview(plusButton)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		avatarView.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(20)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(40)
		}
		
		avatarLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
		nameLabel.snp.makeConstraints { make in
			make.leading.equalTo(avatarView.snp.trailing).offset(12)
			make.top.equalToSuperview().offset(12)
			make.trailing.lessThanOrEqualTo(controlsStackView.snp.leading).offset(-12)
		}
		
		emailLabel.snp.makeConstraints { make in
			make.leading.equalTo(nameLabel)
			make.top.equalTo(nameLabel.snp.bottom).offset(2)
			make.trailing.lessThanOrEqualTo(controlsStackView.snp.leading).offset(-12)
		}
		
		controlsStackView.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-20)
			make.centerY.equalToSuperview()
		}
		
		minusButton.snp.makeConstraints { make in
			make.width.height.equalTo(32)
		}
		
		shareCountLabel.snp.makeConstraints { make in
			make.width.equalTo(40)
			make.height.equalTo(32)
		}
		
		plusButton.snp.makeConstraints { make in
			make.width.height.equalTo(32)
		}
	}
	
	private func setupActions() {
		minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
		plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
	}
	
	// MARK: - Configuration
	
	func configure(with participant: BillParticipant, shares: Int) {
		self.participant = participant
		self.currentShares = shares
		
		avatarLabel.text = participant.abbreviatedName
		nameLabel.text = participant.name
		emailLabel.text = participant.email.isEmpty ? "No email" : participant.email
		emailLabel.isHidden = participant.email.isEmpty
		
		updateSharesUI()
	}
	
	// MARK: - Actions
	
	@objc private func minusButtonTapped() {
		guard currentShares > 0 else { return }
		currentShares -= 1
		updateSharesUI()
		notifyDelegate()
		
		// Haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .light)
		impactFeedback.impactOccurred()
	}
	
	@objc private func plusButtonTapped() {
		currentShares += 1
		updateSharesUI()
		notifyDelegate()
		
		// Haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .light)
		impactFeedback.impactOccurred()
	}
	
	// MARK: - Private Methods
	
	private func updateSharesUI() {
		shareCountLabel.text = "\(currentShares)"
		
		// Update visual state based on shares
		let isActive = currentShares > 0
		
		avatarView.backgroundColor = isActive ? .systemBlue : .systemGray4
		shareCountLabel.backgroundColor = isActive ? .systemBlue.withAlphaComponent(0.1) : .tertiarySystemGroupedBackground
		shareCountLabel.textColor = isActive ? .systemBlue : .label
		
		minusButton.alpha = currentShares > 0 ? 1.0 : 0.3
		minusButton.isEnabled = currentShares > 0
		
		// Animate the changes
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
			self.layoutIfNeeded()
		}
	}
	
	private func notifyDelegate() {
		guard let participant = participant else { return }
		delegate?.participantSelectorCell(self, didChangeShares: currentShares, for: participant.id)
	}
}
