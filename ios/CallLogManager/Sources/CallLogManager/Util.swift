//
//  Util.swift
//  CallLogManager
//
//  Created by Dhikshith Reddy on 23/10/24.
//

import Foundation

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

extension String {
    var dateFromIso8601: Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)  
        
        return isoFormatter.date(from: self)
    }
}


extension TimeInterval {
    var inSeconds : Int {
        return Int(self.rounded())
    }
}
