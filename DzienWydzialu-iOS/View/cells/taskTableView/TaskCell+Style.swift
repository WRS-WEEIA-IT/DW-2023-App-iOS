//
//  TaskCell+Style.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 06/01/2024.
//

import UIKit

extension TaskCell {
    func styleCell() {
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        infoLabel.isHidden = hideQrText
        styleBackgroundImage()
        applyGradient()
        setStatusStyle()
        setButtonStyle()
    }
    
    private func styleBackgroundImage() {
        backgroundImage.layer.cornerRadius = backgroundImage.frame.size.height / 8
    }
    
    private func setStatusStyle() {
        if isDone {
            checkmarkImage.isHidden = false
            qrcodeImage.isHidden = true
            infoLabel.text = "TASK DONE"
            alpha = 0.6
        } else {
            checkmarkImage.isHidden = true
            qrcodeImage.isHidden = false
            infoLabel.text = "SCAN CODE\nTO COMPLETE THE TASK"
        }
    }
    
    private func setButtonStyle() {
        CellsStyles.stylePointsButton(pointsButton: &pointsButton)
    }
    
    private func applyGradient() {
        for subview in backgroundImage.subviews {
            subview.removeFromSuperview()
        }
        
        let gradientView = CellsStyles.getBackgroundGradientView()
        backgroundImage.addSubview(gradientView)
    }
}
