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
    
    var tasksArray : [Tasks] = []
    
    let db = Firestore.firestore()
    let taskCreator = TaskCreator()
                
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
    }
}

//MARK: - TableView

extension TasksViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasksArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.taskCellIdentifier, for: indexPath) as! TaskCell
        
        if UIImage(named: task.imageSource) != nil {
            cell.backgroundImage.image = UIImage(named: task.imageSource)
        }
        cell.titleLabel.text = task.title
        cell.descriptionLabel.text = task.description
        cell.taskNumberLabel.text = "Task \(task.numberOfTask)"
        cell.pointsButton.setTitle("\(task.points) POINTS", for: .normal)
        
        if task.done {
            cell.qrcodeImage.isHidden = true
            cell.upTextLabel.text = "TASK COMPLETED!"
            cell.downTextLabel.isHidden = true
            cell.checkmarkImage.isHidden = false
            cell.filter.alpha = 0.85
        } else {
            cell.checkmarkImage.isHidden = true
            cell.downTextLabel.isHidden = false
            cell.qrcodeImage.isHidden = false
            cell.upTextLabel.text = "SCAN CODE"
            cell.downTextLabel.text = "TO COMPLETE THE TASK"
            cell.filter.alpha = 0.55
        }
        
        return cell
    }
    
}


//MARK: - LOADING TASKS

extension TasksViewController {
    
    func loadTasks() {
        db.collection("tasks").addSnapshotListener { snapshot , error in
            
            self.tasksArray = []
            
            if error != nil {
                print("Error fetching tasks from Firebase!")
            } else {
                if let snapshotDocuments = snapshot?.documents {
                    for document in snapshotDocuments {
                        let documentData = document.data()
                        if let newTask = self.taskCreator.createTask(documentData: documentData) {
                            self.tasksArray.append(newTask)
                            
                            DispatchQueue.main.async {
                                self.tasksTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
}
    
