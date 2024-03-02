//
//  HomeViewController.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 17/02/2023.
//

import UIKit
import FirebaseFirestore
import ImageSlideshow

class HomeViewController: UIViewController {
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var taskCollectionView: UICollectionView!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var modalBackgroundView: UIView!
    
    let db = Firestore.firestore()
        
    var eventsArray = [Events]()
    var tasksArray = [Tasks]()
    var tasksImages: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalBackgroundView.layer.cornerRadius = 25
        setupSlideShow()
        
        eventTableView.dataSource = self
        eventTableView.register(UINib(nibName: K.eventNibName, bundle: nil), forCellReuseIdentifier: K.eventCellIdentifier)
        eventTableView.rowHeight = K.rowHeight
        
        taskCollectionView.dataSource = self
        taskCollectionView.register(UINib(nibName: K.taskCollectionNibName, bundle: nil), forCellWithReuseIdentifier: K.taskCellCollectionIdentifier)
        
        checkID()
        checkWinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    private func update() {
        loadEvents()
        loadTasks()
    }
    
    private func manageDefaultTask() {
        if tasksArray.count > 1 {
            tasksArray.removeAll { task in
                task.title == "No tasks available"
            }
        }
    }
    
    private func manageDefaultEvent() {
        if eventsArray.count > 1 {
            eventsArray.removeAll { event in
                event.title == "No events available"
            }
        }
    }
    
    @IBAction func seeEventsButtonClicked(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = K.TabBarIndex.events
    }
    
    @IBAction func seeTasksButtonClicked(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = K.TabBarIndex.tasks
    }
    
    private func setupSlideShow() {
        imageSlideshow.backgroundColor = UIColor(named: "backgroundColor")
        imageSlideshow.slideshowInterval = 3
        imageSlideshow.pageIndicator = nil
        imageSlideshow.isUserInteractionEnabled = false
        let gradient = CellsStyles.getBackgroundGradientView()
        gradient.layer.opacity = 0.9
        imageSlideshow.layer.opacity = 0.7
        imageSlideshow.contentScaleMode = .scaleAspectFill
        imageSlideshow.addSubview(gradient)
        imageSlideshow.setImageInputs([
            ImageSource(image: UIImage(named: "homeImage1")!),
            ImageSource(image: UIImage(named: "homeImage2")!),
            ImageSource(image: UIImage(named: "homeImage3")!),
            ImageSource(image: UIImage(named: "homeImage4")!),
            ImageSource(image: UIImage(named: "homeImage5")!),
            ImageSource(image: UIImage(named: "homeImage6")!),
        ])
    }
}

//MARK: - ID and Points

extension HomeViewController {
    private func getNewId() -> String {
        let timeStamp = Timestamp()
        let hashValue = String(abs(timeStamp.nanoseconds.hashValue))
        
        return hashValue
    }
    
    func checkID() {
        if K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) != nil { return }

        let id = getNewId()
        db.collection("users").whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            if error != nil { return }
            if snapshot?.count == 0 {
                self.db.collection("users").document("\(id)").setData(["id": id, "winner": false, "points": 0, "time": Timestamp.init()])
                let stringId = String(id)
                K.defaults.sharedUserDefaults.set(stringId, forKey: K.defaults.codeId)
                return
            }
        }
    }
}

//MARK: - Check Winner

extension HomeViewController {
    func checkWinner() {
        db.collection("contestTime").whereField(K.contestTime.endTime, isLessThan: Timestamp.init()).getDocuments { snapshot, error in
            if error != nil || snapshot?.documents.count == 0 { return }
            guard let id = K.defaults.sharedUserDefaults.string(forKey: K.defaults.codeId) else { return }
            
            self.db.collection("users").document(id).getDocument { snapshot, error in
                if error != nil { return }
                guard let data = snapshot?.data() else { return }
                
                if let winner = data["winner"] as? Bool {
                    let alert = AlertViewController()
                    alert.parentVC = self
                    alert.homeAlert = true
                    alert.isWinner = winner
                    
                    alert.appear(sender: self)
                }
            }
        }
    }
}

//MARK: - Manage tasks

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var taskCell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskCellCollectionIdentifier, for: indexPath) as! TaskCellCollection

        let task = tasksArray[indexPath.row]
        if task.numberOfTask == -1 {
            setDefaultTask(taskCell: &taskCell, task: task)
        } else {
            setTask(taskCell: &taskCell, task: task)
        }
        
        return taskCell
    }
    
    private func setTask(taskCell: inout TaskCellCollection, task: Tasks) {
        if UIImage(named: task.imageSource) != nil {
            taskCell.backgroundImage.image = tasksImages[task.imageSource]
        }
        taskCell.titleLabel.text = task.title
        taskCell.descriptionLabel.text = task.description
        taskCell.taskNumberLabel.text = "Task \(task.numberOfTask)"
        taskCell.pointsButton.setTitle("\(task.points) POINTS", for: .normal)
        taskCell.isDone = task.done
    }
    
    private func setDefaultTask(taskCell: inout TaskCellCollection, task: Tasks) {
        taskCell.backgroundImage.image = nil
        taskCell.titleLabel.text = task.title
        taskCell.descriptionLabel.text = task.description
        taskCell.taskNumberLabel.text = nil
        taskCell.pointsButton.setTitle("NO TASKS", for: .normal)
        taskCell.hideQrText = true
    }
}

//MARK: - Manage events

extension HomeViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath) as! EventCell
        
        if !eventsArray.isEmpty {
            let event = eventsArray[0]
                        
            if UIImage(named: event.imageSource) != nil {
                cell.backgroundImage.image = UIImage(named: event.imageSource)
            } else if event.imageSource == "" {
                cell.backgroundImage.image = nil
            }
            cell.hourLabel.text = event.time
            cell.eventSubject.text = event.title
            cell.eventType.text = event.eventType
            if event.room.isEmpty {
                cell.place.text = ""
                cell.isDefault = true
            } else {
                cell.place.text = "\(event.partner), Room \(event.room)"
            }
        }
        
        return cell
    }
}

//MARK: - Loading Events

extension HomeViewController {
    func loadEvents() {
        self.eventsArray = [Events(eventType: "Wait for incoming event!", time: "", title: "No events available", partner: "", imageSource: "", room: "")]
        loadEvent(collectionType: K.lectures)
        loadEvent(collectionType: K.workshops)
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
                    self.manageDefaultEvent()
                }
                self.eventTableView.reloadData()
            }
        }
    }
}

//MARK: - Loading Tasks

extension HomeViewController {
    func loadTasks() {
        db.collection("tasks").addSnapshotListener { snapshot , error in
            if error != nil { return }
            guard let snapshotDocuments = snapshot?.documents else { return }
            self.tasksArray = [Tasks(title: "No tasks available", description: "Wait for incoming event!", points: 0, imageSource: "", qrCode: "", numberOfTask: -1, done: false)]

            for document in snapshotDocuments {
                let documentData = document.data()
                if let newTask = TaskCreator.createTask(documentData: documentData) {
                    if !newTask.done {
                        self.tasksArray.append(newTask)
                        self.tasksImages[newTask.imageSource] = UIImage(named: newTask.imageSource)
                        self.manageDefaultTask()
                    }
                }
                self.taskCollectionView.reloadData()
            }
        }
    }
}
