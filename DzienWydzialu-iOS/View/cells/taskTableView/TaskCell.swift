//
//  TaskCell.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 23/02/2023.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var isDone: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        styleCell()
    }
}
