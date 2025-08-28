//
//  AnalyticsEventsInfo.swift
//  MobileAssignment
//
//  Created by KavinduDissanayake on 2025-08-28.
//

import Foundation

// MARK: - Core Architecture - Analytics & Base Classes
struct AnalyticsEventsInfo {
    let name: String
    let timeStamp: String
}

protocol AnalyticsIdentifiable {
    var analyticsEventInfo: AnalyticsEventsInfo { get }
}

extension AnalyticsIdentifiable {
    var analyticsEventInfo: AnalyticsEventsInfo {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timeStamp = formatter.string(from: Date())
        return AnalyticsEventsInfo(name: String(describing: self), timeStamp: timeStamp)
    }
}

protocol ActionIdType: Hashable, AnalyticsIdentifiable {}
protocol UIActionType: Hashable, AnalyticsIdentifiable {}
