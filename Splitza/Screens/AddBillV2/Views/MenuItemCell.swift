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
	private var currency: String = "IDR"
	
	// Closures instead of delegate
	var onTitleChanged: ((String) -> Void)?
	var onPriceChanged: ((Double) -> Void)?
	var onParticipantSelectionRequested: (() -> Void)?
	
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
	
	
	private lazy var participantsLabel: UILabel = {
		let label = UILabel()
		label.text = "Sharing with"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .systemBlue
		label.textAlignment = .left
		return label
	}()
	
	private lazy var participantsStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = 6 // Slightly increased spacing for better visibility
		stack.alignment = .center
		stack.distribution = .fill // Changed to fill for better control of element sizes
		return stack
	}()
	
	private lazy var addParticipantView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBlue.withAlphaComponent(0.15)
		view.layer.cornerRadius = 18 // Increased to match new participant size
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
		
		// Add shadow for consistency with participant views
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 0, height: 1)
		view.layer.shadowRadius = 2
		view.layer.shadowOpacity = 0.2
		
		// Make it tappable
		view.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addParticipantViewTapped))
		view.addGestureRecognizer(tapGesture)
		
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "plus.circle.fill")
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = .systemBlue
		
		view.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.height.equalTo(20) // Increased size
		}
		
		return view
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
	
	private lazy var participantsScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}()
	
	private func setupUI() {
		selectionStyle = .none
		backgroundColor = .clear
		
		contentView.addSubview(containerView)
		containerView.addSubview(titleTextField)
		containerView.addSubview(priceTextField)
		containerView.addSubview(participantsLabel)
		containerView.addSubview(participantsScrollView)
		
		participantsScrollView.addSubview(participantsStackView)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
		}
		
		titleTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.height.equalTo(24)
		}
		
		priceTextField.snp.makeConstraints { make in
			make.top.equalTo(titleTextField.snp.bottom).offset(8)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.height.equalTo(24)
		}
		
		participantsLabel.snp.makeConstraints { make in
			make.top.equalTo(priceTextField.snp.bottom).offset(12)
			make.leading.equalToSuperview().offset(16)
			make.height.equalTo(16)
		}
		
		participantsScrollView.snp.makeConstraints { make in
			make.top.equalTo(participantsLabel.snp.bottom).offset(6)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.height.equalTo(44) // Fixed height for scroll view
			make.bottom.equalToSuperview().offset(-12)
		}
		
		participantsStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.height.equalTo(participantsScrollView)
		}
		
		containerView.snp.makeConstraints { make in
			make.height.greaterThanOrEqualTo(100)
		}
	}
	
	private func setupActions() {
		titleTextField.addTarget(self, action: #selector(titleChanged), for: .editingDidEnd)
		priceTextField.addTarget(self, action: #selector(priceChanged), for: .editingDidEnd)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(participantsAreaTapped))
		participantsScrollView.addGestureRecognizer(tapGesture)
	}
	
	// MARK: - Configuration
	
	func configure(with menuItem: MenuItem, participants: [BillParticipant], currency: String) {
		self.menuItem = menuItem
		self.participants = participants
		self.currency = currency
		
		titleTextField.text = menuItem.title
		priceTextField.text = menuItem.price.formattedCurrency(currencyCode: currency)
		
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
	
	// MARK: - Private Methods
	
	private func updateParticipantsUI() {
		
		guard let menuItem = menuItem else {
			return
		}
		
		// Clear existing views
		participantsStackView.arrangedSubviews.forEach { view in
			participantsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		
		let assignedParticipants = participants.filter { participant in
			menuItem.participantAssignments[participant.id] != nil
		}
		
		// Update participants label to show count
		if assignedParticipants.isEmpty {
			participantsLabel.text = "Add participants"
		} else if assignedParticipants.count == 1 {
			participantsLabel.text = "1 participant"
		} else {
			participantsLabel.text = "\(assignedParticipants.count) participants"
		}
		
		// Always show assigned participant bubbles (if any) then a plus button to allow adding / editing
		for (index, participant) in assignedParticipants.enumerated() {
			let participantView = createParticipantView(participant, shares: menuItem.participantAssignments[participant.id] ?? 1)
			participantsStackView.addArrangedSubview(participantView)
		}
		
		// Create a spacer view to push addParticipantView to the right
		if assignedParticipants.isEmpty {
			// If no participants, just add the add button directly
			participantsStackView.addArrangedSubview(addParticipantView)
		} else {
			// If there are participants, add a spacer to push the add button to the right
			let spacerView = UIView()
			spacerView.backgroundColor = .clear
			participantsStackView.addArrangedSubview(spacerView)
			participantsStackView.addArrangedSubview(addParticipantView)
			
			// Make spacer take up available space
			spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		}
		
		// Fix size for add participant view
		addParticipantView.snp.remakeConstraints { make in
			make.width.height.equalTo(36)
		}
		
		layoutIfNeeded()
		
		// Remove previous constraints if they exist
		participantsStackView.snp.removeConstraints()
		
		// Recreate constraints - don't constrain width explicitly
		participantsStackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.leading.equalToSuperview()
			// Don't constrain trailing to allow content to determine width
			make.height.equalTo(participantsScrollView)
		}
		
		// Update layout
		setNeedsLayout()
		layoutIfNeeded()
		
		// Calculate and set the content size manually for scrolling
		let totalWidth = participantsStackView.systemLayoutSizeFitting(
			CGSize(width: UIView.layoutFittingCompressedSize.width, 
				  height: participantsScrollView.frame.height)
		).width
		
		// Ensure the content size is at least as wide as the scroll view
		participantsScrollView.contentSize = CGSize(
			width: max(totalWidth, participantsScrollView.frame.width),
			height: participantsScrollView.frame.height
		)
	}
	
	private func createParticipantView(_ participant: BillParticipant, shares: Int) -> UIView {
		// Create a fixed size container that won't stretch
		let containerWrapper = UIView()
		containerWrapper.translatesAutoresizingMaskIntoConstraints = false
		
		let containerView = UIView()
		containerView.backgroundColor = .yellow
		containerWrapper.addSubview(containerView)
		
		// Use a dynamic color based on participant's name hash for variety
		let colors: [UIColor] = [.systemBlue, .systemGreen, .systemIndigo, .systemOrange, .systemPurple, .systemTeal]
		let colorIndex = abs(participant.abbreviatedName.hash) % colors.count
		containerView.backgroundColor = colors[colorIndex]
		
		containerView.layer.cornerRadius = 16
		containerView.layer.borderWidth = 2
		containerView.layer.borderColor = UIColor.white.cgColor
		
		// Add shadow for depth
		containerView.layer.shadowColor = UIColor.black.cgColor
		containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
		containerView.layer.shadowRadius = 2
		containerView.layer.shadowOpacity = 0.2
		
		let label = UILabel()
		label.text = participant.abbreviatedName
		label.font = .systemFont(ofSize: 12, weight: .bold)
		label.textColor = .white
		label.textAlignment = .center
		
		containerView.addSubview(label)
		
		// Add share count if > 1
		if shares > 1 {
			let badgeView = UIView()
			badgeView.backgroundColor = .systemRed
			badgeView.layer.cornerRadius = 9
			
			let badgeLabel = UILabel()
			badgeLabel.text = "\(shares)"
			badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
			badgeLabel.textColor = .white
			badgeLabel.textAlignment = .center
			
			badgeView.addSubview(badgeLabel)
			containerView.addSubview(badgeView)
			
			badgeView.snp.makeConstraints { make in
				make.top.trailing.equalToSuperview().offset(-2)
				make.width.height.equalTo(18)
			}
			
			badgeLabel.snp.makeConstraints { make in
				make.center.equalToSuperview()
			}
		}
		
		// Set fixed size for the wrapper
		containerWrapper.snp.makeConstraints { make in
			make.width.height.equalTo(36)
		}
		
		// Fill the wrapper with the actual container
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
		return containerWrapper
	}
}
