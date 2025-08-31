//
//  AddBillHeaderView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit
import SnapKit

final class AddBillHeaderView: UIView {
	
	// MARK: - Properties
	
	var onCancel: (() -> Void)?
	var onSave: (() -> Void)?
	
	// MARK: - UI Components
	
	private lazy var dragIndicator: UIView = {
		let view = UIView()
		view.backgroundColor = .tertiaryLabel
		view.layer.cornerRadius = 2.5
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Add New Bill"
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.textAlignment = .center
		return label
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Cancel", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		return button
	}()
	
	lazy var saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Save", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		button.backgroundColor = .systemBlue
		button.setTitleColor(.white, for: .normal)
		button.setTitleColor(.systemBackground, for: .disabled)
		button.layer.cornerRadius = 10
		button.isEnabled = false
		return button
	}()
	
	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupActions()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupActions()
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		backgroundColor = .systemBackground
		
		addSubview(dragIndicator)
		addSubview(titleLabel)
		addSubview(cancelButton)
		addSubview(saveButton)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		dragIndicator.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.centerX.equalToSuperview()
			make.width.equalTo(36)
			make.height.equalTo(4)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.top.equalTo(dragIndicator.snp.bottom).offset(16)
		}
		
		cancelButton.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalTo(titleLabel)
		}
		
		saveButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-16)
			make.centerY.equalTo(titleLabel)
			make.width.equalTo(60)
			make.height.equalTo(32)
			make.bottom.equalToSuperview().offset(-16)
		}
	}
	
	private func setupActions() {
		cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
		saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
	}
	
	@objc private func cancelTapped() {
		onCancel?()
	}
	
	@objc private func saveTapped() {
		onSave?()
	}
}
