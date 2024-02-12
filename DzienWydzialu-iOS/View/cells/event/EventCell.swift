//
//  EventCell.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit
import SafariServices

class EventCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var eventSubject: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        styleCell()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://forms.gle/XjRZccrbxortTEiU6") {
                UIApplication.shared.open(url)
        }
    }
}
