//
//  SplitBillTableViewCell.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

final class SplitBillTableViewCell: UITableViewCell {
	static let identifier = "SplitBillTableViewCell"
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.layer.cornerRadius = 16
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 0, height: 2)
		view.layer.shadowRadius = 8
		view.layer.shadowOpacity = 0.1
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var amountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .systemBlue
		label.textAlignment = .right
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var locationLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = .tertiaryLabel
		label.numberOfLines = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var statusBadge: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 12
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private lazy var statusLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var participantsLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .medium)
		label.textColor = .secondaryLabel
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var chevronImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "chevron.right")
		imageView.tintColor = .tertiaryLabel
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	// MARK: - Initialization
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		backgroundColor = .clear
		selectionStyle = .none
		
		contentView.addSubview(containerView)
		statusBadge.addSubview(statusLabel)
		
		containerView.addSubview(titleLabel)
		containerView.addSubview(amountLabel)
		containerView.addSubview(dateLabel)
		containerView.addSubview(locationLabel)
		containerView.addSubview(statusBadge)
		containerView.addSubview(participantsLabel)
		containerView.addSubview(chevronImageView)
		
		setupConstraints()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// Container view
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			
			// Title label
			titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
			
			// Amount label
			amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
			amountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
			amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
			
			// Chevron
			chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			chevronImageView.widthAnchor.constraint(equalToConstant: 12),
			chevronImageView.heightAnchor.constraint(equalToConstant: 12),
			
			// Date label
			dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			
			// Location label
			locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
			locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			locationLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -8),
			
			// Status badge
			statusBadge.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
			statusBadge.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
			statusBadge.heightAnchor.constraint(equalToConstant: 24),
			statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
			
			// Status label
			statusLabel.centerXAnchor.constraint(equalTo: statusBadge.centerXAnchor),
			statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
			statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
			statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
			
			// Participants label
			participantsLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
			participantsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			participantsLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
			participantsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
		])
	}
	
	// MARK: - Configuration
	
	func configure(with splitBill: SplitBill) {
		titleLabel.text = splitBill.title
		amountLabel.text = splitBill.formattedAmount
		dateLabel.text = splitBill.formattedDate
		locationLabel.text = splitBill.location ?? "No location"
		
		// Configure status badge
		if splitBill.isSettled {
			statusBadge.backgroundColor = .systemGreen.withAlphaComponent(0.2)
			statusLabel.text = "Settled"
			statusLabel.textColor = .systemGreen
		} else {
			statusBadge.backgroundColor = .systemOrange.withAlphaComponent(0.2)
			statusLabel.text = "Pending"
			statusLabel.textColor = .systemOrange
		}
		
		// Configure participants info
		let settledCount = splitBill.settledParticipants
		let totalCount = splitBill.participantCount
		participantsLabel.text = "\(settledCount)/\(totalCount) participants paid • \(totalCount) people"
		
		// Add subtle animation on configuration
		containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
			self.containerView.transform = .identity
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
		amountLabel.text = nil
		dateLabel.text = nil
		locationLabel.text = nil
		participantsLabel.text = nil
		statusLabel.text = nil
	}
	
	// MARK: - Animation
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
			self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
			self.containerView.alpha = highlighted ? 0.8 : 1.0
		}
	}
}
