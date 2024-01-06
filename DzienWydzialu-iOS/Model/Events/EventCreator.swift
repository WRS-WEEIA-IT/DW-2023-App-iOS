//
//  eventManager.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 15/03/2023.
//

import UIKit
import FirebaseFirestore

class EventCreator {
    static func createEvent(documentData: [String: Any], collectionType: String) -> Events? {
        guard let partner = documentData[K.Events.partner] as? String else { return nil }
        guard let title = documentData[K.Events.title] as? String else { return nil }
        guard let imageSource = documentData[K.Events.imageSource] as? String else { return nil }
        guard let timeStart = documentData[K.Events.timeStart] as? Timestamp else { return nil }
        guard let timeEnd = documentData[K.Events.timeEnd] as? Timestamp else { return nil }
        guard let hall = documentData[K.Events.hall] as? String else { return nil }
        
        let time = getTimeFormat(timeStart: timeStart, timeEnd: timeEnd)
        var eventType = collectionType == K.lectures ? "Lecture" : "Workshop"

        let newEvent = Events(
            eventType: eventType,
            time: time,
            title: title,
            partner: partner,
            imageSource: imageSource,
            hall: hall
        )
        return newEvent
    }
    
    private static func getTimeFormat(timeStart: Timestamp, timeEnd: Timestamp) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm"
        var time = dateFormatter.string(from: timeStart.dateValue())

        dateFormatter.dateFormat = "HH:mm"
        let newTimeEndString = dateFormatter.string(from: timeEnd.dateValue())

        time += " - \(newTimeEndString)"
        return time
    }
}
