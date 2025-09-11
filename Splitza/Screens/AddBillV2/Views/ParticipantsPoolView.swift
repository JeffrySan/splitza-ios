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
	
	var onAddParticipant: (() -> Void)?
	
	// MARK: - UI Components
	private let headerButton: UIButton = UIButton(type: .system)
	private let titleLabel: UILabel = UILabel()
	private let participantCountLabel: UILabel = UILabel()
	private let chevronImageView: UIImageView = UIImageView()
	
	private let collapsibleContentView: UIView = UIView()
	private let participantsStackView: UIStackView = UIStackView()
	private let addParticipantButton: UIButton = UIButton(type: .system)
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	private let viewModel: AddBillV2ViewModel
	
	init(viewModel: AddBillV2ViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		
		// Configure View
		configureContainerView()
		
		configureHeaderButton()
		configureTitleLabel()
		configureParticipantCountLabel()
		configureChevronImageView()

		configureParticipantsStackView()
		configureAddParticipantButton()
		
		// Configure View Hierarchy
		configureViewHierarchy()
		
		// Configure Constraints
		setupHeaderButtonConstraints()
		setupCollapsibleContainerConstraints()

		// Configure Bindings
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		
		self.viewModel = AddBillV2ViewModel()
		super.init(coder: coder)
		
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		// Setup any gesture recognizers or main thread operations here
		setupActions()
	}
	
	private func configureContainerView() {
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .secondarySystemGroupedBackground
		layer.cornerRadius = 12
		layer.borderWidth = 1
		layer.borderColor = UIColor.separator.cgColor
	}
	
	private func configureHeaderButton() {
		headerButton.contentHorizontalAlignment = .leading
		headerButton.backgroundColor = .clear
		headerButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureTitleLabel() {
		titleLabel.text = "Participants"
		titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
		titleLabel.backgroundColor = .clear
		titleLabel.textColor = .label
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureParticipantCountLabel() {
		participantCountLabel.text = "1 person"
		participantCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
		participantCountLabel.textColor = .secondaryLabel
		participantCountLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureChevronImageView() {
		chevronImageView.image = UIImage(systemName: "chevron.down")
		chevronImageView.contentMode = .scaleAspectFit
		chevronImageView.tintColor = .secondaryLabel
		chevronImageView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureParticipantsStackView() {
		participantsStackView.axis = .horizontal
		participantsStackView.spacing = 8
		participantsStackView.alignment = .center
		participantsStackView.distribution = .fill
		participantsStackView.backgroundColor = .clear
		participantsStackView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureAddParticipantButton() {
		addParticipantButton.setTitle("+ Add", for: .normal)
		addParticipantButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
		addParticipantButton.setTitleColor(.systemBlue, for: .normal)
		addParticipantButton.backgroundColor = .systemBlue.withAlphaComponent(0.1)
		addParticipantButton.layer.cornerRadius = 8
		addParticipantButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
		addParticipantButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func configureViewHierarchy() {
		addSubview(headerButton)
		
		headerButton.addSubview(titleLabel)
		headerButton.addSubview(participantCountLabel)
		headerButton.addSubview(chevronImageView)
		
		addSubview(collapsibleContentView)

		collapsibleContentView.addSubview(participantsStackView)
		collapsibleContentView.addSubview(addParticipantButton)
	}
	
	private func setupHeaderButtonConstraints() {
		
		headerButton.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(8)
			make.left.right.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.top.equalToSuperview()
		}
		
		participantCountLabel.snp.makeConstraints { make in
			make.leading.equalTo(titleLabel)
			make.top.equalTo(titleLabel.snp.bottom).offset(2)
			make.bottom.equalToSuperview()
		}
		
		chevronImageView.snp.makeConstraints { make in
			make.right.equalToSuperview().offset(-8)
			make.centerY.equalTo(headerButton)
			make.width.height.equalTo(16)
		}
	}
	
	private func setupCollapsibleContainerConstraints() {
		
		collapsibleContentView.snp.makeConstraints { make in
			make.top.equalTo(headerButton.snp.bottom).offset(8)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalToSuperview().offset(-8)
			make.height.equalTo(0)
		}
		
		participantsStackView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview().offset(-8)
			make.leading.equalToSuperview().offset(16)
			make.height.equalTo(40)
			make.trailing.lessThanOrEqualTo(addParticipantButton.snp.leading).offset(-12)
		}
		
		addParticipantButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview().offset(-16)
			make.centerY.equalTo(participantsStackView)
			make.height.width.equalTo(32)
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
		for (index, participant) in participants.enumerated() {
			let chipView = ParticipantViewConstructor.create(
				selectedParticipantTag: viewModel.selectedParticipantViewTag,
				labelName: participant.abbreviatedName,
				index: index
			)
			participantsStackView.addArrangedSubview(chipView)
		}
	}
	
	private func updateCollapsedState(_ isCollapsed: Bool) {
		let targetHeight = isCollapsed ? 0 : 40
		let rotationAngle = isCollapsed ? 0 : CGFloat.pi
		
		UIView.animate(
			withDuration: 0.3,
			delay: 0,
			usingSpringWithDamping: 0.8,
			initialSpringVelocity: 0.5,
			options: .curveEaseIn
		) { [weak self] in
			
			guard let self else {
				return
			}
			
			self.collapsibleContentView.snp.updateConstraints { make in
				make.height.equalTo(targetHeight)
			}
			
			self.chevronImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
			
			// Hide/show content views
			self.collapsibleContentView.isHidden = isCollapsed
			self.collapsibleContentView.alpha = isCollapsed ? 0 : 1
			self.participantsStackView.isHidden = isCollapsed
			self.addParticipantButton.isHidden = isCollapsed
		}
	}
}
