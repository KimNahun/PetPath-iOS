//
//  PushRangeViewController.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Combine
import NMapsMap
import UIKit

final class PushRangeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PushViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private var didInitialLocationSet = false
    
    // MARK: - UI Components
    
    private let mapView = NMFMapView().then {
        $0.isUserInteractionEnabled = false
        $0.zoomLevel = 11.7
    }
    
    private let rangeView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("001EFF").withAlphaComponent(0.2)
        $0.isHidden = true
    }
    
    private let contentview = UIView()
    
    private let messageLabel = UILabel().then {
        $0.text = "알림 받을 범위"
    }
    
    private let locationLabel = UILabel()
    
    private let slider = UISlider()
        
    private let getPushButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("알림 받기", for: .normal)
    }
    
    private let shortRangeLabel = UILabel().then {
        $0.text = "가까운 동네"
    }
    private let middleRangeLabel = UILabel().then {
        $0.text = "주변 동네"
    }
    private let longRangeLabel = UILabel().then {
        $0.text = "먼 동네"
    }
    private let shortDistanceLabel = UILabel().then {
        $0.text = "1km"
    }
    private let middleDistanceLabel = UILabel().then {
        $0.text = "3km"
    }
    private let longDistanceLabel = UILabel().then {
        $0.text = "5km"
    }
    
    private let dot1 = UIView()
    
    private let dot2 = UIView()
    
    private let dot3 = UIView()
  
    init(viewModel: PushViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        setupTapGestures()
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        slider.value = 1
        getPushButton.addTarget(self, action: #selector(getPushButtonTapped), for: .touchUpInside)
        setupLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("주변 산책 알림 받기")
        requestPermissionsIfNeeded([.location]) { [weak self] isPermit in
            guard let self = self else { return }
            if isPermit {
              
            } else {
                present(PermissionBlockModalViewController(message: "지도에서 위치를 보기 위해서는 권한이 필요합니다.\n설정으로 이동해서 위치 권한을 활설화 해주세요"), animated: true)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rangeView.layer.cornerRadius = rangeView.frame.width / 2
        rangeView.isHidden = false
    }
    
    // MARK: - Bind
    
    private func bind() {
        viewModel.$positionResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] position in
            guard let self = self, let position = position else { return }
            locationLabel.text = position.roadAddress
        }.store(in: &subscriptions)
    }
}

extension PushRangeViewController {
    @objc private func didTapShortLabel() {
        slider.setValue(0, animated: true)
        sliderDidEndSliding(slider)
    }

    @objc private func didTapMiddleLabel() {
        slider.setValue(1, animated: true)
        sliderDidEndSliding(slider)
    }

    @objc private func didTapLongLabel() {
        slider.setValue(2, animated: true)
        sliderDidEndSliding(slider)
    }
    private func setupTapGestures() {
        [shortRangeLabel, shortDistanceLabel, middleRangeLabel, middleDistanceLabel,
         longRangeLabel, longDistanceLabel, dot1, dot2, dot3].forEach {
            $0.isUserInteractionEnabled = true
        }

        // 각각 별도 인스턴스 생성
        shortRangeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShortLabel)))
        shortDistanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShortLabel)))
        dot1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShortLabel)))

        middleRangeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMiddleLabel)))
        middleDistanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMiddleLabel)))
        dot2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMiddleLabel)))

        longRangeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLongLabel)))
        longDistanceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLongLabel)))
        dot3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLongLabel)))
    }
    
    @objc private func getPushButtonTapped() {
        let range: WalkRange
        switch slider.value {
        case 0: range = .short
        case 1: range = .middle
        case 2: range = .long
        default: range = .unknown
        }
        viewModel.modifyRequest = .init(marketing: viewModel.modifyRequest?.marketing ?? false, newWalk: true, newWalkX: viewModel.nowLocation?.x, newWalkY: viewModel.nowLocation?.y, newWalkRange: range)
        viewModel.modifyPushAlertSetting()
    }
    
    private func setupLocation() {
        LocationManager.shared.startUpdatingLocation()
        
        LocationManager.shared.onLocationUpdate = { [weak self] coordinate in
            guard let self = self else { return }

            guard !self.didInitialLocationSet else { return }
            self.didInitialLocationSet = true

            let position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            let update = NMFCameraUpdate(scrollTo: position)
            update.animation = .easeIn
            mapView.positionMode = .direction
            mapView.moveCamera(update)
            viewModel.positionToAddress(lat: coordinate.latitude, lng: coordinate.longitude)
            viewModel.nowLocation = (y: coordinate.latitude, x: coordinate.longitude)
            LocationManager.shared.stopUpdatingLocation()
        }
    }
    @objc private func sliderDidEndSliding(_ sender: UISlider) {
        let snappedValue = round(sender.value)
        sender.setValue(snappedValue, animated: true)
        
        let zoom: Double
        switch Int(snappedValue) {
        case 0: zoom = 13.5
        case 1: zoom = 11.7
        case 2: zoom = 11.0
        default: zoom = 11.7
        }
        
        let update = NMFCameraUpdate(zoomTo: zoom)
        update.animation = .easeIn
        mapView.moveCamera(update)
    }
}

