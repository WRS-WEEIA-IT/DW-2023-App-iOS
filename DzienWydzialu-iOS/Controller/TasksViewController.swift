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
    @IBOutlet weak var tasksTabelView: UITableView!
    
    var tasksArray : [Tasks] = [
    Tasks(numberOfTask: "Zadanie 1", title: "Witamy na wydziale!", description: "Kod do wykonania zadania znajdziesz..", points: "15 PUNKTÓW", done: false),
    Tasks(numberOfTask: "Zadanie 2", title: "Witamy na wydziale!", description: "Kod do wykonania zadania znajdziesz..", points: "10 PUNKTÓW", done: true),
    Tasks(numberOfTask: "Zadanie 3", title: "Witamy na wydziale!", description: "Kod do wykonania zadania znajdziesz..", points: "5 PUNKTÓW", done: false),
    Tasks(numberOfTask: "Zadanie 4", title: "Witamy na wydziale!", description: "Kod do wykonania zadania znajdziesz..", points: "10 PUNKTÓW", done: false),
    Tasks(numberOfTask: "Zadanie 5", title: "Witamy na wydziale!", description: "Kod do wykonania zadania znajdziesz..", points: "15 PUNKTÓW", done: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskIcon.tintColor = UIColor(named: K.buttonColor)
        taskLabel.textColor = UIColor(named: K.buttonColor)

        tasksTabelView.dataSource = self
        tasksTabelView.rowHeight = K.rowHeight
        tasksTabelView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
    }


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
        cell.taskNumberLabel.text = task.numberOfTask
        cell.pointsButton.titleLabel?.text = task.points
        
        if task.done {
            cell.qrcodeImage.isHidden = true
            cell.upTextLabel.text = "ZADANIE WYKONANE!"
            cell.downTextLabel.isHidden = true
            cell.filter.alpha = 0.75
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


//        let db = Firestore.firestore()
//        let docRef = db.collection("tasks").document("gała")
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//            } else {
//                print("Document does not exist")
//            }
//        }
