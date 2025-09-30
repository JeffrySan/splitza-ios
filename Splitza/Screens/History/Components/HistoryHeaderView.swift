//
//  HistoryHeaderView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit

final class HistoryHeaderView: UIView {
	
	// MARK: - UI Components
	
	private let titleLabel: UILabel = UILabel()
	private let subtitleLabel: UILabel = UILabel()
	private let searchBar: CustomSearchBar = CustomSearchBar()

	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureViews()
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configureViews()
		setupUI()
	}

	// MARK: - Configure Views

	private func configureViews() {
		configureTitleLabel()
		configureSubtitleLabel()
		configureSearchBar()
	}

	private func configureTitleLabel() {
		titleLabel.text = "Split History"
		titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
		titleLabel.textColor = .label
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureSubtitleLabel() {
		subtitleLabel.text = "Track all your shared expenses"
		subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
		subtitleLabel.textColor = .secondaryLabel
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureSearchBar() {
		searchBar.placeholder = "Search bills, locations, people..."
		searchBar.translatesAutoresizingMaskIntoConstraints = false
	}

	// MARK: - Setup UI
	
	private func setupUI() {
		setupViewAppearance()
		setupViewHierarchy()
		setupConstraints()
	}

	private func setupViewAppearance() {
		backgroundColor = .systemBackground
		translatesAutoresizingMaskIntoConstraints = false
	}

	private func setupViewHierarchy() {
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
