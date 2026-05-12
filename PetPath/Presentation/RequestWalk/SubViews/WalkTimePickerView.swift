//
//  WalkTimePickerView.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class WalkTimePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    let datePublisher = PassthroughSubject<Date, Never>()

    private let pickerView = UIPickerView()
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return cal
    }()

    private lazy var days: [Date] = {
        let now = Date()
        return (0...29).compactMap {
            calendar.date(byAdding: .day, value: $0, to: now)
        }
    }()

    // ✅ 시간: 0~23 * 3세트 = 72개
    private let hours = Array(0..<72)
    
    // ✅ 분: 0,10,...50 * 3세트 = 18개
    private let minutes = stride(from: 0, to: 180, by: 10).map { $0 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        scrollToCurrentTime()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        pickerView.delegate = self
        pickerView.dataSource = self
        addSubview(pickerView)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1

        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 4 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return days.count
        case 1: return hours.count
        case 2: return 1
        case 3: return minutes.count
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 120
        case 1, 3: return 50
        case 2: return 20
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.frame.height / 3
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = component == 0 ? UIFont.systemFont(ofSize: 25) : UIFont.systemFont(ofSize: 36)

        switch component {
        case 0:
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd(E)"
            formatter.locale = Locale(identifier: "ko_KR")
            label.text = formatter.string(from: days[row])
        case 1:
            label.text = String(format: "%02d", hours[row] % 24)
        case 2:
            label.text = ":"
        case 3:
            label.text = String(format: "%02d", minutes[row] % 60)
        default:
            break
        }
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        datePublisher.send(getSelectedDate())
    }

    func getSelectedDate() -> Date {
        let day = days[pickerView.selectedRow(inComponent: 0)]
        let rawHour = hours[pickerView.selectedRow(inComponent: 1)]
        let rawMinute = minutes[pickerView.selectedRow(inComponent: 3)]
        let hour = rawHour % 24
        let minute = rawMinute % 60
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? Date()
    }

    func setDate(_ date: Date) {
        let hour = calendar.component(.hour, from: date)
        let minute = (calendar.component(.minute, from: date) / 10) * 10

        guard
            let dayIndex = days.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }),
            let baseHourIndex = hours.firstIndex(where: { $0 % 24 == hour }),
            let baseMinuteIndex = minutes.firstIndex(where: { $0 % 60 == minute })
        else { return }

        let hourIndex = baseHourIndex + 24   // 0~23 → 24~47
        let minuteIndex = baseMinuteIndex + 6 // 0~5 → 6~11

        pickerView.selectRow(dayIndex, inComponent: 0, animated: true)
        pickerView.selectRow(hourIndex, inComponent: 1, animated: true)
        pickerView.selectRow(minuteIndex, inComponent: 3, animated: true)

        datePublisher.send(getSelectedDate())
    }

    func scrollToCurrentTime() {
        setDate(Date())
    }
}
