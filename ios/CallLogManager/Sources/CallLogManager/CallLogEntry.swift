//
//  CallLogEntry.swift
//  CallLogManager
//
//  Created by Dhikshith Reddy on 23/10/24.
//
import Foundation
import Contacts

struct CallLogEntry: Identifiable, Codable {
    let id: UUID
    let number: String
    let contactName: String?
    let date: Date
    let duration: TimeInterval
    let isOutgoing: Bool
    
    init(id: UUID, number: String, contactName: String?, date: Date, duration: TimeInterval, isOutgoing: Bool) {
        self.id = id
        self.number = number
        self.contactName = contactName
        self.date = date
        self.duration = duration
        self.isOutgoing = isOutgoing
    }

    func toMap() -> [String: Any] {
        return [
            "id": id.uuidString,
            "number": number,
            "contactName": contactName ?? "",
            "date": date.iso8601,
            "duration": Int(duration.rounded()),
            "isOutgoing": isOutgoing
        ]
    }
}
