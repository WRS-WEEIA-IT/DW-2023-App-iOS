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
        applyGradient(colors: [UIColor(red: 0.09, green: 0.35, blue: 0.93, alpha: 1.00).cgColor,UIColor(red: 0.02, green: 0.87, blue: 0.99, alpha: 1.00).cgColor])
    }
    
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = bounds.height / 2
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
