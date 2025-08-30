//
//  ParticipantInputCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import RxSwift

protocol ParticipantInputCellDelegate: AnyObject {
	func participantCell(_ cell: ParticipantInputCell, didUpdateName name: String, email: String)
	func participantCellDidRequestRemoval(_ cell: ParticipantInputCell)
}

final class ParticipantInputCell: UITableViewCell {
	
	static let identifier = "ParticipantInputCell"
	
	// MARK: - Properties
	
	weak var delegate: ParticipantInputCellDelegate?
	private var disposeBag = DisposeBag()
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Participant name"
		textField.font = .systemFont(ofSize: 16, weight: .medium)
		textField.borderStyle = .none
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var emailTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Email (optional)"
		textField.font = .systemFont(ofSize: 14, weight: .regular)
		textField.textColor = .secondaryLabel
		textField.keyboardType = .emailAddress
		textField.autocapitalizationType = .none
		textField.borderStyle = .none
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
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
		containerView.addSubview(separatorView)
		containerView.addSubview(emailTextField)
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
			
			// Name text field
			nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			nameTextField.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -12),
			nameTextField.heightAnchor.constraint(equalToConstant: 44),
			
			// Remove button
			removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			removeButton.widthAnchor.constraint(equalToConstant: 44),
			removeButton.heightAnchor.constraint(equalToConstant: 44),
			
			// Separator
			separatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
			separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			separatorView.heightAnchor.constraint(equalToConstant: 0.5),
			
			// Email text field
			emailTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
			emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			emailTextField.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -12),
			emailTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
			emailTextField.heightAnchor.constraint(equalToConstant: 44)
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
		delegate?.participantCell(self, didUpdateName: name, email: email)
	}
	
	// MARK: - Configuration
	
	func configure(with participant: ParticipantInput) {
		nameTextField.text = participant.name
		emailTextField.text = participant.email
	}
}
