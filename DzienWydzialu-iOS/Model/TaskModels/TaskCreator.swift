//
//  TaskCreator.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 15/03/2023.
//

import UIKit

struct TaskCreator {
    func createTask(documentData : [String : Any]) -> Tasks? {
        if let newTitle = documentData[K.tasks.title] as? String, let newDescription = documentData[K.tasks.description] as? String, let newImageSource = documentData[K.tasks.imageSource] as? String, let newPoints = documentData[K.tasks.points] as? Int, let newQrCode = documentData[K.tasks.qrCode] as? String, let newTaskNumber = documentData[K.tasks.taskNumber] as? Int {
            
            let newDone = checkTaskWithLocal(qrcode: newQrCode, newPoints: newPoints)
            
            let newTask = Tasks(title: newTitle, description: newDescription, points: newPoints, imageSource: newImageSource, qrCode: newQrCode, numberOfTask: newTaskNumber, done: newDone)
            
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
