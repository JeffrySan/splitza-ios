//
//  AddBillSummaryView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class AddBillSummaryView: UIView {
	
	// MARK: - Properties
	
	private let disposeBag = DisposeBag()
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var summaryLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.numberOfLines = 0
		label.text = "Total: $0.00 • 0 participants • $0.00 each"
		label.textAlignment = .center
		return label
	}()
	
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
		addSubview(containerView)
		containerView.addSubview(summaryLabel)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.height.greaterThanOrEqualTo(60) // Following HIG
		}
		
		summaryLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(16)
		}
	}
	
	// MARK: - Public Methods
	
	func updateSummary(totalAmount: Double, participantCount: Int, currency: String, isBalanced: Bool) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currency
		
		let totalFormatted = formatter.string(from: NSNumber(value: totalAmount)) ?? "\(currency) \(String(format: "%.2f", totalAmount))"
		let averageAmount = participantCount > 0 ? totalAmount / Double(participantCount) : 0.0
		let averageFormatted = formatter.string(from: NSNumber(value: averageAmount)) ?? "\(currency) \(String(format: "%.2f", averageAmount))"
		
		let balanceStatus = isBalanced ? "✓ Balanced" : "⚠️ Not balanced"
		
		summaryLabel.text = "\(totalFormatted) • \(participantCount) participants • \(averageFormatted) each\n\(balanceStatus)"
		
		// Update color based on balance status
		summaryLabel.textColor = isBalanced ? .systemGreen : .systemOrange
	}
}
