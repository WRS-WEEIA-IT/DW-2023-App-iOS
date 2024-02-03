//
//  StrokeGradientButton.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 03/02/2024.
//

import UIKit

class StrokeGradientButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    private func applyGradient() {
        let colors = [
            UIColor(red: 0.25, green: 0.07, blue: 0.36, alpha: 1.00).cgColor,
            UIColor(red: 0.15, green: 0.12, blue: 0.32, alpha: 1.00).cgColor
        ]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = bounds.height / 2
        gradientLayer.frame = bounds
        
        let shape = CAShapeLayer()
        shape.lineWidth = 5
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.cornerRadius = bounds.height / 2
        shape.frame = bounds
        gradientLayer.mask = shape

        layer.addSublayer(gradientLayer)
    }
}
