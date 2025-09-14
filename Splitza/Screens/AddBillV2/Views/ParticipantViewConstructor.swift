//
//  ParticipantView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/09/25.
//

import UIKit
import RxSwift
import RxRelay

final class ParticipantViewCoin: UIView {
	
	private let label = UILabel()
	
	private let disposeBag: DisposeBag = DisposeBag()
	private let billParticipant: BillParticipant
	private let viewModel: AddBillV2ViewModel
	private let disableTap: Bool
	
	init(billParticipant: BillParticipant, viewModel: AddBillV2ViewModel, disableTap: Bool = false) {
		self.billParticipant = billParticipant
		self.viewModel = viewModel
		self.disableTap = disableTap
		
		super.init(frame: .zero)
		
		configureContainerView()
		configureLabelView()
		
		setupConstraints()
		
		observeSelectedParticipant()
	}
	
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		setupActions()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureContainerView(isSelectedParticipant: Bool = false) {
		
		let borderColor: UIColor = isSelectedParticipant ? .systemBlue : .systemBlue.withAlphaComponent(0.3)
		
		backgroundColor = isSelectedParticipant ? .systemBlue.withAlphaComponent(0.2) : .systemBlue.withAlphaComponent(0.1)
		layer.cornerRadius = 16
		layer.borderWidth = isSelectedParticipant ? 2 : 1
		layer.borderColor = borderColor.cgColor
	}
	
	private func configureLabelView() {
		label.text = billParticipant.abbreviatedName
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = .systemBlue
		label.textAlignment = .center
		
		addSubview(label)
	}
	
	private func setupConstraints() {
		snp.makeConstraints { make in
			make.width.height.equalTo(32)
		}
		
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
	}
	
	private func observeSelectedParticipant() {
		viewModel.selectedParticipant
			.distinctUntilChanged({ old, new in
				return old.id == new.id
			})
			.subscribe(onNext: { [weak self] participant in
				
				guard let self else {
					return
				}
				
				let isSelectedParticipant = participant.id == self.billParticipant.id
				self.configureContainerView(isSelectedParticipant: isSelectedParticipant)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupActions() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		addGestureRecognizer(tapGesture)
	}
	
	@objc private func handleTap() {
		
		guard !disableTap else {
			return
		}
		
		viewModel.selectedParticipant.accept(billParticipant)
	}
}
