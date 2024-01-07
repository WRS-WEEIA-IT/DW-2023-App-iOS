//
//  InfoViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit
import MessageUI
import FirebaseFirestore

class InfoViewController: UIViewController {
    @IBOutlet weak var pointsButton: GradientButton!
    @IBOutlet weak var appIdLabel: UILabel!
    @IBOutlet weak var awardStackView: UIStackView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
        checkWinner()
    }
}

//MARK: - Update

extension InfoViewController {
    func update() {
        if let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) {
            appIdLabel.text = "APP ID: #\(id)"
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

//MARK: - Check winner

extension InfoViewController {
    func checkWinner() {
        db.collection("contestTime").whereField(K.contestTime.endTime, isLessThan: Timestamp.init()).getDocuments { snapshot, error in
            if error != nil || snapshot?.documents.count == 0 { return }
            guard let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) else { return }
            
            self.db.collection("users").document(id).getDocument { snapshot, error in
                if error != nil { return }
                if let data = snapshot?.data() {
                    if let winner = data["winner"] as? Bool {
                        if winner == true {
                            self.awardStackView.isHidden = false
                        }
                    }
                }
            }
        }
    }
}
