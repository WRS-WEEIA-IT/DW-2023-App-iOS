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
    var points = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskIcon.tintColor = UIColor(named: K.buttonColor)
        taskLabel.textColor = UIColor(named: K.buttonColor)

        tasksTableView.dataSource = self
        tasksTableView.rowHeight = K.rowHeight
        tasksTableView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
        
        loadTasks()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        loadTasks()
//        self.tasksTableView.reloadData()
//    }

}

extension TasksViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasksArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.taskCellIdentifier, for: indexPath) as! TaskCell
        
        cell.titleLabel.text = task.title
        cell.descriptionLabel.text = task.description
        cell.taskNumberLabel.text = "Zadanie \(task.numberOfTask)"
        cell.pointsButton.titleLabel?.text = "\(task.points) PUNKTÓW"
        
        if task.done {
            cell.qrcodeImage.isHidden = true
            cell.upTextLabel.text = "ZADANIE WYKONANE!"
            cell.downTextLabel.isHidden = true
            cell.filter.alpha = 0.85
        } else {
            cell.checkmarkImage.isHidden = true
            cell.downTextLabel.isHidden = false
            cell.upTextLabel.text = "ZESKANUJ KOD"
            cell.downTextLabel.text = "ABY WYKONAĆ ZADANIE"
        }
        
        return cell
    }
    
}


//MARK: - FIRESTORE

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
                        if let newTask = self.createTask(documentData: documentData) {
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
    
    func createTask(documentData : [String : Any]) -> Tasks? {
        if let newTitle = documentData[K.tasks.title] as? String, let newDescription = documentData[K.tasks.description] as? String, let newImageSource = documentData[K.tasks.imageSource] as? String, let newPoints = documentData[K.tasks.points] as? Int, let newQrCode = documentData[K.tasks.qrCode] as? String{
            
            let newDone = checkTaskWithLocal(qrcode: newQrCode, newPoints: newPoints)
            
            let newTask = Tasks(title: newTitle, description: newDescription, points: newPoints, imageSource: newImageSource, qrCode: newQrCode, numberOfTask: tasksArray.count+1, done: newDone)
            
            return newTask
        } else {
            print("Error fetching data!")
            return nil
        }
    }
    
    func checkTaskWithLocal(qrcode: String, newPoints: Int) -> Bool {
        if let localCodeArray = K.defaults.sharedUserDefaults.stringArray(forKey: K.defaults.codeArray) {
            if localCodeArray.contains(qrcode) {
                points += newPoints
                pointsLabel.text = ("Currently you have \(points) points!")
                return true
            }
        }
        return false
    }
    
    
}
    
