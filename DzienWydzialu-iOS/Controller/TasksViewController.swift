//
//  TasksViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 21/02/2023.
//

import UIKit
import FirebaseFirestore

class TasksViewController: UIViewController {
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    let db = Firestore.firestore()
    var tasksArray : [Tasks] = [Tasks(title: "No tasks available", description: "Wait for incoming event!", points: 0, imageSource: "", qrCode: "", numberOfTask: -1, done: false)]
                
    override func viewDidLoad() {
        super.viewDidLoad()

        tasksTableView.dataSource = self
        tasksTableView.rowHeight = K.rowHeight
        tasksTableView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        update()
    }
}

//MARK: - Points and Update

extension TasksViewController {
    func update() {
        let points = K.defaults.sharedUserDefaults.integer(forKey: K.defaults.points)
        pointsLabel.attributedText = getAttributedInfoText(points: points)
        
        loadTasks()
        if self.tasksArray.count > 1 {
            self.tasksArray.remove(at: 0)
        }
    }
    
    private func getAttributedInfoText(points: Int) -> NSMutableAttributedString {
        let attrs = [
            NSAttributedString.Key.font : UIFont(name: "Montserrat-ExtraBold", size: 12),
            NSAttributedString.Key.foregroundColor : UIColor(named: "purpleColor")
        ]
        let attributedPoints = NSMutableAttributedString(
            string: String(points),
            attributes: attrs as [NSAttributedString.Key : Any]
        )
        
        let infoText = "Currently you have "
        let attributedInfo = NSMutableAttributedString(string: infoText)
        let secondInfoText = " points"
        let attributedSecondInfo = NSMutableAttributedString(string: secondInfoText)
        
        attributedInfo.append(attributedPoints)
        attributedInfo.append(attributedSecondInfo)
        
        return attributedInfo
    }
}

//MARK: - TableView

extension TasksViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasksArray[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: K.taskCellIdentifier, for: indexPath) as! TaskCell
        
        if task.numberOfTask == -1 {
            setDefaultTask(taskCell: &cell, task: task)
        } else {
            setTask(taskCell: &cell, task: task)
        }
        
        return cell
    }
    
    private func setTask(taskCell: inout TaskCell, task: Tasks) {
        if UIImage(named: task.imageSource) != nil {
            taskCell.backgroundImage.image = UIImage(named: task.imageSource)
        }
        taskCell.titleLabel.text = task.title
        taskCell.descriptionLabel.text = task.description
        taskCell.taskNumberLabel.text = "Task \(task.numberOfTask)"
        taskCell.pointsButton.setTitle("\(task.points) POINTS", for: .normal)
        taskCell.isDone = task.done
    }
    
    private func setDefaultTask(taskCell: inout TaskCell, task: Tasks) {
        taskCell.backgroundImage.image = nil
        taskCell.titleLabel.text = task.title
        taskCell.descriptionLabel.text = task.description
        taskCell.taskNumberLabel.text = nil
        taskCell.pointsButton.setTitle("NO TASKS", for: .normal)
        taskCell.hideQrText = true
    }
}

//MARK: - Loading tasks

extension TasksViewController {
    func loadTasks() {
        db.collection("tasks").addSnapshotListener { snapshot , error in
            if error != nil { return }
            guard let snapshotDocuments = snapshot?.documents else { return }
            self.tasksArray = []

            for document in snapshotDocuments {
                let documentData = document.data()
                if let newTask = TaskCreator.createTask(documentData: documentData) {
                    self.tasksArray.append(newTask)

                    DispatchQueue.main.async {
                        self.tasksTableView.reloadData()
                    }
                }
            }
        }
    }
}
