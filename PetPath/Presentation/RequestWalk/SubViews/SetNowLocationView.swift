//
//  SetNowLocationView.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import Combine
import NMapsMap
import UIKit

final class SetNowLocationView: UIView, NMFMapViewCameraDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var didHandleInitialLocation = false
    private let viewModel: RequestWalkViewModel
    let selectPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let mapView = NMFMapView()
    
    private let marker = AspectFitImageView().then {
        $0.image = UIImage(named: "mapMarker")
    }
    
    private let whiteView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.masksToBounds = true
    }
    
    private let mainLabel = UILabel().then {
        $0.textColor = .dark
        $0.font = FontSet.pretendardSemiBold(size: 14)
    }
    
    private let subLabel = UILabel().then {
        $0.textColor = .dark
        $0.font = FontSet.pretendardSemiBold(size: 12)
    }
    
    private let detailTextField = UITextField().then {
        $0.font = FontSet.pretendardSemiBold(size: 12)
        $0.tintColor = .neutral7
        $0.textColor = .dark
        $0.backgroundColor = .neutral4
        $0.placeholder = "상세 주소 입력"
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 24))
        $0.leftView = containerView
        $0.leftViewMode = .always
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
    }
    
    private let selectButton = BottomPlacedButton(isSelected: true).then {
        $0.setTitle("이 위치로 픽업 위치 설정", for: .normal)
    }
    
    init(viewModel: RequestWalkViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupLocationTracking()
        bind()
        detailTextField.delegate = self
        setupKeyboardObserver()
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.$positionResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            self?.mainLabel.text = response.roadAddress
            self?.subLabel.text = response.address
        }.store(in: &subscriptions)
    }
    func moveCamera(index: Int) {
        self.isHidden = false
        let result = viewModel.searchedResponse[index]
        let coordinate = CLLocationCoordinate2D(latitude: result.y, longitude: result.x)
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        mapView.moveCamera(cameraUpdate)
    }
}

extension SetNowLocationView {
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let height = keyboardFrame.height
        
        whiteView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(height)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        whiteView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func selectButtonTapped() {
        let request = viewModel.requestWalkRequest
        let finalRequest = viewModel.finalRequest
        viewModel.finalRequest = RequestWalkRequest(dogs: finalRequest.dogs, startAt: finalRequest.startAt, endAt: finalRequest.endAt, requestPath: finalRequest.requestPath, address: mainLabel.text ?? "", pickupX: request.pickupX, pickupY: request.pickupY, pickupDetail: detailTextField.text ?? "", require: finalRequest.require)
        selectPublisher.send()
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let center = mapView.cameraPosition.target
        viewModel.positionToAddress(lat: center.lat, lng: center.lng)
        let request = viewModel.requestWalkRequest
        viewModel.requestWalkRequest = RequestWalkRequest(dogs: request.dogs, startAt: request.startAt, endAt: request.endAt, requestPath: request.requestPath, address: request.address, pickupX: center.lng, pickupY: center.lat, pickupDetail: request.pickupDetail, require: request.require)
    }
    
    private func setupLocationTracking() {
        mapView.addCameraDelegate(delegate: self)
        
        didHandleInitialLocation = false
        
        LocationManager.shared.startUpdatingLocation()
        
        LocationManager.shared.onLocationUpdate = { [weak self] coordinate in
            guard let self = self, !self.didHandleInitialLocation else { return }
            self.didHandleInitialLocation = true
            
            let request = self.viewModel.requestWalkRequest
            LocationManager.shared.stopUpdatingLocation()
            
            let lat = coordinate.latitude
            let lng = coordinate.longitude
            
            self.viewModel.positionToAddress(lat: lat, lng: lng)
            
            self.viewModel.requestWalkRequest = RequestWalkRequest(
                dogs: request.dogs,
                startAt: request.startAt,
                endAt: request.endAt,
                requestPath: request.requestPath,
                address: request.address,
                pickupX: lng,
                pickupY: lat,
                pickupDetail: request.pickupDetail,
                require: request.require
            )
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
            self.mapView.moveCamera(cameraUpdate)
        }
        
        LocationManager.shared.onAuthorizationDenied = {
            ToastMessenger.shared.showToast(message: "위치 권한 거부됨. 설정에서 허용해주세요.")
        }
    }
}

extension SetNowLocationView {
    private func setupLayOuts() {
        [mapView, marker, whiteView, mainLabel, subLabel, detailTextField, selectButton].forEach {
            self.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(whiteView.snp.top)
        }
        marker.snp.makeConstraints {
            $0.centerX.centerY.equalTo(mapView)
        }
        whiteView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(187)
        }
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(whiteView.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(17)
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(14)
        }
        detailTextField.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(43)
        }
        selectButton.snp.makeConstraints {
            $0.top.equalTo(detailTextField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(41)
        }
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        self.backgroundColor = .systemBackground
    }
}
