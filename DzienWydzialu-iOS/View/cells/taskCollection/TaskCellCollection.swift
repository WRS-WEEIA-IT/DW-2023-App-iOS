//
//  TaskCell.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 23/02/2023.
//

import UIKit

class TaskCellCollection : UICollectionViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pointsButton: GradientButton!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var isDone: Bool = false
    var hideQrText: Bool = false
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        styleCell()
    }
}
