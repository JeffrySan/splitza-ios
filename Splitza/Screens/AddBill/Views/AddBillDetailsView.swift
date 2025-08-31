//
//  AddBillDetailsView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillDetailsView: UIView {
	
	// MARK: - Properties
	
	private let disposeBag = DisposeBag()
	
	// Observables
	let titleRelay = BehaviorRelay<String>(value: "")
	let locationRelay = BehaviorRelay<String>(value: "")
	let descriptionRelay = BehaviorRelay<String>(value: "")
	let currencyRelay = BehaviorRelay<String>(value: "USD")
	
	var onCurrencySelection: (() -> Void)?
	
	private let currencies = [
		("USD", "US Dollar"),
		("EUR", "Euro"),
		("GBP", "British Pound"),
		("JPY", "Japanese Yen"),
		("AUD", "Australian Dollar"),
		("CAD", "Canadian Dollar"),
		("CHF", "Swiss Franc"),
		("CNY", "Chinese Yuan"),
		("SEK", "Swedish Krona"),
		("NZD", "New Zealand Dollar"),
		("MXN", "Mexican Peso"),
		("SGD", "Singapore Dollar"),
		("HKD", "Hong Kong Dollar"),
		("NOK", "Norwegian Krone"),
		("KRW", "South Korean Won"),
		("TRY", "Turkish Lira"),
		("RUB", "Russian Ruble"),
		("INR", "Indian Rupee"),
		("BRL", "Brazilian Real"),
		("ZAR", "South African Rand"),
		("IDR", "Indonesian Rupiah"),
		("MYR", "Malaysian Ringgit"),
		("THB", "Thai Baht"),
		("PLN", "Polish Zloty"),
		("CZK", "Czech Koruna")
	]
	
	// MARK: - UI Components
	
	private lazy var stackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 16
		stack.distribution = .fillEqually
		return stack
	}()
	
	lazy var titleTextField: UITextField = {
		let textField = createTextField(placeholder: "Bill title", returnKeyType: .next)
		return textField
	}()
	
	lazy var currencyButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("USD", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.backgroundColor = .tertiarySystemGroupedBackground
		button.setTitleColor(.label, for: .normal)
		button.layer.cornerRadius = 10
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.separator.cgColor
		button.contentHorizontalAlignment = .left
		button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		
		// Add dropdown arrow
		let arrowImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
		button.setImage(arrowImage, for: .normal)
		button.tintColor = .secondaryLabel
		button.semanticContentAttribute = .forceRightToLeft
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
		
		return button
	}()
	
	lazy var locationTextField: UITextField = {
		let textField = createTextField(placeholder: "Location (optional)", returnKeyType: .next)
		return textField
	}()
	
	lazy var descriptionTextField: UITextField = {
		let textField = createTextField(placeholder: "Description (optional)", returnKeyType: .done)
		return textField
	}()
	
	// MARK: - Initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupBindings()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		addSubview(stackView)
		
		stackView.addArrangedSubview(titleTextField)
		stackView.addArrangedSubview(currencyButton)
		stackView.addArrangedSubview(locationTextField)
		stackView.addArrangedSubview(descriptionTextField)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		// Set consistent height for all elements following HIG
		[titleTextField, currencyButton, locationTextField, descriptionTextField].forEach { view in
			view.snp.makeConstraints { make in
				make.height.equalTo(44) // HIG minimum touch target
			}
		}
	}
	
	private func setupBindings() {
		titleTextField.rx.text.orEmpty
			.bind(to: titleRelay)
			.disposed(by: disposeBag)
		
		locationTextField.rx.text.orEmpty
			.bind(to: locationRelay)
			.disposed(by: disposeBag)
		
		descriptionTextField.rx.text.orEmpty
			.bind(to: descriptionRelay)
			.disposed(by: disposeBag)
		
		currencyRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] currency in
				self?.currencyButton.setTitle(currency, for: .normal)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupActions() {
		currencyButton.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
	}
	
	@objc private func currencyButtonTapped() {
		showCurrencyPicker()
	}
	
	// MARK: - Private Methods
	
	private func createTextField(placeholder: String, returnKeyType: UIReturnKeyType) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.borderStyle = .roundedRect
		textField.backgroundColor = .tertiarySystemGroupedBackground
		textField.layer.borderWidth = 1
		textField.layer.borderColor = UIColor.separator.cgColor
		textField.layer.cornerRadius = 10
		textField.returnKeyType = returnKeyType
		textField.font = .systemFont(ofSize: 16, weight: .regular) // Consistent with HIG
		return textField
	}
	
	private func showCurrencyPicker() {
		guard let viewController = self.findViewController() else { return }
		
		let alert = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
		
		for (code, name) in currencies {
			alert.addAction(UIAlertAction(title: "\(code) - \(name)", style: .default) { [weak self] _ in
				self?.currencyRelay.accept(code)
			})
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		// For iPad support
		if let popover = alert.popoverPresentationController {
			popover.sourceView = currencyButton
			popover.sourceRect = currencyButton.bounds
		}
		
		viewController.present(alert, animated: true)
	}
}

extension UIView {
	func findViewController() -> UIViewController? {
		if let nextResponder = self.next as? UIViewController {
			return nextResponder
		} else if let nextResponder = self.next as? UIView {
			return nextResponder.findViewController()
		} else {
			return nil
		}
	}
}
