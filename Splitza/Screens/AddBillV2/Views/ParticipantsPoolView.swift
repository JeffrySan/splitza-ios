//
//  ParticipantsPoolView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class ParticipantsPoolView: UIView {
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	private let viewModel: AddBillV2ViewModel
	
	var onAddParticipant: (() -> Void)?
	
	// MARK: - UI Components
	
	private lazy var containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .secondarySystemGroupedBackground
		view.layer.cornerRadius = 12
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.separator.cgColor
		return view
	}()
	
	private lazy var headerButton: UIButton = {
		let button = UIButton(type: .system)
		button.contentHorizontalAlignment = .leading
		button.backgroundColor = .clear
		return button
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Participants"
		label.font = .systemFont(ofSize: 18, weight: .semibold)
		label.textColor = .label
		return label
	}()
	
	private lazy var participantCountLabel: UILabel = {
		let label = UILabel()
		label.text = "1 person"
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private lazy var chevronImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "chevron.down")
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = .secondaryLabel
		return imageView
	}()
	
	private lazy var participantsStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.spacing = 8
		stack.alignment = .center
		stack.distribution = .fill
		return stack
	}()
	
	private lazy var addParticipantButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("+ Add", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
		button.setTitleColor(.systemBlue, for: .normal)
		button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
		button.layer.cornerRadius = 8
		button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
		return button
	}()
	
	private lazy var collapsibleContentView: UIView = {
		let view = UIView()
		return view
	}()
	
	// MARK: - Initialization
	
	init(viewModel: AddBillV2ViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		setupUI()
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup
	
	private func setupUI() {
		addSubview(containerView)
		containerView.addSubview(headerButton)
		containerView.addSubview(collapsibleContentView)
		
		headerButton.addSubview(titleLabel)
		headerButton.addSubview(participantCountLabel)
		headerButton.addSubview(chevronImageView)
		
		collapsibleContentView.addSubview(participantsStackView)
		collapsibleContentView.addSubview(addParticipantButton)
		
		setupConstraints()
		setupActions()
	}
	
	private func setupConstraints() {
		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		headerButton.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview()
			make.height.equalTo(50)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview().offset(-4)
		}
		
		participantCountLabel.snp.makeConstraints { make in
			make.leading.equalTo(titleLabel)
			make.top.equalTo(titleLabel.snp.bottom).offset(2)
		}
		
		chevronImageView.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-16)
			make.centerY.equalToSuperview()
			make.width.height.equalTo(16)
		}
		
		collapsibleContentView.snp.makeConstraints { make in
			make.top.equalTo(headerButton.snp.bottom)
			make.leading.trailing.bottom.equalToSuperview()
			make.height.equalTo(0) // Initially collapsed
		}
		
		participantsStackView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.leading.equalToSuperview().offset(16)
			make.trailing.lessThanOrEqualTo(addParticipantButton.snp.leading).offset(-12)
		}
		
		addParticipantButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-16)
			make.centerY.equalTo(participantsStackView)
			make.height.equalTo(32)
		}
	}
	
	private func setupActions() {
		headerButton.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
		addParticipantButton.addTarget(self, action: #selector(addParticipantTapped), for: .touchUpInside)
	}
	
	private func setupBindings() {
		// Participants changes
		viewModel.participantsRelay
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] participants in
				self?.updateParticipantsUI(participants)
			})
			.disposed(by: disposeBag)
		
		// Collapsed state changes
		viewModel.isParticipantsSectionCollapsed
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] isCollapsed in
				self?.updateCollapsedState(isCollapsed)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Actions
	
	@objc private func headerTapped() {
		viewModel.toggleParticipantsSection()
	}
	
	@objc private func addParticipantTapped() {
		onAddParticipant?()
	}
	
	// MARK: - Private Methods
	
	private func updateParticipantsUI(_ participants: [BillParticipant]) {
		// Update count label
		let count = participants.count
		participantCountLabel.text = count == 1 ? "1 person" : "\(count) people"
		
		// Clear existing participant views
		participantsStackView.arrangedSubviews.forEach { view in
			participantsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		
		// Add participant chips
		for participant in participants {
			let chipView = createParticipantChip(participant)
			participantsStackView.addArrangedSubview(chipView)
		}
	}
	
	private func createParticipantChip(_ participant: BillParticipant) -> UIView {
		let containerView = UIView()
		containerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
		containerView.layer.cornerRadius = 16
		containerView.layer.borderWidth = 1
		containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
		
		let label = UILabel()
		label.text = participant.abbreviatedName
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = .systemBlue
		label.textAlignment = .center
		
		containerView.addSubview(label)
		
		// Constraints
		containerView.snp.makeConstraints { make in
			make.width.height.equalTo(32)
		}
		
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		
		return containerView
	}
	
	private func updateCollapsedState(_ isCollapsed: Bool) {
		let targetHeight = isCollapsed ? 0 : 60
		let rotationAngle = isCollapsed ? 0 : CGFloat.pi
		
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
			self.collapsibleContentView.snp.updateConstraints { make in
				make.height.equalTo(targetHeight)
			}
			
			self.chevronImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
			
			// Hide/show content views
			self.collapsibleContentView.alpha = isCollapsed ? 0 : 1
			self.participantsStackView.isHidden = isCollapsed
			self.addParticipantButton.isHidden = isCollapsed
			
			self.layoutIfNeeded()
		}
	}
}
