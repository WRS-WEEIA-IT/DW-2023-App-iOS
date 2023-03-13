//
//  SettingsViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsIcon.tintColor = UIColor(named: K.buttonColor)
        settingsLabel.textColor = UIColor(named: K.buttonColor)
    }
}
