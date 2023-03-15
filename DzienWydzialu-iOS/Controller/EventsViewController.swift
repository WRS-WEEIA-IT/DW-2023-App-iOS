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
    
    let eventCreator = EventCreator()
        
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

    func loadEvent(collectionType: String) {
        db.collection(collectionType).addSnapshotListener { snapshot, error in

            if error != nil {
                print("Error with loading data from firebase!")
            } else {
                if let snapshotDocuments = snapshot?.documents {
                    for document in snapshotDocuments {
                        let documentData = document.data()
                        if let newEvent = self.eventCreator.createEvent(documentData: documentData, collectionType: collectionType){
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
