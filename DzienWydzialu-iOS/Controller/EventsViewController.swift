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
    
    var eventsArray : [Events] = [
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 15:00-16:00", timeEnd: "something", title: "Swift Development"),
        Events(eventType: "Warsztat", timeStart: "31.03.2023 10:00-12:00", timeEnd: "something", title: "Clean Code"),
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 12:15-14:00", timeEnd: "something", title: "UI/UX"),
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 12:15-14:00", timeEnd: "something", title: "UI/UX"),
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 12:15-14:00", timeEnd: "something", title: "UI/UX"),
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 12:15-14:00", timeEnd: "something", title: "UI/UX"),
        Events(eventType: "Szkolenie", timeStart: "31.03.2023 12:15-14:00", timeEnd: "something", title: "UI/UX")
    ]
    
//    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.nibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
    }


}

//MARK: - TableViewDataSource

extension EventsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = eventsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! EventCell
        
        cell.dateLabel.text = event.timeStart
        cell.eventSubject.text = event.title
        cell.eventType.text = event.eventType
        
        return cell
    }
    
    
}





//MARK: - Firebase

//extension EventsViewController {
//    func loadData() {
//        let docRef = db.collection("events").document("1")
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
//}
