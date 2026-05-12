//
//  TimeContentViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/24/25.
//

import Combine
import UIKit

final class TimeContentViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: RequestWalkViewModel
    
    private let messageLabel = UILabel().then {
        $0.text = "산책 시간 설정"
        $0.textColor = .dark
        $0.font = FontSet.pretendardBold(size: 20)
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage(named: "chevronLeft"), for: .normal)
    }
    
    private let reloadButton = UIButton().then {
        $0.setImage(UIImage(named: "reload"), for: .normal)
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .neutral5
    }
    
    private let startTimeLabel = UILabel().then {
        $0.text = "산책 시작"
    }
    private let endTimeLabel = UILabel().then {
        $0.text = "산책 종료"
    }
    
    private let segmentedControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.selectedSegmentIndex = 0
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ColorSet.neutral11, NSAttributedString.Key.font: FontSet.pretendardMedium(size: 14)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ColorSet.neutral11, NSAttributedString.Key.font: FontSet.pretendardMedium(size: 14)], for: .selected)
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = .neutral8
    }
    
    private let startPickerView = WalkTimePickerView()
    private let endPickerView = WalkTimePickerView().then {
        $0.isHidden = true
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private let selectButton = BottomPlacedButton()
    
    
    init(viewModel: RequestWalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        segmentedControl.addTarget(self, action: #selector(segmentDidChanged), for: .valueChanged)
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        startPickerView.scrollToCurrentTime()
        endPickerView.scrollToCurrentTime()
        setPickerStartAddedTime()
        [startTimeLabel, endTimeLabel].enumerated().forEach { index, label in
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            label.tag = index
        }
    }
    
    private func bind() {
        startPickerView.datePublisher.sink { [weak self] date in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            let dateString = formatter.string(from: date)
            self?.viewModel.requestWalkRequest.startAt = dateString
        }.store(in: &subscriptions)
        
        endPickerView.datePublisher.sink { [weak self] date in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            let dateString = formatter.string(from: date)
            self?.viewModel.requestWalkRequest.endAt = dateString
        }.store(in: &subscriptions)
        
        viewModel.$requestWalkRequest.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] request in
            let startTime = request.startAt.extractDateComponentsFromISO()
            let endTime = request.endAt.extractDateComponentsFromISO()
            self?.segmentedControl.removeAllSegments()
            self?.segmentedControl.insertSegment(withTitle: "\(startTime.month)/\(startTime.day) (\(startTime.weekday)) \(startTime.hour):\(startTime.minute)", at: 0, animated: false)
            self?.segmentedControl.insertSegment(withTitle: "\(endTime.month)/\(endTime.day) (\(endTime.weekday)) \(endTime.hour):\(endTime.minute)", at: 1, animated: false)
        }.store(in: &subscriptions)
        
        viewModel.$computedResult.receive(on: DispatchQueue.main).sink { [weak self] computedResult in
            if computedResult.success {
                self?.selectButton.setTitle("총 \(computedResult.priceText) 이용", for: .normal)
            } else {
                self?.selectButton.setTitle(computedResult.priceText.isEmpty ? "시간을 설정해주세요" : computedResult.priceText, for: .normal)
            }
            self?.selectButton.setupButtonStatus(isSelected: computedResult.success)
        }.store(in: &subscriptions)
    }
}
extension TimeContentViewController {
    private func setPickerStartAddedTime() {
        let currentDate = endPickerView.getSelectedDate()
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "Asia/Seoul") {
            calendar.timeZone = timeZone
        }
        let startNewDate = calendar.date(byAdding: .minute, value: 30, to: currentDate) ?? Date()
        let endNewDate = calendar.date(byAdding: .minute, value: 60, to: currentDate) ?? Date()
        startPickerView.setDate(startNewDate)
        endPickerView.setDate(endNewDate)
    }
    @objc private func selectButtonTapped() {
        let request = viewModel.requestWalkRequest
        let newRequest = viewModel.finalRequest
        viewModel.finalRequest = RequestWalkRequest(dogs: newRequest.dogs, startAt: request.startAt, endAt: request.endAt, requestPath: newRequest.requestPath, address: newRequest.address, pickupX: newRequest.pickupX, pickupY: newRequest.pickupY, pickupDetail: newRequest.pickupDetail, require: newRequest.require)
        dismiss(animated: true)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func labelTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        segmentedControl.selectedSegmentIndex = index
        segmentDidChanged(segmentedControl)
    }
    @objc private func reloadButtonTapped() {
        if startPickerView.isHidden {
            endPickerView.scrollToCurrentTime()
        } else {
            startPickerView.scrollToCurrentTime()
        }
    }
    
    @objc private func segmentDidChanged(_ sender: UISegmentedControl) {
        underlineView.snp.remakeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.equalTo(sender.selectedSegmentIndex == 0 ? view.snp.leading : view.snp.centerX)
            $0.trailing.equalTo(sender.selectedSegmentIndex == 0 ? view.snp.centerX : view.snp.trailing)
            $0.height.equalTo(3)
        }
        endPickerView.isHidden = sender.selectedSegmentIndex == 0
        startPickerView.isHidden = sender.selectedSegmentIndex == 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc private func timeButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        var offsetMinutes = 0
        switch title {
        case "+ 10분": offsetMinutes = 10
        case "+ 30분": offsetMinutes = 30
        case "+ 1시간": offsetMinutes = 60
        case "- 30분": offsetMinutes = -30
        default: return
        }
        let currentDate: Date
        if startPickerView.isHidden {
            currentDate = endPickerView.getSelectedDate()
        } else {
            currentDate = startPickerView.getSelectedDate()
        }
        
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "Asia/Seoul") {
            calendar.timeZone = timeZone
        }
        let newDate = calendar.date(byAdding: .minute, value: offsetMinutes, to: currentDate) ?? Date()
        if startPickerView.isHidden {
            endPickerView.setDate(newDate)
        } else {
            startPickerView.setDate(newDate)
        }
    }
}

extension TimeContentViewController {
    private func setupLayOuts() {
        [backButton, messageLabel, reloadButton, separatorView, startTimeLabel, endTimeLabel, segmentedControl, underlineView, startPickerView, endPickerView, buttonStackView, selectButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(24)
        }
        messageLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }
        reloadButton.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(24)
        }
        separatorView.snp.makeConstraints {
            $0.top.equalTo(reloadButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        startTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.centerX)
            $0.top.equalTo(separatorView.snp.bottom)
            $0.height.equalTo(37)
        }
        endTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(view.snp.centerX)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(separatorView.snp.bottom)
            $0.height.equalTo(37)
        }
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(endTimeLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        underlineView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(view.snp.centerX)
            $0.height.equalTo(3)
        }
        startPickerView.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(205)
        }
        endPickerView.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(205)
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(startPickerView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(26)
        }
        selectButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    private func setupComponents() {
        [startTimeLabel, endTimeLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .neutral11
            $0.font = FontSet.pretendardMedium(size: 14)
        }
    }
    
    private func setupStackView() {
        let titles = ["+ 10분", "+ 30분", "+ 1시간", "- 30분"]
        
        titles.forEach { title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.neutral7, for: .normal)
            button.titleLabel?.font = FontSet.pretendardMedium(size: 12)
            button.backgroundColor = .clear
            button.layer.borderColor = ColorSet.neutral7.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 12
            button.snp.makeConstraints { $0.width.equalTo(60) }
            button.addTarget(self, action: #selector(timeButtonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        buttonStackView.distribution = .equalSpacing
        buttonStackView.alignment = .center
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        setupStackView()
        self.view.backgroundColor = .systemBackground
    }
}
