//
//  TimeWorker.swift
//  PetPath
//
//  Created by 김나훈 on 5/18/25.
//

import Foundation

final class TimeWorker {
    
    static let shared = TimeWorker()
    
    private init() {}
    
    func getCurrentLocalTime() -> String {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: now)
    }
    
    func calculateTimeDiff(from start: String, to end: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone.current
        print(start)
        print(end)
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else {
            return "0분"
        }
        
        let diff = Int(endDate.timeIntervalSince(startDate))
        guard diff > 0 else { return "0분" }
        
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        
        switch (hours, minutes) {
        case (let h, let m) where h > 0 && m > 0:
            return "\(h)시간 \(m)분"
        case (let h, _) where h > 0:
            return "\(h)시간"
        default:
            return "\(minutes)분"
        }
    }
    
}
