//
//  TasksViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 21/02/2023.
//

import UIKit
import FirebaseFirestore

class TasksViewController: UIViewController {
    @IBOutlet weak var taskIcon: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    let db = Firestore.firestore()
    var tasksArray : [Tasks] = [Tasks(title: "No tasks available", description: "Wait for incoming event!", points: 0, imageSource: "", qrCode: "", numberOfTask: -1, done: false)]
                
    override func viewDidLoad() {
        super.viewDidLoad()

        taskIcon.tintColor = UIColor(named: K.buttonColor)
        taskLabel.textColor = UIColor(named: K.buttonColor)

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
        pointsLabel.text = "Currently you have \(points) points!"
        loadTasks()
        if self.tasksArray.count > 1 {
            self.tasksArray.remove(at: 0)
        }
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
        
        taskCell.checkmarkImage.isHidden = true
        taskCell.downTextLabel.isHidden = false
        taskCell.qrcodeImage.isHidden = false
        taskCell.upTextLabel.text = "SCAN CODE"
        taskCell.downTextLabel.text = "TO COMPLETE THE TASK"
        taskCell.filter.alpha = 0.55
    }
    
    private func setDefaultTask(taskCell: inout TaskCell, task: Tasks) {
        taskCell.backgroundImage.image = nil
        taskCell.titleLabel.text = task.title
        taskCell.descriptionLabel.text = task.description
        taskCell.taskNumberLabel.text = nil
        taskCell.pointsButton.setTitle("NO TASKS", for: .normal)
        
        taskCell.checkmarkImage.isHidden = true
        taskCell.downTextLabel.isHidden = true
        taskCell.qrcodeImage.isHidden = true
        taskCell.upTextLabel.text = nil
    }
}

//MARK: - LOADING TASKS

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