extension PushRangeViewController {
    
    private func setupLayOuts() {
        [mapView, contentview, getPushButton].forEach {
            view.addSubview($0)
        }
        mapView.addSubview(rangeView)
        [messageLabel, locationLabel, dot1, dot2, dot3, slider, shortRangeLabel, shortDistanceLabel, middleRangeLabel, middleDistanceLabel, longRangeLabel, longDistanceLabel].forEach {
            contentview.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(contentview.snp.top)
        }
        rangeView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(23)
            $0.height.equalTo(rangeView.snp.width)
        }
        contentview.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(200)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }
        slider.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(8)
        }
        dot1.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.leading.equalTo(slider)
        }
        dot2.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.centerX.equalTo(slider)
        }
        dot3.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.trailing.equalTo(slider)
        }
        shortRangeLabel.snp.makeConstraints {
            $0.top.equalTo(dot1.snp.bottom)
            $0.leading.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(15)
        }
        middleRangeLabel.snp.makeConstraints {
            $0.top.equalTo(dot1.snp.bottom)
            $0.centerX.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(15)
        }
        longRangeLabel.snp.makeConstraints {
            $0.top.equalTo(dot1.snp.bottom)
            $0.trailing.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(15)
        }
        shortDistanceLabel.snp.makeConstraints {
            $0.top.equalTo(shortRangeLabel.snp.bottom)
            $0.leading.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(14)
        }
        middleDistanceLabel.snp.makeConstraints {
            $0.top.equalTo(shortRangeLabel.snp.bottom)
            $0.centerX.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(14)
        }
        longDistanceLabel.snp.makeConstraints {
            $0.top.equalTo(shortRangeLabel.snp.bottom)
            $0.trailing.equalTo(slider)
            $0.width.equalTo(50)
            $0.height.equalTo(14)
        }
        getPushButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    private func setupComponents() {
        messageLabel.textColor = .dark
        messageLabel.font = FontSet.pretendardBold(size: 16)
        locationLabel.textColor = .neutral9
        locationLabel.font = FontSet.pretendardMedium(size: 13)
        [shortRangeLabel, shortDistanceLabel].forEach {
            $0.textAlignment = .left
        }
        [middleRangeLabel, middleDistanceLabel].forEach {
            $0.textAlignment = .center
        }
        [longRangeLabel, longDistanceLabel].forEach {
            $0.textAlignment = .right
        }
        [shortRangeLabel, middleRangeLabel, longRangeLabel].forEach {
            $0.textColor = .dark
            $0.font = FontSet.pretendardSemiBold(size: 10)
        }
        [shortDistanceLabel, middleDistanceLabel, longDistanceLabel].forEach {
            $0.textColor = .neutral8
            $0.font = FontSet.pretendardSemiBold(size: 10)
        }
        [dot1, dot2, dot3].forEach {
            $0.backgroundColor = ColorSet.fromHex("D9D9D9")
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
        slider.minimumTrackTintColor = ColorSet.fromHex("D9D9D9")
        slider.maximumTrackTintColor = ColorSet.fromHex("D9D9D9")
        slider.thumbTintColor = ColorSet.fromHex("FEE254")
        let thumbImage = UIImage(named: "yellowDot")?.withRenderingMode(.alwaysOriginal)
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
        slider.isContinuous = true
        slider.minimumValue = 0
        slider.maximumValue = 2
        contentview.layer.cornerRadius = 6
        contentview.layer.masksToBounds = true
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
