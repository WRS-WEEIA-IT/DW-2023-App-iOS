//
//  TaskAlert.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 16/03/2023.
//

import UIKit

class TaskAlert: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var taskNumber: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pointsButton: GradientButton!
    
    var parentVC = UIViewController()
    var task: Tasks?
    
    init() {
        super.init(nibName: K.taskAlertNibName, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if task != nil {
            updateTask()
        }
    }
    
    func applyConfig() {
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 20
    }
    
    func updateTask() {
        if let newTask = task {
            self.taskNumber.text = "Task \(newTask.numberOfTask)"
            self.titleLabel.text = newTask.title
            self.descriptionLabel.text = newTask.description
            self.pointsButton.titleLabel?.text = "\(newTask.points) POINTS"
            self.backgroundImage.layer.cornerRadius = 25
        }
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
    
    @IBAction func okPressed(_ sender: GradientButton) {
        hide()
    }
}
