//
//  GradientButton.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 13/03/2023.
//

import UIKit

class GradientButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    private func applyGradient() {
        let colors = [
            UIColor(red: 0.247, green: 0.071, blue: 0.357, alpha: 1).cgColor,
            UIColor(red: 0.145, green: 0.122, blue: 0.322, alpha: 1).cgColor
        ]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = bounds.height / 2
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
