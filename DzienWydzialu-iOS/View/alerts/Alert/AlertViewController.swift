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
  
    @IBOutlet weak var checkmarkIcon: UIImageView!
    @IBOutlet weak var exclamationIcon: UIImageView!
    @IBOutlet weak var wrongIcon: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var officeTextLabel: UILabel!
    
    @IBOutlet weak var okGreenButton: UIButton!
    @IBOutlet weak var okRedButton: UIButton!
    @IBOutlet weak var okYellowButton: UIButton!
    
    var parentVC = UIViewController()
    
    var isWrong: Bool = true
    var isWinner: Bool = false
    var homeAlert: Bool = false
    
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
        if homeAlert {
            if isWinner {
                changeToWinner()
            } else {
                changeToLoser()
            }
        } else {
            if isWrong {
                changeToWrong()
            } else {
                changeToLocal()
            }
        }
    }
    
    func changeToLoser() {
        self.wrongIcon.isHidden = false
        self.exclamationIcon.isHidden = true
        self.checkmarkIcon.isHidden = true
        
        self.textLabel.text = "You didn't win! :("
        self.officeTextLabel.isHidden = true
        
        self.okRedButton.isHidden = false
        self.okYellowButton.isHidden = true
        self.okGreenButton.isHidden = true
    }
    
    func changeToWinner() {
        self.wrongIcon.isHidden = true
        self.exclamationIcon.isHidden = true
        self.checkmarkIcon.isHidden = false
        
        self.textLabel.text = "You won an award!"
        self.officeTextLabel.isHidden = false
        
        self.okRedButton.isHidden = true
        self.okYellowButton.isHidden = true
        self.okGreenButton.isHidden = false
    }
    
    func changeToLocal() {
        self.wrongIcon.isHidden = true
        self.exclamationIcon.isHidden = false
        self.checkmarkIcon.isHidden = true
        
        self.textLabel.text = "Task already done!"
        self.officeTextLabel.isHidden = true
        
        self.okRedButton.isHidden = true
        self.okYellowButton.isHidden = false
        self.okGreenButton.isHidden = true
    }
    
    func changeToWrong() {
        self.wrongIcon.isHidden = false
        self.exclamationIcon.isHidden = true
        self.checkmarkIcon.isHidden = true
        
        self.textLabel.text = "Wrong code!"
        self.officeTextLabel.isHidden = true
        
        self.okRedButton.isHidden = false
        self.okYellowButton.isHidden = true
        self.okGreenButton.isHidden = true
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
        if !homeAlert {
            parentVC.dismiss(animated: true)
        }
    }
    
    @IBAction func donePressed(_ sender: GradientButton) {
        hide()
    }
}
