//
//  MenuItemCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class MenuItemCell: UITableViewCell {
	
	static let identifier = "MenuItemCell"
	
	// MARK: - Properties
	private var disposeBag = DisposeBag()
	
	private var menuItem: MenuItem?
	private var participants: [BillParticipant] = []
	
	// Closures instead of delegate
	var onTitleChanged: ((String) -> Void)?
	var onPriceChanged: ((Double) -> Void)?
	var onParticipantSelectionRequested: (() -> Void)?
	var onRemovalRequested: (() -> Void)?
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var titleTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Menu item name"
		textField.font = .systemFont(ofSize: 16, weight: .medium)
		textField.textColor = .label
		textField.borderStyle = .none
		textField.returnKeyType = .next
		return textField
	}()
	
	private lazy var priceTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "0.00"
		textField.font = .systemFont(ofSize: 14, weight: .regular)
		textField.textColor = .label
		textField.keyboardType = .decimalPad
		textField.borderStyle = .none
		textField.textAlignment = .left
		return textField
	}()
	
	private lazy var currencyLabel: UILabel = {
		let label = UILabel()
		label.text = "$"
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = .label
		return label
	}()
	
	private lazy var participantsButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = .clear
		button.layer.cornerRadius = 8
		return button
	}()
	
	private lazy var participantsStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = -4 // Overlapping effect
		stack.alignment = .center
		stack.distribution = .fill
		return stack
	}()
	
	private lazy var addParticipantView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray5
		view.layer.cornerRadius = 16
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.systemGray4.cgColor
		
		// Make it tappable
		view.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addParticipantViewTapped))
		view.addGestureRecognizer(tapGesture)
		
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "plus")
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = .systemGray2
		
		view.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.height.equalTo(16)
		}
		
		return view
	}()
	
	private lazy var removeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		button.tintColor = .systemRed
		button.backgroundColor = .white
		button.layer.cornerRadius = 12
		return button
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
		disposeBag = DisposeBag()
		menuItem = nil
		participants = []
		
		// Clear participants stack view
		participantsStackView.arrangedSubviews.forEach { view in
			participantsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		selectionStyle = .none
		backgroundColor = .clear
		
		contentView.addSubview(containerView)
		containerView.addSubview(titleTextField)
		containerView.addSubview(currencyLabel)
		containerView.addSubview(priceTextField)
		containerView.addSubview(participantsButton)
		containerView.addSubview(removeButton)
		
		participantsButton.addSubview(participantsStackView)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
			make.height.greaterThanOrEqualTo(80)
		}
		
		titleTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalTo(removeButton.snp.leading).offset(-8)
			make.height.equalTo(24)
		}
		
		currencyLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.bottom.equalToSuperview().offset(-12)
			make.width.equalTo(20)
		}
		
		priceTextField.snp.makeConstraints { make in
			make.leading.equalTo(currencyLabel.snp.trailing).offset(4)
			make.centerY.equalTo(currencyLabel)
			make.width.equalTo(80)
			make.height.equalTo(24)
		}
		
		participantsButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-16)
			make.centerY.equalToSuperview()
			make.height.equalTo(40)
			make.width.greaterThanOrEqualTo(40)
		}
		
		participantsStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(4)
		}
		
		removeButton.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.trailing.equalToSuperview().offset(-8)
			make.width.height.equalTo(24)
		}
	}
	
	private func setupActions() {
		titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingDidEnd)
		priceTextField.addTarget(self, action: #selector(priceChanged), for: .editingDidEnd)
		participantsButton.addTarget(self, action: #selector(participantsButtonTapped), for: .touchUpInside)
		removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
	}
	
	// MARK: - Configuration
	
	func configure(with menuItem: MenuItem, participants: [BillParticipant], currency: String) {
		self.menuItem = menuItem
		self.participants = participants
		
		titleTextField.text = menuItem.title
		priceTextField.text = menuItem.price > 0 ? String(format: "%.2f", menuItem.price) : ""
		currencyLabel.text = getCurrencySymbol(for: currency)
		
		updateParticipantsUI()
	}
	
	// MARK: - Actions
	
	@objc private func titleChanged() {
		guard let title = titleTextField.text else { return }
		onTitleChanged?(title)
	}
	
	@objc private func priceChanged() {
		guard let priceText = priceTextField.text,
			  let price = Double(priceText) else { return }
		onPriceChanged?(price)
	}
	
	@objc private func participantsButtonTapped() {
		onParticipantSelectionRequested?()
	}
	
	@objc private func removeButtonTapped() {
		onRemovalRequested?()
	}
	
	@objc private func addParticipantViewTapped() {
		onParticipantSelectionRequested?()
	}
	
	// MARK: - Private Methods
	
	private func updateParticipantsUI() {
		guard let menuItem = menuItem else { return }
		
		// Clear existing views
		participantsStackView.arrangedSubviews.forEach { view in
			participantsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		
		let assignedParticipants = participants.filter { participant in
			menuItem.participantAssignments[participant.id] != nil
		}
		
		if assignedParticipants.isEmpty {
			// Show add button
			participantsStackView.addArrangedSubview(addParticipantView)
			addParticipantView.snp.makeConstraints { make in
				make.width.height.equalTo(32)
			}
		} else {
			// Show assigned participants
			for (index, participant) in assignedParticipants.enumerated() {
				let participantView = createParticipantView(participant, shares: menuItem.participantAssignments[participant.id] ?? 1, isLast: index == assignedParticipants.count - 1)
				participantsStackView.addArrangedSubview(participantView)
			}
		}
	}
	
	private func createParticipantView(_ participant: BillParticipant, shares: Int, isLast: Bool) -> UIView {
		let containerView = UIView()
		containerView.backgroundColor = .systemBlue
		containerView.layer.cornerRadius = 16
		containerView.layer.borderWidth = 2
		containerView.layer.borderColor = UIColor.white.cgColor
		
		// Add shadow for depth
		containerView.layer.shadowColor = UIColor.black.cgColor
		containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
		containerView.layer.shadowRadius = 2
		containerView.layer.shadowOpacity = 0.1
		
		let label = UILabel()
		label.text = participant.abbreviatedName
		label.font = .systemFont(ofSize: 10, weight: .bold)
		label.textColor = .white
		label.textAlignment = .center
		
		containerView.addSubview(label)
		
		// Add share count if > 1
		if shares > 1 {
			let badgeView = UIView()
			badgeView.backgroundColor = .systemRed
			badgeView.layer.cornerRadius = 8
			
			let badgeLabel = UILabel()
			badgeLabel.text = "\(shares)"
			badgeLabel.font = .systemFont(ofSize: 8, weight: .bold)
			badgeLabel.textColor = .white
			badgeLabel.textAlignment = .center
			
			badgeView.addSubview(badgeLabel)
			containerView.addSubview(badgeView)
			
			badgeView.snp.makeConstraints { make in
				make.top.trailing.equalToSuperview().offset(-2)
				make.width.height.equalTo(16)
			}
			
			badgeLabel.snp.makeConstraints { make in
				make.center.equalToSuperview()
			}
		}
		
		// Constraints
		containerView.snp.makeConstraints { make in
			make.width.height.equalTo(32)
		}
		
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
		// Bring to front if it's the last one
		if isLast {
			containerView.layer.zPosition = 100
		}
		
		return containerView
	}
	
	private func getCurrencySymbol(for currency: String) -> String {
		switch currency {
		case "USD": return "$"
		case "EUR": return "€"
		case "GBP": return "£"
		case "JPY": return "¥"
		case "IDR": return "Rp"
		default: return currency
		}
	}
}
