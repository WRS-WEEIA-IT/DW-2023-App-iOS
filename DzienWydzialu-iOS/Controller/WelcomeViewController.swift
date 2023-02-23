//
//  ViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseFirestore

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var houseIcon: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeLabel.textColor = UIColor(named: K.buttonColor)
        houseIcon.tintColor = UIColor(named: K.buttonColor)
    }

}

