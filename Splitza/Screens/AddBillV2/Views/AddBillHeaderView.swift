//
//  AddBillHeaderView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 05/09/25.
//

import UIKit
import RxRelay

final class AddBillHeaderView: UIView {
	
	let titleTextField: UITextField = UITextField()
	let locationTextField: UITextField = UITextField()
	
	init() {
		super.init(frame: .zero)
		
		configureContainerView()
		configureTitleTextField()
		configureLocationTextField()
		
		constructViewHierarchy()
		
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureContainerView() {
		backgroundColor = .secondarySystemGroupedBackground
		layer.cornerRadius = 12
		layer.borderWidth = 1
		layer.borderColor = UIColor.separator.cgColor
	}
	
	private func configureTitleTextField() {
		titleTextField.placeholder = "Bill title (e.g., Lunch at Restaurant)"
		titleTextField.font = .systemFont(ofSize: 18, weight: .semibold)
		titleTextField.textColor = .label
		titleTextField.borderStyle = .none
		titleTextField.returnKeyType = .next
	}
	
	private func configureLocationTextField() {
		locationTextField.placeholder = "Location (optional)"
		locationTextField.font = .systemFont(ofSize: 14, weight: .regular)
		locationTextField.textColor = .secondaryLabel
		locationTextField.borderStyle = .none
		locationTextField.returnKeyType = .next
	}
	
	private func constructViewHierarchy() {
		addSubview(titleTextField)
		addSubview(locationTextField)
	}
	
	private func setupConstraints() {
		titleTextField.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(24)
		}
		
		locationTextField.snp.makeConstraints { make in
			make.top.equalTo(titleTextField.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.equalTo(20)
		}
	}
}
