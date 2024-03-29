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
    var tasksArray = [Tasks]()
                
    override func viewDidLoad() {
        super.viewDidLoad()

        tasksTableView.dataSource = self
        tasksTableView.rowHeight = K.rowHeight
        tasksTableView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
        tasksTableView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
}

//MARK: - Points and Update

extension TasksViewController {
    private func update() {
        updatePoints()
        loadTasks()
    }
    
    private func manageDefaultTask() {
        if tasksArray.count > 1 {
            tasksArray.removeAll { task in
                task.title == "No tasks available"
            }
        }
    }
    
    private func updatePoints() {
        let points = K.defaults.sharedUserDefaults.integer(forKey: K.defaults.points)
        self.pointsLabel.attributedText = self.getAttributedInfoText(points: points)
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
        taskCell.hideQrText = false
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
        DispatchQueue.main.async {
            self.db.collection("tasks").addSnapshotListener { snapshot , error in
                if error != nil { return }
                guard let snapshotDocuments = snapshot?.documents else { return }
                self.tasksArray = [Tasks(title: "No tasks available", description: "Wait for incoming event!", points: 0, imageSource: "", qrCode: "", numberOfTask: -1, done: false)]

                for document in snapshotDocuments {
                    let documentData = document.data()
                    if let newTask = TaskCreator.createTask(documentData: documentData) {
                        self.tasksArray.append(newTask)
                        self.tasksArray.sort { !$0.done && $1.done }
                        self.updatePoints()
                        self.manageDefaultTask()
                    }
                    self.tasksTableView.reloadData()
                }
            }
        }
    }
}
