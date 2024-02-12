//
//  MapViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 12/02/2024.
//

import UIKit

class MapViewController: UIViewController {
    @IBOutlet weak var zoomImageView: ZoomImageView!
    @IBOutlet weak var floorButton: UIButton!
    private var isGroundFloor = true
    
    override func viewDidLoad() {
        floorButton.imageView?.image = UIImage(systemName: "square.2.layers.3d.bottom.filled")
    }
    
    @IBAction func floorButtonClicked(_ sender: Any) {
        isGroundFloor.toggle()
        if isGroundFloor {
            floorButton.setImage(UIImage(systemName: "square.2.layers.3d.bottom.filled"), for: .normal)
            zoomImageView.imageName = "groundFloor"
        } else {
            floorButton.setImage(UIImage(systemName: "square.2.layers.3d.top.filled"), for: .normal)
            zoomImageView.imageName = "firstFloor"
        }
    }
}
