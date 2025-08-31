//
//  ImprovedParticipantInputCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift

protocol ImprovedParticipantInputCellDelegate: AnyObject {
	func participantCell(_ cell: ImprovedParticipantInputCell, didUpdateName name: String, email: String, amount: String)
	func participantCellDidRequestRemoval(_ cell: ImprovedParticipantInputCell)
	func participantCellDidRequestSelection(_ cell: ImprovedParticipantInputCell)
}

final class ImprovedParticipantInputCell: UITableViewCell {
	
	static let identifier = "ImprovedParticipantInputCell"
	
	// MARK: - Properties
	
	weak var delegate: ImprovedParticipantInputCellDelegate?
	private var disposeBag = DisposeBag()
	private var currentCurrency = "USD"
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var topRowStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = 12
		stack.alignment = .center
		stack.distribution = .fill
		return stack
	}()
	
	private lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Participant name"
		textField.font = .systemFont(ofSize: 16, weight: .medium) // HIG text size
		textField.borderStyle = .none
		textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		return textField
	}()
	
	private lazy var selectButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "person.circle"), for: .normal)
		button.tintColor = .systemBlue
		button.setContentHuggingPriority(.required, for: .horizontal)
		return button
	}()
	
	private lazy var removeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
		button.tintColor = .systemRed
		button.setContentHuggingPriority(.required, for: .horizontal)
		return button
	}()
	
	private lazy var emailTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Email (optional)"
		textField.font = .systemFont(ofSize: 14, weight: .regular) // Smaller for secondary info
		textField.textColor = .secondaryLabel
		textField.keyboardType = .emailAddress
		textField.autocapitalizationType = .none
		textField.borderStyle = .none
		return textField
	}()
	
	private lazy var amountTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Amount"
		textField.font = .systemFont(ofSize: 16, weight: .semibold)
		textField.textColor = .systemBlue
		textField.keyboardType = .decimalPad
		textField.textAlignment = .right
		textField.borderStyle = .none
		return textField
	}()
	
	private lazy var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .separator
		return view
	}()
	
	private lazy var bottomSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .separator
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
		
		// Add components to container
		containerView.addSubview(topRowStackView)
		containerView.addSubview(separatorView)
		containerView.addSubview(emailTextField)
		containerView.addSubview(bottomSeparatorView)
		containerView.addSubview(amountTextField)
		
		// Setup top row stack
		topRowStackView.addArrangedSubview(nameTextField)
		topRowStackView.addArrangedSubview(selectButton)
		topRowStackView.addArrangedSubview(removeButton)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(4) // Minimal cell spacing
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.greaterThanOrEqualTo(116) // Following HIG for minimum height
		}
		
		topRowStackView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(32) // HIG touch target
		}
		
		selectButton.snp.makeConstraints { make in
			make.width.height.equalTo(32) // HIG minimum touch target
		}
		
		removeButton.snp.makeConstraints { make in
			make.width.height.equalTo(32) // HIG minimum touch target
		}
		
		separatorView.snp.makeConstraints { make in
			make.top.equalTo(topRowStackView.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(0.5)
		}
		
		emailTextField.snp.makeConstraints { make in
			make.top.equalTo(separatorView.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(28) // Smaller height for secondary info
		}
		
		bottomSeparatorView.snp.makeConstraints { make in
			make.top.equalTo(emailTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(0.5)
		}
		
		amountTextField.snp.makeConstraints { make in
			make.top.equalTo(bottomSeparatorView.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-12)
			make.height.equalTo(32) // HIG touch target
		}
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
	
	private func formatCurrentAmount() {
		guard let currentText = amountTextField.text,
			  !currentText.isEmpty,
			  let value = Double(currentText.replacingOccurrences(of: ",", with: "")),
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
