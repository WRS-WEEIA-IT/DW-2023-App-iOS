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
    var tasksArray: [Tasks] = [Tasks(title: "yeah", description: "Yeah", points: 5, imageSource: "ee", qrCode: "ee", numberOfTask: 5, done: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeLabel.textColor = UIColor(named: K.buttonColor)
        houseIcon.tintColor = UIColor(named: K.buttonColor)
        
        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: K.taskNibName, bundle: nil), forCellReuseIdentifier: K.taskCellIdentifier)
        
        loadAllEvents()
    }

}

extension WelcomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath) as! EventCell
        if tableView == eventTableView {
            let event = eventsArray[0]
            
            cell.dateLabel.text = event.time
            cell.eventSubject.text = event.title
            cell.eventType.text = event.eventType
            
            return cell
        } else {
            let event = eventsArray[1]
            
            cell.dateLabel.text = event.time
            cell.eventSubject.text = event.title
            cell.eventType.text = event.eventType
            
            return cell
        }
        
    }
    
    
}

//MARK: - Loading tasks and events

extension WelcomeViewController {
    func loadAllEvents() {
        self.eventsArray = []
        loadEvent(collectionType: K.lectures)
        loadEvent(collectionType: K.workshops)
    }
    
    func loadEvent(collectionType: String) {
        db.collection(collectionType).addSnapshotListener { snapshot, error in
            
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
    
    func loadTasks() {
        
    }
    
}

