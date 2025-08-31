//
//  ParticipantInputCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import RxSwift

protocol ParticipantInputCellDelegate: AnyObject {
	func participantCell(_ cell: ParticipantInputCell, didUpdateName name: String, email: String, amount: String)
	func participantCellDidRequestRemoval(_ cell: ParticipantInputCell)
	func participantCellDidRequestSelection(_ cell: ParticipantInputCell)
}

final class ParticipantInputCell: UITableViewCell {
	
	static let identifier = "ParticipantInputCell"
	
	// MARK: - Properties
	
	weak var delegate: ParticipantInputCellDelegate?
	private var disposeBag = DisposeBag()
	private var currentCurrency = "USD"
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		view.isUserInteractionEnabled = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Participant name"
		textField.font = .systemFont(ofSize: 16, weight: .medium)
		textField.borderStyle = .none
		textField.setContentHuggingPriority(.defaultLow, for: .vertical)
		textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var emailTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Email (optional)"
		textField.font = .systemFont(ofSize: 16, weight: .regular)
		textField.textColor = .label
		textField.keyboardType = .emailAddress
		textField.autocapitalizationType = .none
		textField.borderStyle = .none
		textField.setContentHuggingPriority(.defaultLow, for: .vertical)
		textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var amountTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Amount"
		textField.font = .systemFont(ofSize: 16, weight: .semibold) // Make amount field more prominent
		textField.textColor = .systemBlue // Highlight amount with blue color
		textField.keyboardType = .decimalPad
		textField.textAlignment = .right
		textField.borderStyle = .none
		textField.isUserInteractionEnabled = true
		textField.isEnabled = true
		textField.setContentHuggingPriority(.defaultLow, for: .vertical)
		textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var selectButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "person.circle"), for: .normal)
		button.tintColor = .systemBlue
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var removeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		button.tintColor = .systemRed
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .separator
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var secondSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .separator
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// MARK: - Initialization
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupBindings()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		disposeBag = DisposeBag()
		setupBindings()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		backgroundColor = .clear
		selectionStyle = .none
		
		contentView.addSubview(containerView)
		containerView.addSubview(nameTextField)
		containerView.addSubview(selectButton)
		containerView.addSubview(separatorView)
		containerView.addSubview(emailTextField)
		containerView.addSubview(secondSeparatorView)
		containerView.addSubview(amountTextField)
		containerView.addSubview(removeButton)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Container view
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150), // Increased minimum height
			
			// Name text field
			nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			nameTextField.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor, constant: -12),
			nameTextField.heightAnchor.constraint(equalToConstant: 44),
			
			// Select button
			selectButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			selectButton.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
			selectButton.widthAnchor.constraint(equalToConstant: 44),
			selectButton.heightAnchor.constraint(equalToConstant: 44),
			
			// Remove button
			removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			removeButton.widthAnchor.constraint(equalToConstant: 44),
			removeButton.heightAnchor.constraint(equalToConstant: 44),
			
			// First separator
			separatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 6),
			separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			separatorView.heightAnchor.constraint(equalToConstant: 0.5),
			
			// Email text field
			emailTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 6),
			emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			emailTextField.heightAnchor.constraint(equalToConstant: 44),
			
			// Second separator
			secondSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 6),
			secondSeparatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			secondSeparatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			secondSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
			
			// Amount text field - ensuring proper height and spacing
			amountTextField.topAnchor.constraint(equalTo: secondSeparatorView.bottomAnchor, constant: 6),
			amountTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			amountTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			amountTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
			amountTextField.heightAnchor.constraint(equalToConstant: 44)
		])
	}
	
	private func setupBindings() {
		// Text field changes
		nameTextField.rx.text.orEmpty
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] _ in
				self?.notifyDelegate()
			})
			.disposed(by: disposeBag)
		
		emailTextField.rx.text.orEmpty
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] _ in
				self?.notifyDelegate()
			})
			.disposed(by: disposeBag)
		
		amountTextField.rx.text.orEmpty
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] _ in
				self?.notifyDelegate()
			})
			.disposed(by: disposeBag)
		
		// Add focus highlighting for amount field
		amountTextField.rx.controlEvent(.editingDidBegin)
			.subscribe(onNext: { [weak self] in
				UIView.animate(withDuration: 0.2) {
					self?.amountTextField.backgroundColor = .systemBlue.withAlphaComponent(0.1)
				}
			})
			.disposed(by: disposeBag)
		
		amountTextField.rx.controlEvent(.editingDidEnd)
			.subscribe(onNext: { [weak self] in
				UIView.animate(withDuration: 0.2) {
					self?.amountTextField.backgroundColor = .clear
				}
				// Format the amount when editing ends
				self?.formatCurrentAmount()
			})
			.disposed(by: disposeBag)
		
		// Select button
		selectButton.rx.tap
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.delegate?.participantCellDidRequestSelection(self)
			})
			.disposed(by: disposeBag)
		
		// Remove button
		removeButton.rx.tap
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.delegate?.participantCellDidRequestRemoval(self)
			})
			.disposed(by: disposeBag)
	}
	
	private func notifyDelegate() {
		let name = nameTextField.text ?? ""
		let email = emailTextField.text ?? ""
		let amount = amountTextField.text ?? ""
		delegate?.participantCell(self, didUpdateName: name, email: email, amount: amount)
	}
	
	// MARK: - Configuration
	
	func configure(with participant: ParticipantInput) {
		nameTextField.text = participant.name
		emailTextField.text = participant.email
		amountTextField.text = participant.amount
	}
	
	func updateCurrency(_ currency: String) {
		currentCurrency = currency
		amountTextField.placeholder = "Amount (\(currency))"
	}
	
	func formatAmount(_ amount: String, currency: String) -> String {
		guard let value = Double(amount), value > 0 else { return amount }
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currency
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		
		return formatter.string(from: NSNumber(value: value))?.replacingOccurrences(of: formatter.currencySymbol, with: "").trimmingCharacters(in: .whitespaces) ?? amount
	}
	
	private func formatCurrentAmount() {
		guard let currentText = amountTextField.text,
			  !currentText.isEmpty,
			  let value = Double(currentText),
			  value > 0 else { return }
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		formatter.groupingSeparator = ","
		formatter.usesGroupingSeparator = true
		
		if let formattedText = formatter.string(from: NSNumber(value: value)) {
			amountTextField.text = formattedText
			notifyDelegate()
		}
	}
}
