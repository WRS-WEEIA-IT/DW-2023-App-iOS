//  Constants.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import UIKit

struct K {
    static let eventCellIdentifier = "ReusableEventCell"
    static let taskCellIdentifier = "ReusableTaskCell"
    static let taskCellCollectionIdentifier = "ReusableTaskCellCollection"
    
    static let eventNibName = "EventCell"
    static let taskNibName = "TaskCell"
    static let taskCollectionNibName = "TaskCellCollection"
    static let alertNibName = "AlertViewController"
    static let taskAlertNibName = "TaskAlert"
    
    static let lectures = "lectures"
    static let workshops = "workshops"
    
    static let rowHeight : CGFloat = 180
    static let qrFrameWidth = 200.0
    static let qrFrameHeight = 200.0
    
    struct contestTime {
        static let endTime = "endTime"
    }
    
    struct defaults {
        static let sharedUserDefaults = UserDefaults.standard
        static let codeArray = "qrCodes"
        static let codeId = "idCode"
        static let points = "points"
    }
    
    struct Events {
        static let eventType = "eventType"
        static let timeStart = "timeStart"
        static let timeEnd = "timeEnd"
        static let partner = "partner"
        static let title = "title"
        static let imageSrc = "imageSrc"
        static let room = "room"
    }
    
    struct Tasks {
        static let title = "title"
        static let imageSrc = "imageSrc"
        static let description = "description"
        static let points = "points"
        static let qrCode = "qrCode"
        static let taskId = "taskId"
    }
    
    struct TabBarIndex {
        static let home = 0
        static let events = 1
        static let qr = 2
        static let tasks = 3
        static let info = 4
    }
}
