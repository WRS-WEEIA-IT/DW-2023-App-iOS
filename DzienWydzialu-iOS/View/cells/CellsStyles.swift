//
//  CellsStyles.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 06/01/2024.
//

import UIKit

final class CellsStyles {
    static func getBackgroundGradientView() -> UIView {
        let gradientView = UIView()
        gradientView.frame = CGRect(x: 0, y: 0, width: 388, height: 162)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
        UIColor(red: 0.247, green: 0.071, blue: 0.357, alpha: 0.75).cgColor,
        UIColor(red: 0.062, green: 0.058, blue: 0.104, alpha: 0.78).cgColor,
        UIColor(red: 0.016, green: 0.015, blue: 0.025, alpha: 0.8).cgColor
        ]
        gradientLayer.locations = [0, 0.34, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        gradientLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 1, b: 1, c: -1, d: 10.19, tx: 0.5, ty: -5.1)
        )
        gradientLayer.bounds = gradientView.bounds.insetBy(
            dx: -0.5*gradientView.bounds.size.width,
            dy: -0.5*gradientView.bounds.size.height
        )
        gradientLayer.position = gradientView.center
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        return gradientView
    }
    
    static func stylePointsButton(pointsButton: inout UIButton) {
        pointsButton.backgroundColor = .clear
        pointsButton.layer.cornerRadius = 10
        pointsButton.layer.borderWidth = 1
        pointsButton.layer.borderColor = UIColor(red: 0.727, green: 0.287, blue: 1, alpha: 1).cgColor
    }
}
