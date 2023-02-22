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
    
    var eventsArray : [Events] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }


}







//MARK: - Firebase

extension EventsViewController {
    func loadData() {
        let docRef = db.collection("events").document("1")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
}
