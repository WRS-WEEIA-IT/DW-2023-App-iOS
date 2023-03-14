//
//  AlertViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 14/03/2023.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    init() {
        super.init(nibName: K.alertNibName, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyConfig()
    }
    
    func applyConfig() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 1, delay: 0.1) {
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 1, delay: 0.0) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    @IBAction func donePressed(_ sender: GradientButton) {
        hide()
    }
    
}
