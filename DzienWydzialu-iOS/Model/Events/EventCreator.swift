//
//  eventManager.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 15/03/2023.
//

import UIKit
import FirebaseFirestore

class EventCreator {
    static func createEvent(documentData : [String : Any], collectionType: String) -> Events? {
        guard let partner = documentData[K.Events.partner] as? String else { return nil }
        guard let title = documentData[K.Events.title] as? String else { return nil }
        guard let imageSource = documentData[K.Events.imageSource] as? String else { return nil }
        guard let timeStart = documentData[K.Events.timeStart] as? Timestamp else { return nil }
        guard let timeEnd = documentData[K.Events.timeEnd] as? Timestamp else { return nil }
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm"
        var newTime = dateFormatter.string(from: timeStart.dateValue())

        dateFormatter.dateFormat = "HH:mm"
        let newTimeEndString = dateFormatter.string(from: timeEnd.dateValue())

        newTime += " - \(newTimeEndString)"

        var newCollectionType: String
        if collectionType == K.lectures {
            newCollectionType = "Lecture"
        } else {
            newCollectionType = "Workshop"
        }

        let newEvent = Events(
            eventType: newCollectionType,
            time: newTime,
            title: title,
            partner: partner,
            imageSource: imageSource
        )
        return newEvent
    }
}
