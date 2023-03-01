//
//  ViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseFirestore

class EventsViewController: UIViewController {
        
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventIcon: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    
    var eventsArray: [Events] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventIcon.tintColor = UIColor(named: K.buttonColor)
        eventLabel.textColor = UIColor(named: K.buttonColor)
        
        eventTableView.dataSource = self
        eventTableView.rowHeight = K.rowHeight
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        
        loadAllEvents()
    }


}

//MARK: - TableViewDataSource

extension EventsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = eventsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath) as! EventCell
        
        cell.dateLabel.text = event.time
        cell.eventSubject.text = event.title
        cell.eventType.text = event.eventType
        
        return cell
    }

}


//MARK: - Firebase

extension EventsViewController {
    func loadAllEvents() {
        self.eventsArray = []
        loadEvent(collectionType: K.lectures)
        loadEvent(collectionType: K.workshops)
    }
    
    func loadEvent(collectionType : String) {
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
    
}
