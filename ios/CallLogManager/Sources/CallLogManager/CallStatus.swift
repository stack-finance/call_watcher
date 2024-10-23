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

