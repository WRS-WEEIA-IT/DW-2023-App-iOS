//
//  SettingsViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit

class InfoViewController : UIViewController {
    
    @IBOutlet weak var pointsButton: GradientButton!
    @IBOutlet weak var appIdLabel: UILabel!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsIcon.tintColor = UIColor(named: K.buttonColor)
        settingsLabel.textColor = UIColor(named: K.buttonColor)
        update()
    }
    
}

extension InfoViewController {
    func update() {
        let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId)
        if id != nil {
            appIdLabel.text = "APP ID: #\(id!)"
        } else {
            appIdLabel.text = "NO ID ASSIGNED"
        }
        
        let points = K.defaults.sharedUserDefaults.integer(forKey: K.defaults.points)
        pointsButton.setTitle("You have \(points) points", for: .normal)
    }
}
