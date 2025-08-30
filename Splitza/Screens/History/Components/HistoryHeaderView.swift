//
//  HistoryHeaderView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit

final class HistoryHeaderView: UIView {
	
	// MARK: - UI Components
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Split History"
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Track all your shared expenses"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private(set) lazy var searchBar: CustomSearchBar = {
		let searchBar = CustomSearchBar()
		searchBar.placeholder = "Search bills, locations, people..."
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		return searchBar
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
		backgroundColor = .systemBackground
		translatesAutoresizingMaskIntoConstraints = false
		
		addSubviews()
		setupConstraints()
	}
	
	private func addSubviews() {
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(searchBar)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Title label
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			
			// Subtitle label
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
			subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			
			// Search bar
			searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
			searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		])
	}
	
	// MARK: - Public Methods
	
	func updateTitle(_ title: String) {
		titleLabel.text = title
	}
	
	func updateSubtitle(_ subtitle: String) {
		subtitleLabel.text = subtitle
	}
}
