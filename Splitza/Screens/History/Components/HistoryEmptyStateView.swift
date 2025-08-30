//
//  HistoryEmptyStateView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit

final class HistoryEmptyStateView: UIView {
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
		imageView.tintColor = .systemGray3
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "No split bills found"
		label.font = .systemFont(ofSize: 20, weight: .semibold)
		label.textColor = .systemGray
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Your split bill history will appear here"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .systemGray2
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}
	
	// MARK: - Setup
	
	private func setupView() {
		backgroundColor = .clear
		isHidden = true
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubviews()
		setupConstraints()
	}
	
	private func addSubviews() {
		addSubview(containerView)
		containerView.addSubview(imageView)
		containerView.addSubview(titleLabel)
		containerView.addSubview(subtitleLabel)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Container view - properly centered
			containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50), // Offset slightly up for better visual balance
			containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
			containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
			containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20),
			containerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20),
			
			// Image view
			imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
			imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			imageView.widthAnchor.constraint(equalToConstant: 80),
			imageView.heightAnchor.constraint(equalToConstant: 80),
			
			// Title label
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			
			// Subtitle label
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
	}
	
	// MARK: - Public Methods
	
	func configure(title: String, subtitle: String, imageName: String) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		imageView.image = UIImage(systemName: imageName)
	}
}
