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
    
    @IBOutlet weak var exclamationIcon: UIImageView!
    @IBOutlet weak var wrongIcon: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var okRedButton: UIButton!
    @IBOutlet weak var okYellowButton: UIButton!
    
    var parentVC: UIViewController = UIViewController()
    var isWrong: Bool = true
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        if isWrong {
            changeToWrong()
        } else {
            changeToLocal()
        }
    }
    
    func changeToLocal() {
        self.wrongIcon.isHidden = true
        self.exclamationIcon.isHidden = false
        self.textLabel.text = "Task already done!"
        self.okRedButton.isHidden = true
        self.okYellowButton.isHidden = false
    }
    
    func changeToWrong() {
        self.wrongIcon.isHidden = false
        self.exclamationIcon.isHidden = true
        self.textLabel.text = "Wrong code!"
        self.okRedButton.isHidden = false
        self.okYellowButton.isHidden = true
    }
    
    func applyConfig() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 20
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.75, delay: 0.0) {
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.75, delay: 0.0) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
            self.dismiss(animated: false)
            self.removeFromParent()
        }
        parentVC.dismiss(animated: true)
    }
    
    @IBAction func donePressed(_ sender: GradientButton) {
        hide()
    }
    
}
