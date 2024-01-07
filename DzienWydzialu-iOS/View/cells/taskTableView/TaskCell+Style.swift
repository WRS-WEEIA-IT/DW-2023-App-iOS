//
//  TaskCell+Style.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 06/01/2024.
//

import Foundation

extension TaskCell {
    func styleCell() {
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
            checkmarkImage.isHidden = true
            qrcodeImage.isHidden = false
            infoLabel.text = "SCAN CODE\nTO COMPLETE THE TASK"
        } else {
            checkmarkImage.isHidden = false
            qrcodeImage.isHidden = true
            infoLabel.text = "TASK DONE"
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
