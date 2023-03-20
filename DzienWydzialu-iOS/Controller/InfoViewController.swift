//
//  SettingsViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit
import MessageUI

class InfoViewController : UIViewController {
    
    @IBOutlet weak var pointsButton: GradientButton!
    @IBOutlet weak var appIdLabel: UILabel!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsIcon.tintColor = UIColor(named: K.buttonColor)
        settingsLabel.textColor = UIColor(named: K.buttonColor)
        update()
    }
    
    
}

//MARK: - Update

extension InfoViewController {
    func update() {
        let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId)
        if id != nil {
            appIdLabel.text = "APP ID: #\(id!)"
        } else {
            appIdLabel.text = "NO ID ASSIGNED"
        }
        
        let points = K.defaults.sharedUserDefaults.integer(forKey: K.defaults.points)
        pointsButton.setTitle("You have \(points) points", for: .normal)
    }
}

//MARK: - Contact email

extension InfoViewController: MFMailComposeViewControllerDelegate {
    @IBAction func contactUsPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["dzien.weeia@samorzad.p.lodz.pl"])
            mailComposer.setSubject("")
                    
            if let fileUrl = Bundle.main.url(forResource: "document", withExtension: "pdf") {
                if let fileData = try? Data(contentsOf: fileUrl) {
                    mailComposer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: "document.pdf")
                }
            }
                    
            present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
