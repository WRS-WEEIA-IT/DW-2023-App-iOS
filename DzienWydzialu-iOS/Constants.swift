//
//  K.swift
//  DzienWydzialu-iOS
//
//  Created by Bartek Chadryś on 22/02/2023.
//

import Foundation

struct K {
    static let eventCellIdentifier = "ReusableEventCell"
    static let taskCellIdentifier = "ReusableTaskCell"
    static let eventNibName = "EventCell"
    static let taskNibName = "TaskCell"
    
    static let buttonColor = "buttonColor"
    static let buttonAction = "buttonPressed"
    static let rowHeight : CGFloat = 180
    static let lectures = "lectures"
    static let workshops = "workshops"
    
    struct events {
        static let eventType = "eventType"
        static let timeStart = "timeStart"
        static let timeEnd = "timeEnd"
        static let partner = "partner"
        static let title = "title"
        static let imageSource = "imageSource"
    }
    
    struct tasks {
        static let title = "title"
        static let imageSource = "imageSource"
        static let description = "description"
        static let points = "points"
    }
    
    struct images {
        
    }
}
