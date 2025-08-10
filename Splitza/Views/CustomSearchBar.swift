//
//  CustomSearchBar.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

protocol CustomSearchBarDelegate: AnyObject {
	func searchBar(_ searchBar: CustomSearchBar, textDidChange searchText: String)
	func searchBarDidBeginEditing(_ searchBar: CustomSearchBar)
	func searchBarDidEndEditing(_ searchBar: CustomSearchBar)
}

final class CustomSearchBar: UIView {
	
	weak var delegate: CustomSearchBarDelegate?
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray6
		view.layer.cornerRadius = 16
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var searchIconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "magnifyingglass")
		imageView.tintColor = .systemGray
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private lazy var textField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Search split bills..."
		textField.font = .systemFont(ofSize: 16, weight: .medium)
		textField.textColor = .label
		textField.backgroundColor = .clear
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.delegate = self
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var clearButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		button.tintColor = .systemGray
		button.alpha = 0
		button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Properties
	
	var text: String {
		return textField.text ?? ""
	}
	
	var placeholder: String? {
		get { textField.placeholder }
		set { textField.placeholder = newValue }
	}
	
	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		backgroundColor = .clear
		
		addSubview(containerView)
		containerView.addSubview(searchIconImageView)
		containerView.addSubview(textField)
		containerView.addSubview(clearButton)
		
		setupConstraints()
		setupGestureRecognizers()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Container view
			containerView.topAnchor.constraint(equalTo: topAnchor),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
			containerView.heightAnchor.constraint(equalToConstant: 44),
			
			// Search icon
			searchIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
			searchIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
			searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
			
			// Text field
			textField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
			textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
			textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			
			// Clear button
			clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
			clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			clearButton.widthAnchor.constraint(equalToConstant: 20),
			clearButton.heightAnchor.constraint(equalToConstant: 20)
		])
	}
	
	private func setupGestureRecognizers() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
		containerView.addGestureRecognizer(tapGesture)
	}
	
	// MARK: - Actions
	
	@objc private func containerTapped() {
		textField.becomeFirstResponder()
	}
	
	@objc private func textFieldDidChange() {
		updateClearButtonVisibility()
		delegate?.searchBar(self, textDidChange: text)
	}
	
	@objc private func clearButtonTapped() {
		textField.text = ""
		updateClearButtonVisibility()
		delegate?.searchBar(self, textDidChange: "")
		
		// Add haptic feedback
		let impactFeedback = UIImpactFeedbackGenerator(style: .light)
		impactFeedback.impactOccurred()
	}
	
	// MARK: - Private Methods
	
	private func updateClearButtonVisibility() {
		let shouldShowClearButton = !text.isEmpty
		
		UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState]) {
			self.clearButton.alpha = shouldShowClearButton ? 1 : 0
			self.clearButton.transform = shouldShowClearButton ? .identity : CGAffineTransform(scaleX: 0.8, y: 0.8)
		}
	}
	
	private func animateContainerHighlight(_ highlighted: Bool) {
		UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
			self.containerView.backgroundColor = highlighted ? .systemGray5 : .systemGray6
			self.searchIconImageView.tintColor = highlighted ? .systemBlue : .systemGray
		}
	}
	
	// MARK: - Public Methods
	
	override func becomeFirstResponder() -> Bool {
		return textField.becomeFirstResponder()
	}
	
	override func resignFirstResponder() -> Bool {
		return textField.resignFirstResponder()
	}
	
	func setText(_ text: String) {
		textField.text = text
		updateClearButtonVisibility()
	}
}

// MARK: - UITextFieldDelegate

extension CustomSearchBar: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		animateContainerHighlight(true)
		delegate?.searchBarDidBeginEditing(self)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		animateContainerHighlight(false)
		delegate?.searchBarDidEndEditing(self)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
