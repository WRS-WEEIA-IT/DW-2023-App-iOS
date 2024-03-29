//
//  EventCell+Style.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 06/01/2024.
//

import UIKit

extension EventCell {
    func styleCell() {
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        backgroundImage.layer.cornerRadius = backgroundImage.frame.size.height / 8
        hideComponents()
        applyGradient()
        self.dateLabel.text = "20 marca 2024"
        self.dateLabel.isHidden = false
    }
    
    private func hideComponents() {
        dateLabel.isHidden = isDefault
        signUpButton.isHidden = isDefault
        hideButtonInLectures()
    }
    
    private func hideButtonInLectures() {
        if eventType.text == "Lecture" {
            signUpButton.isHidden = true
        }
    }
    
    private func applyGradient() {
        for subview in backgroundImage.subviews {
            subview.removeFromSuperview()
        }
        
        let gradientView = CellsStyles.getBackgroundGradientView()
        backgroundImage.addSubview(gradientView)
    }
}
