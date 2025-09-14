//
//  CheckboxButton.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/09/25.
//

import UIKit

final class CheckboxButton: UIButton {
	
	// MARK: - Initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Configuration
	private func configureView() {
		setImage(UIImage(systemName: "square"), for: .normal)
		setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
		tintColor = .systemBlue
		contentMode = .scaleAspectFit
	}
}
