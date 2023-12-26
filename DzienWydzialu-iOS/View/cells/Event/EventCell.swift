//
//  EventCell.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit
import SafariServices

class EventCell : UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var eventSubject: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        backgroundImage.layer.cornerRadius = backgroundImage.frame.size.height / 8
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeFIvOGhhrMT6bvAaxosJENssDEa4kW-4ZJr0LpDQsLagVoNQ/closedform") {
                UIApplication.shared.open(url)
        }
    }
}
