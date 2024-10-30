// CallManager.swift
import Foundation
import CallKit
import Contacts
import SwiftUI

class CallManager: NSObject, ObservableObject {
    let callObserver = CXCallObserver()
    var calls: [UUID: CallStatus] = [:]
    var callLog: [CallLogEntry] = []
    private var callStartTimes: [UUID: Date] = [:]
    private let storage = CallStorageManager()
    var lastDialedNumber: String?
    
    override init() {
        super.init()
        callObserver.setDelegate(self, queue: nil)
        loadCallLog()
    }
    
    func initiatePhoneCall(to contact: CNContact) {
        guard let number = contact.phoneNumbers.first?.value.stringValue else { return }
        if let url = URL(string: "tel://\(number)") {
            lastDialedNumber = number;
            UIApplication.shared.open(url)
        }
    }
    
    func initiatePhoneCall(to number: String) {
        if let url = URL(string: "tel://\(number)") {
            lastDialedNumber = number;
            UIApplication.shared.open(url)
        }
    }
    
    private func endCallAndLogEntry(uuid: UUID) {
        guard let startTime = callStartTimes[uuid],
              let call = calls[uuid] else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let logEntry = CallLogEntry(id: uuid,
                                    number: call.number,
                                    contact: call.contact,
                                    date: startTime,
                                    duration: duration,
                                    isOutgoing: call.isOutgoing)
        
        callLog.insert(logEntry, at: 0)
        storage.saveCall(logEntry)
        
        calls.removeValue(forKey: uuid)
        callStartTimes.removeValue(forKey: uuid)
    }

    func queryCallLogs(filters: [String: Any]) -> [CallLogEntry] {
        var callLogEntries: [CallLogEntry] = []
        
        var predicate = NSPredicate(value: true)
        
        // Handle date range
        if let dateFrom = filters["dateFrom"] as? String,
        let dateTo = filters["dateTo"] as? String {
        let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let fromDate = dateFormatter.date(from: dateFrom),
                let toDate = dateFormatter.date(from: dateTo) {
                predicate = NSPredicate(format: "date >= %@ AND date <= %@", fromDate as CVarArg, toDate as CVarArg)
            }
        }
        
        // Handle duration range
        if let durationFrom = filters["durationFrom"] as? Int,
        let durationTo = filters["durationTo"] as? Int {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                NSPredicate(format: "duration >= %d AND duration <= %d", durationFrom, durationTo)
            ])
        }
        
        // Handle name filter
        if let name = filters["name"] as? String {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                NSPredicate(format: "contactName CONTAINS[c] %@", name)
            ])
        }
        
        // Handle number filter
        if let number = filters["number"] as? String {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                NSPredicate(format: "number CONTAINS[c] %@", number)
            ])
        }
        
        // Handle call type (isOutgoing)
        if let isOutgoing = filters["isOutgoing"] as? Bool {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                NSPredicate(format: "isOutgoing == %@", NSNumber(value: isOutgoing))
            ])
        }
        
        let filteredCallLog = callLog.filter { entry in
            predicate.evaluate(with: entry)
        }
        
        return filteredCallLog
    }
    
    private func loadCallLog() {
        callLog = storage.loadCalls()
    }

    func clearStorage() {
        storage.clear()
        callLog = []
    }
}

extension CallManager: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded {
            endCallAndLogEntry(uuid: call.uuid)
        } else if call.hasConnected {
            callStartTimes[call.uuid] = Date()
            updateCallStatus(for: call, status: .Connecting, number: lastDialedNumber)
        } else if call.isOutgoing {
            updateCallStatus(for: call, status: .Outgoing, number: lastDialedNumber)
        } else if call.isOnHold {
            updateCallStatus(for: call, status: .OnHold, number: lastDialedNumber)
        } else {
            updateCallStatus(for: call, status: .Incoming, number: "")
        }
    }
    
    private func updateCallStatus(for call: CXCall, status: CallCurrentStatus, number: String? = "") {
        DispatchQueue.main.async {
            if(self.calls.keys.contains(call.uuid)) {
                self.calls[call.uuid]?.currentStatus = status;
            } else {
                /// find contact based on [number]
                self.calls[call.uuid] =
                            CallStatus(id: call.uuid,
                                       number: number ?? "",
                                       isOutgoing: call.isOutgoing,
                                       currentStatus: status,
                                       contact: nil) // We'll update the contact later if possible
            }
           
        }
    }
}
