//
//  AddBillTotalAmountView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillTotalAmountView: UIView {
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	
	// Observables
	let totalAmountRelay = BehaviorRelay<Double>(value: 0.0)
	let distributedAmountRelay = BehaviorRelay<Double>(value: 0.0)
	let currencyRelay = BehaviorRelay<String>(value: "IDR")
	
	var onTotalAmountChanged: ((Double) -> Void)?
	
	// MARK: - UI Components
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var totalAmountLabel: UILabel = {
		let label = UILabel()
		label.text = "Total Amount"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		return label
	}()
	
	lazy var totalAmountTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "0.00"
		textField.font = .systemFont(ofSize: 18, weight: .semibold)
		textField.textColor = .label
		textField.textAlignment = .right
		textField.keyboardType = .decimalPad
		textField.borderStyle = .none
		return textField
	}()
	
	private lazy var distributedLabel: UILabel = {
		let label = UILabel()
		label.text = "Distributed: $0.00"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var remainingLabel: UILabel = {
		let label = UILabel()
		label.text = "Remaining: $0.00"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .systemOrange
		return label
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
		addSubview(containerView)
		containerView.addSubview(totalAmountLabel)
		containerView.addSubview(totalAmountTextField)
		containerView.addSubview(distributedLabel)
		containerView.addSubview(remainingLabel)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.height.equalTo(100) // Following HIG for readable content
		}
		
		totalAmountLabel.snp.makeConstraints { make in
			make.top.leading.equalToSuperview().offset(16)
		}
		
		totalAmountTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.trailing.equalToSuperview().offset(-16)
			make.leading.greaterThanOrEqualTo(totalAmountLabel.snp.trailing).offset(16)
			make.height.equalTo(32) // HIG minimum touch target
		}
		
		distributedLabel.snp.makeConstraints { make in
			make.top.equalTo(totalAmountTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
		}
		
		remainingLabel.snp.makeConstraints { make in
			make.top.equalTo(distributedLabel.snp.bottom).offset(4)
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().offset(-16)
		}
	}
	
	private func setupBindings() {
		// Total amount input with formatting
		totalAmountTextField.rx.text.orEmpty
			.map { text -> Double in
				let cleanedText = text.replacingOccurrences(of: ",", with: "")
				return Double(cleanedText) ?? 0.0
			}
			.bind(to: totalAmountRelay)
			.disposed(by: disposeBag)
		
		// Format total amount when editing ends
		totalAmountTextField.rx.controlEvent(.editingDidEnd)
			.subscribe(onNext: { [weak self] in
				self?.formatTotalAmount()
			})
			.disposed(by: disposeBag)
		
		// Update distributed and remaining amounts
		Observable.combineLatest(
			totalAmountRelay.asObservable(),
			distributedAmountRelay.asObservable(),
			currencyRelay.asObservable()
		)
		.observe(on: MainScheduler.instance)
		.subscribe(onNext: { [weak self] (totalAmount, distributeAmount, currency) in
			
			// Safely create formatter with validation
			let formatter = NumberFormatter()
			formatter.numberStyle = .currency
			
			// Validate currency code before setting
			let validCurrency = currency.isEmpty ? "USD" : currency
			formatter.currencyCode = validCurrency
			formatter.locale = Locale.current
			
			self?.distributedLabel.text = formatter.string(from: NSNumber(value: distributeAmount)) ?? "-"
			self?.remainingLabel.text = formatter.string(from: NSNumber(value: totalAmount - distributeAmount)) ?? "-"
			
			// Update remaining amount color
			let remainingValue = (self?.totalAmountRelay.value ?? 0.0) - (self?.distributedAmountRelay.value ?? 0.0)
			
			if remainingValue == 0 {
				self?.remainingLabel.textColor = .systemGreen
			} else if remainingValue > 0 {
				self?.remainingLabel.textColor = .systemOrange
			} else {
				self?.remainingLabel.textColor = .systemRed
			}
		})
		.disposed(by: disposeBag)
		
		// Notify about total amount changes
		totalAmountRelay
			.skip(1) // Skip initial value
			.subscribe(onNext: { [weak self] amount in
				self?.onTotalAmountChanged?(amount)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Public Methods
	
	func updateDistributedAmount(_ amount: Double) {
		distributedAmountRelay.accept(amount)
	}
	
	func updateCurrency(_ currency: String) {
		currencyRelay.accept(currency)
	}
	
	// MARK: - Private Methods
	
	private func formatTotalAmount() {
		guard let currentText = totalAmountTextField.text,
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
			totalAmountTextField.text = formattedText
		}
	}
}
