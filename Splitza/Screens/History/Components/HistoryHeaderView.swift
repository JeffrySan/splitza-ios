//
//  HistoryHeaderView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import UIKit

final class HistoryHeaderView: UIView {
	
	// MARK: - UI Components
	
	private var titleLabel: UILabel!
	private var subtitleLabel: UILabel!
	var searchBar: CustomSearchBar!

	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: - Public Methods
	func setupHeaderView() async {
		await configureViews()
		
		setupUI()
	}
	
	func updateTitle(_ title: String) {
		titleLabel.text = title
	}
	
	func updateSubtitle(_ subtitle: String) {
		subtitleLabel.text = subtitle
	}

	// MARK: - Configure Views

	private func configureViews() async {
		await configureTitleLabel()
		await configureSubtitleLabel()
		await configureSearchBar()
	}

	private func configureTitleLabel() async {
		let label = UILabel()
		label.text = "Split History"
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .label
		label.translatesAutoresizingMaskIntoConstraints = false
		
		await MainActor.run {
			titleLabel = label
		}
	}

	private func configureSubtitleLabel() async {
		let label = UILabel()
		label.text = "Track all your shared expenses"
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		
		await MainActor.run {
			subtitleLabel = label
		}
	}

	private func configureSearchBar() async {
		let searchBar = CustomSearchBar()
		searchBar.placeholder = "Search bills, locations, people..."
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		
		await MainActor.run {
			self.searchBar = searchBar
		}
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
}
