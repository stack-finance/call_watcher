// CallManager.swift
import Foundation
import CallKit
import Contacts
import SwiftUI

class CallLogManager: NSObject, ObservableObject {
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
                                    contactName: call.contact?.givenName,
                                    date: startTime,
                                    duration: duration,
                                    isOutgoing: call.isOutgoing)
        
        callLog.insert(logEntry, at: 0)
        let _ = storage.save(logEntry)
        
        
        calls.removeValue(forKey: uuid)
        callStartTimes.removeValue(forKey: uuid)
    }
    
    private func loadCallLog() {
        callLog = storage.getAllCallLogs()
    }

    func clearStorage() -> Bool {
        callLog = []
        return storage.clear()
    }
}

extension CallLogManager: CXCallObserverDelegate {
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
                self.calls[call.uuid] = CallStatus(
                    id: call.uuid,
                    number: number ?? "",
                    isOutgoing: call.isOutgoing,
                    currentStatus: status,
                    contact: nil) // We'll update the contact later if possible
            }
           
        }
    }
}
