//
//  ViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseFirestore

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var houseIcon: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var taskTableView: UITableView!
    
    let db = Firestore.firestore()
        
    var eventsArray: [Events] = []
    var tasksArray: [Tasks] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeLabel.textColor = UIColor(named: K.buttonColor)
        houseIcon.tintColor = UIColor(named: K.buttonColor)
        
        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        eventTableView.rowHeight = K.welcomeRowHeight
        
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
        taskTableView.rowHeight = K.welcomeRowHeight
        
        loadAllEvents()
        loadTasks()
    }

}

extension WelcomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == eventTableView) {
            return 1
        } else {
            return tasksArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == eventTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath) as! EventCell

            if !eventsArray.isEmpty {
                let event = eventsArray[0]
                    
                cell.dateLabel.text = event.time
                cell.eventSubject.text = event.title
                cell.eventType.text = event.eventType
            }
            return cell
        } else {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: K.taskCellIdentifier, for: indexPath) as! TaskCell
            let task = tasksArray[indexPath.row]
                
            taskCell.titleLabel.text = task.title
            taskCell.descriptionLabel.text = task.description
            taskCell.taskNumberLabel.text = "Zadanie \(task.numberOfTask)"
            taskCell.pointsButton.titleLabel?.text = "\(task.points) PUNKTÓW"
            
            taskCell.checkmarkImage.isHidden = true
            taskCell.downTextLabel.isHidden = false
            taskCell.qrcodeImage.isHidden = false
            taskCell.upTextLabel.text = "ZESKANUJ KOD"
            taskCell.downTextLabel.text = "ABY WYKONAĆ ZADANIE"
            taskCell.filter.alpha = 0.55
            
            return taskCell
            }
        }
    
    
}

//MARK: - Loading Events

extension WelcomeViewController {
    func loadAllEvents() {
        self.eventsArray = []
        loadEvent(collectionType: K.lectures)
        loadEvent(collectionType: K.workshops)
    }
    
    func loadEvent(collectionType: String) {
        db.collection(collectionType).whereField(K.events.timeEnd, isGreaterThanOrEqualTo: Timestamp.init()).addSnapshotListener { snapshot, error in
            
            if error != nil {
                print("Error with loading data from firebase!")
            } else {
                if let snapshotDocuments = snapshot?.documents {
                    for document in snapshotDocuments {
                        let documentData = document.data()
                        if let newEvent = self.createEvent(documentData: documentData, collectionType: collectionType) {
                            self.eventsArray.append(newEvent)
                            self.eventsArray.sort { $0.time < $1.time }
                            
                            DispatchQueue.main.async {
                                self.eventTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createEvent(documentData : [String : Any], collectionType: String ) -> Events? {
        if let newPartner = documentData[K.events.partner] as? String, let newTitle = documentData[K.events.title] as? String, let newImagesource = documentData[K.events.imageSource] as? String, let newTimeStart = documentData[K.events.timeStart] as? Timestamp, let newTimeEnd = documentData[K.events.timeEnd] as? Timestamp {
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm"
            var newTime = dateFormatter.string(from: newTimeStart.dateValue())
            
            dateFormatter.dateFormat = "HH:mm"
            let newTimeEndString = dateFormatter.string(from: newTimeEnd.dateValue())
            
            newTime += " - \(newTimeEndString)"
            
            let newEvent = Events(eventType: collectionType, time: newTime,title: newTitle, partner: newPartner, imageSource: newImagesource)
            return newEvent
        }
        return nil
    }
    
}

//MARK: - Loading Tasks

extension WelcomeViewController {
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
                            if !newTask.done {
                                self.tasksArray.append(newTask)
                                DispatchQueue.main.async {
                                    self.taskTableView.reloadData()
                                }
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
                return true
            }
        }
        return false
    }
}

