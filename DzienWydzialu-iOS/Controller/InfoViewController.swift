//
//  InfoViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit
import MessageUI
import FirebaseFirestore
import ThirdPartyMailer

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
    @IBAction func mailButtonClicked(_ sender: Any) {
        let recipient = "dzien.weeia@samorzad.p.lodz.pl"
        var actions = getAvailableMailsActions(recipient: recipient)
        
        if !actions.isEmpty {
            let alertController = UIAlertController(
                title: "Which mail app do you want to use?",
                message: nil,
                preferredStyle: .alert
            )
            
            actions.append(UIAlertAction(title: "Cancel", style: .default))
            actions.forEach { alertController.addAction($0) }
            
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(
                title: "We did not find any compatible mail app on your phone",
                message: "Our mail is: \(recipient)",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Copy mail", style: .cancel, handler: { _ in
                UIPasteboard.general.string = recipient
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
            
            present(alertController, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    private func getAvailableMailsActions(recipient: String) -> [UIAlertAction] {
        let clients = getAvailableMailClients()
        var actions = [UIAlertAction]()
        
        clients.forEach { client in
            actions.append(
                UIAlertAction(
                    title: client.name,
                    style: .default,
                    handler: { _ in
                        ThirdPartyMailer.openCompose(client, recipient: recipient)
                    }
                )
            )
        }
        if MFMailComposeViewController.canSendMail() {
            actions.append(
                UIAlertAction(
                    title: "Apple Mail",
                    style: .default,
                    handler: { [weak self] _ in
                        let mailComposer = MFMailComposeViewController()
                        mailComposer.mailComposeDelegate = self
                        mailComposer.setToRecipients([recipient])
                        
                        self?.present(mailComposer, animated: true)
                    }
                )
            )
        }
        return actions
    }
    
    private func getAvailableMailClients() -> [ThirdPartyMailClient] {
        let availableClientsNames = ["Gmail", "Microsoft Outlook"]
        var clients = ThirdPartyMailClient.clients.filter { availableClientsNames.contains($0.name) }
        clients.forEach { client in
            if !ThirdPartyMailer.isMailClientAvailable(client) {
                clients.removeAll(where: { $0.name == client.name })
            }
        }
        return clients
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
