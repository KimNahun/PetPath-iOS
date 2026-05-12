//
//  String+.swift
//  PetPath
//
//  Created by 김나훈 on 3/20/25.
//

import Foundation

extension String {
    func calculateAge() -> (year: String, month: String)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let birthDate = dateFormatter.date(from: self) else { return nil }
        
        let calendar = Calendar.current
        let today = Date()
        
        // ✅ 년, 월 차이 계산
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: today) // 🔥 변경: birthDate → today 순서 변경
        
        guard let year = components.year, let month = components.month else { return nil }
        
        return (String(abs(year)), String(abs(month))) // 🔥 절댓값 처리
    }
    func extractYearMonth() -> (year: String, month: String)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        return (String(year), String(month))
    }
    func extractDateUsingFormatter() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // ✅ 밀리초(.000Z)까지 포함
        
        guard let date = formatter.date(from: self) else { return "날짜 변환 실패" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.timeZone = TimeZone(identifier: "UTC") // ✅ UTC 기준 변환
        
        return outputFormatter.string(from: date)
    }
    
    func extractDateComponentsFromISO() -> (year: String, month: String, day: String, weekday: String, hour: String, minute: String, second: String) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = formatter.date(from: self)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: self)
        }

        guard let date else { return ("", "", "", "", "", "", "") }

        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone.current  

        let components = calendar.dateComponents(in: timeZone, from: date)

        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second,
              let weekdayIndex = components.weekday else {
            return ("", "", "", "", "", "", "")
        }

        let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = weekdaySymbols[(weekdayIndex - 1) % 7]

        return (
            year: String(year),
            month: String(format: "%02d", month),
            day: String(format: "%02d", day),
            weekday: weekday,
            hour: String(format: "%02d", hour),
            minute: String(format: "%02d", minute),
            second: String(format: "%02d", second)
        )
    }
    func padLeft(count: Int, with char: Character = "0") -> String {
            return String(repeating: char, count: max(0, count - self.count)) + self
        }
}
