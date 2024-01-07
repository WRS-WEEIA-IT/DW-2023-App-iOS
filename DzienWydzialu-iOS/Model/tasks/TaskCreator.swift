//
//  TaskCreator.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 15/03/2023.
//

import UIKit

class TaskCreator {
    static func createTask(documentData: [String: Any]) -> Tasks? {
        guard let title = documentData[K.Tasks.title] as? String else { return nil }
        guard let description = documentData[K.Tasks.description] as? String else { return nil }
        guard let imageSource = documentData[K.Tasks.imageSource] as? String else { return nil }
        guard let points = documentData[K.Tasks.points] as? Int else { return nil }
        guard let qrCode = documentData[K.Tasks.qrCode] as? String else { return nil }
        guard let taskNumber = documentData[K.Tasks.taskNumber] as? Int else { return nil }
        
        let done = checkTaskWithLocal(qrcode: qrCode, newPoints: points)
        let newTask = Tasks(
            title: title,
            description: description,
            points: points,
            imageSource: imageSource,
            qrCode: qrCode,
            numberOfTask: taskNumber,
            done: done
        )
        return newTask
    }
    
    static func checkTaskWithLocal(qrcode: String, newPoints: Int) -> Bool {
        if let localCodeArray = K.defaults.sharedUserDefaults.stringArray(forKey: K.defaults.codeArray) {
            if localCodeArray.contains(qrcode) {
                return true
            }
        }
        return false
    }
}
