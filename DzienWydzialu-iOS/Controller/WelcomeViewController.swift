//
//  ViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseFirestore

class WelcomeViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var houseIcon: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var taskCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
        
    var eventsArray: [Events] = []
    var tasksArray: [Tasks] = []
    
    var timer = Timer()
    var counter = 0
    
    let eventCreator = EventCreator()
    let taskCreator = TaskCreator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        homeLabel.textColor = UIColor(named: K.buttonColor)
        houseIcon.tintColor = UIColor(named: K.buttonColor)
        
        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        eventTableView.rowHeight = K.welcomeRowHeight
        
        taskCollectionView.dataSource = self
        taskCollectionView.register(UINib(nibName: K.taskCollectionNibName, bundle: nil), forCellWithReuseIdentifier: K.taskCellCollectionIdentifier)
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: K.scrollTimeInterval, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
        loadAllEvents()
        loadTasks()
        checkID()
    }

}

//MARK: - ID and Points

extension WelcomeViewController {    
    func checkID() {
        if K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) != nil {
            print("defaults cancelled id!")
            return
        }

        let id = Int.random(in: 1...999999)
        
        db.collection("users").whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                if snapshot?.count == 0 {
                    self.db.collection("users").document("\(id)").setData(["id": id, "winner": false, "points": 0, "time": Timestamp.init()])
                    let stringId = String(id)
                    K.defaults.sharedUserDefaults.set(stringId, forKey: K.defaults.codeId)
                    return
                }
            }
        }
    }
}


//MARK: - Manage tasks

extension WelcomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taskCell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskCellCollectionIdentifier, for: indexPath) as! TaskCellCollection
        
        let task = tasksArray[indexPath.row]
        
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
        
        return taskCell
    }
    
    @objc func changeImage() {
        if counter < tasksArray.count {
            counter += 1
            if(counter == tasksArray.count) {
                counter = 0
            }
            let index = IndexPath.init(item: counter, section: 0)
            self.taskCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
    }
    
}

//MARK: - Manage events

extension WelcomeViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath) as! EventCell
        
        if !eventsArray.isEmpty {
            let event = eventsArray[0]
                        
            if UIImage(named: event.imageSource) != nil {
                cell.backgroundImage.image = UIImage(named: event.imageSource)
            }
            cell.dateLabel.text = event.time
            cell.eventSubject.text = event.title
            cell.eventType.text = event.eventType
        }
        
        return cell
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
                        if let newEvent = self.eventCreator.createEvent(documentData: documentData, collectionType: collectionType) {
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
                        if let newTask = self.taskCreator.createTask(documentData: documentData) {
                            if !newTask.done {
                                self.tasksArray.append(newTask)
                                DispatchQueue.main.async {
                                    self.taskCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

