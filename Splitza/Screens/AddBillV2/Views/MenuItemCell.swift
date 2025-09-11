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
	
	var onTitleChanged: ((String) -> Void)?
	var onPriceChanged: ((Double) -> Void)?
	var onParticipantSelectionRequested: (() -> Void)?
	
	// MARK: - UI Components
	private let containerView = UIView()
	private let titleTextField = UITextField()
	private let priceTextField = UITextField()
	private let participantsStackView = UIStackView()
	private let participantsScrollView = UIScrollView()
	private let checkboxButton = CheckboxButton()
	
	// MARK: - Properties
	private var disposeBag = DisposeBag()
	private var menuItem: MenuItem!
	private var participants: [BillParticipant] = []
	private var currency: String = "USD"
	
	private var assignedParticipants: [BillParticipant] {
		return participants.filter { participant in
			menuItem.participantAssignments[participant.id] != nil
		}
	}
	
	// MARK: - Initialization
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		configureContainerView()
		configureTitleTextField()
		configurePriceTextField()
		configureParticipantsStackView()
		configureParticipantsScrollView()
		
		configureViewHierarchy()
		
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: - View Lifecycle
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		setupActions()
	}

	// MARK: - Setup Methods
	private func configureContainerView() {
		containerView.backgroundColor = .secondarySystemGroupedBackground
		containerView.layer.cornerRadius = 12
		containerView.layer.borderWidth = 1
		containerView.layer.borderColor = UIColor.separator.cgColor
	}
	
	private func configureTitleTextField() {
		titleTextField.placeholder = "Menu item name"
		titleTextField.font = .systemFont(ofSize: 16, weight: .medium)
		titleTextField.textColor = .label
		titleTextField.borderStyle = .none
		titleTextField.returnKeyType = .next
	}
	
	private func configurePriceTextField() {
		priceTextField.placeholder = "0.00"
		priceTextField.font = .systemFont(ofSize: 14, weight: .regular)
		priceTextField.textColor = .label
		priceTextField.keyboardType = .decimalPad
		priceTextField.borderStyle = .none
		priceTextField.textAlignment = .left
	}
	
	private func configureParticipantsStackView() {
		participantsStackView.axis = .horizontal
		participantsStackView.spacing = 6
		participantsStackView.alignment = .center
		participantsStackView.distribution = .fill
	}
	
	private func configureParticipantsScrollView() {
		participantsScrollView.showsHorizontalScrollIndicator = false
		participantsScrollView.showsVerticalScrollIndicator = false
	}

	private func configureViewHierarchy() {
		
		selectionStyle = .none
		backgroundColor = .clear
		
		contentView.addSubview(containerView)
		
		containerView.addSubview(titleTextField)
		containerView.addSubview(priceTextField)
		containerView.addSubview(participantsScrollView)
		containerView.addSubview(checkboxButton)
		
		participantsScrollView.addSubview(participantsStackView)
	}

	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
		}

		titleTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
		}

		priceTextField.snp.makeConstraints { make in
			make.top.equalTo(titleTextField.snp.bottom).offset(4)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
		}
		
		checkboxButton.snp.makeConstraints { make in
			make.top.equalTo(priceTextField.snp.top).offset(-2-14)
			make.trailing.equalToSuperview().offset(-16)
			make.width.height.equalTo(28)
		}
		
		participantsScrollView.snp.makeConstraints { make in
			make.top.equalTo(priceTextField.snp.bottom).offset(6)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.height.equalTo(0)
			make.bottom.equalToSuperview().offset(-8)
		}
		
		participantsStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.height.equalTo(0)
		}
	}
	
	private func setupActions() {
		titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingDidEnd)
		priceTextField.addTarget(self, action: #selector(priceChanged), for: .editingDidEnd)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(participantsAreaTapped))
		participantsScrollView.addGestureRecognizer(tapGesture)
		
		checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
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
	// MARK: - Configuration
	
	func configure(with menuItem: MenuItem, participants: [BillParticipant], currency: String) {
		self.menuItem = menuItem
		self.participants = participants
		self.currency = currency
		
		titleTextField.text = menuItem.title
		priceTextField.text = menuItem.price.formattedCurrency(currencyCode: currency)
		checkboxButton.isSelected = !menuItem.assignedParticipantIds.isEmpty
		
		updateParticipantsUI()
	}
	
	// MARK: - Actions
	
	@objc private func titleChanged() {
		guard let title = titleTextField.text else {
			return
		}
		
		onTitleChanged?(title)
	}
	
	@objc private func priceChanged() {
		guard let priceText = priceTextField.text,
			  let price = Double(priceText) else {
			return
		}
		
		priceTextField.text = price.formattedCurrency(currencyCode: currency)
		onPriceChanged?(price)
	}
	
	@objc private func participantsAreaTapped() {
		onParticipantSelectionRequested?()
	}
	
	@objc private func addParticipantViewTapped() {
		onParticipantSelectionRequested?()
	}
	
	@objc private func checkboxTapped() {
		checkboxButton.isSelected.toggle()
		// You can add logic here to update participant assignment if needed
	}
	// MARK: - Private Methods
	
	private func updateParticipantsUI() {
		
		guard let menuItem = menuItem else {
			return
		}
		
		clearExistingStackViews()
		
		let localAssignedParticipants = assignedParticipants
		
		for participant in localAssignedParticipants {
			// let shares = (menuItem.participantAssignments[participant.id] ?? 1)
			let participantView = ParticipantViewConstructor.create(
				selectedParticipantTag: -1,
				labelName: participant.abbreviatedName,
				index: -1
			)
			participantsStackView.addArrangedSubview(participantView)
		}
		
		participantsStackView.snp.updateConstraints { make in
			make.height.equalTo(localAssignedParticipants.isEmpty ? 0 : 44)
		}
	}
	
	private func clearExistingStackViews() {
		participantsStackView.arrangedSubviews.forEach { view in
			participantsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
	}
}
