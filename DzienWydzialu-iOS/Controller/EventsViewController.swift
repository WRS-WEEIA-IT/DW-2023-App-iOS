//
//  EventsViewController.swift
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
    
    let db = Firestore.firestore()
    var eventsArray: [Events] = [Events(eventType: "Wait for incoming event!", time: "", title: "No events available", partner: "", imageSource: "", hall: "")]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        eventIcon.tintColor = UIColor(named: K.buttonColor)
        eventLabel.textColor = UIColor(named: K.buttonColor)
        
        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        eventTableView.rowHeight = K.rowHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        if UIImage(named: event.imageSource) != nil {
            cell.backgroundImage.image = UIImage(named: event.imageSource)
        } else if event.imageSource == "" {
            cell.backgroundImage.image = nil
        }
        cell.dateLabel.text = event.time
        cell.eventSubject.text = event.title
        cell.eventType.text = event.eventType
        cell.place.text = event.hall
        
        return cell
    }
}

//MARK: - Firebase

extension EventsViewController {
    func loadAllEvents() {
        self.eventsArray = []
        loadEvent(collectionType: K.lectures)
        loadEvent(collectionType: K.workshops)
        if self.eventsArray.count > 1 {
            self.eventsArray.remove(at: 0)
        }
    }

    func loadEvent(collectionType: String) {
        db.collection(collectionType).whereField(K.Events.timeEnd, isGreaterThanOrEqualTo: Timestamp.init()).addSnapshotListener { snapshot, error in
            if error != nil { return }
            guard let snapshotDocuments = snapshot?.documents else { return }
            
            for document in snapshotDocuments {
                let documentData = document.data()
                if let newEvent = EventCreator.createEvent(documentData: documentData, collectionType: collectionType) {
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
