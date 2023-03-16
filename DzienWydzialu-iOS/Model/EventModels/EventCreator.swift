//
//  eventManager.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 15/03/2023.
//

import UIKit
import FirebaseFirestore

struct EventCreator {
    func createEvent(documentData : [String : Any], collectionType: String ) -> Events? {
        if let newPartner = documentData[K.events.partner] as? String, let newTitle = documentData[K.events.title] as? String, let newImagesource = documentData[K.events.imageSource] as? String, let newTimeStart = documentData[K.events.timeStart] as? Timestamp, let newTimeEnd = documentData[K.events.timeEnd] as? Timestamp {

            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm"
            var newTime = dateFormatter.string(from: newTimeStart.dateValue())

            dateFormatter.dateFormat = "HH:mm"
            let newTimeEndString = dateFormatter.string(from: newTimeEnd.dateValue())

            newTime += " - \(newTimeEndString)"

            var newCollectionType: String
            if collectionType == K.lectures {
                newCollectionType = "Lecture"
            } else {
                newCollectionType = "Workshop"
            }

            let newEvent = Events(eventType: newCollectionType, time: newTime,title: newTitle, partner: newPartner, imageSource: newImagesource)
            return newEvent
        }
        return nil
    }
}
