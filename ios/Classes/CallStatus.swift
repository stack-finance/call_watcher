// CallStatus.swift
import Foundation
import Contacts

struct CallStatus: Identifiable {
    let id: UUID
    let number: String
    var isOutgoing: Bool
    var currentStatus: CallCurrentStatus
    var contact: CNContact?
}

enum CallCurrentStatus {
    case Incoming;
    case Outgoing;
    case Connecting;
    case OnHold;
    case Ended;
}


struct CallLogEntry: Identifiable, Codable {
    let id: UUID
    let number: String
    let contactName: String?
    let date: Date
    let duration: TimeInterval
    let isOutgoing: Bool
    
    init(id: UUID, number: String, contact: CNContact?, date: Date, duration: TimeInterval, isOutgoing: Bool) {
        self.id = id
        self.number = number
        self.contactName = contact?.givenName
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

class CallStorageManager {
    private let userDefaults = UserDefaults.standard
    private let callLogKey = "CallLog"
    
    func saveCall(_ call: CallLogEntry) {
        var calls = loadCalls()
        calls.insert(call, at: 0)
        if let encoded = try? JSONEncoder().encode(calls) {
            userDefaults.set(encoded, forKey: callLogKey)
        }
    }
    
    func loadCalls() -> [CallLogEntry] {
        if let data = userDefaults.data(forKey: callLogKey),
           let calls = try? JSONDecoder().decode([CallLogEntry].self, from: data) {
            return calls
        }
        return []
    }

    func clear() {
        userDefaults.removeObject(forKey: callLogKey)
    }
}

/// date util extension to get millisecondsSinceEpoch
extension Date {
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    var iso8601: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)  // Use UTC time zone

        return isoFormatter.string(from: self)
    }
}