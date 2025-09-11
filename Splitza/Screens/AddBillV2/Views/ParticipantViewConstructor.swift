//
//  ParticipantView.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/09/25.
//

import UIKit

struct ParticipantViewConstructor {
	
	static func create(selectedParticipantTag: Int, labelName: String, index: Int) -> UIView {
		let isSelectedParticipant = selectedParticipantTag == index
		let borderColor: UIColor = isSelectedParticipant ? .systemBlue : .systemBlue.withAlphaComponent(0.3)
		
		let containerView = UIView()
		containerView.backgroundColor = isSelectedParticipant ? .systemBlue.withAlphaComponent(0.2) : .systemBlue.withAlphaComponent(0.1)
		containerView.layer.cornerRadius = 16
		containerView.layer.borderWidth = isSelectedParticipant ? 2 : 1
		containerView.layer.borderColor = borderColor.cgColor
		containerView.tag = index
		
		let label = UILabel()
		label.text = labelName
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
}
