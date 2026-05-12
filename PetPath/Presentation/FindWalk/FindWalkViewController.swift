//
//  FindWalkViewController.swift
//  PetPath
//
//  Created by 김나훈 on 3/27/25.
//

import Combine
import Foundation
import NMapsMap
import UIKit
import SnapKit

// TODO: 소형견, 중형견, 대형건 색상 구분 전체적으로
// ???: 여기 마커 중복 되는지, 그리고 잘 없어지는지
// TODO: 내 위치 자동으로 따라와지게 수정해야함
final class FindWalkViewController: UIViewController, NMFMapViewCameraDelegate {
    
    private var didInitialLocationSet = false
    
    private var headerTopConstraint: Constraint?
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: FindWalkViewModel
    
    private let mapView = NMFMapView().then {
        $0.minZoomLevel = 14
        $0.maxZoomLevel = 21
        $0.positionMode = .direction
    }
    
    private let headerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = true
    }
    private let penView = UIView().then {
        $0.backgroundColor = ColorSet.fromHex("D9D9D9")
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }
    private let locationButton = UIButton().then {
        $0.setImage(UIImage(named: "location"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.8
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 16
    }
    
    private lazy var tableView = FindWalkTableView(viewModel: viewModel)
    
    private let noWalkLabel = UILabel().then {
        $0.text = "이 주변에는 산책 요청이 없어요"
        $0.isHidden = true
        $0.textColor = .neutral8
        $0.font = FontSet.pretendardBold(size: 14)
    }
    
    private lazy var searchWalkAddressContentViewController = SearchWalkAddressContentViewController(viewModel: viewModel)
    
    // MARK: - Init
    init(viewModel: FindWalkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationRightButtons(keys: ["magnifyingGlass"])
        bind()
        setupGesture()
        setupLocation()
        mapView.positionMode = .direction
        mapView.addCameraDelegate(delegate: self)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle("산책 요청")
        viewModel.nowLocation = viewModel.nowLocation
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.stopUpdatingLocation()
    }
    
    
    private func bind() {
        navigationButtonPublisher(for: "magnifyingGlass")
            .sink { [weak self] in
                guard let self = self else { return }
                let viewController = BottomSheetViewController(contentViewController: searchWalkAddressContentViewController, defaultHeight: UIScreen.main.bounds.height - view.safeAreaInsets.top, cornerRadius: 0, isPannedable: false)
                viewController.modalPresentationStyle = .overFullScreen
                viewController.modalTransitionStyle = .crossDissolve
                present(viewController, animated: true)
            }.store(in: &subscriptions)
        
        tableView.walkIdPublisher.sink { [weak self] id in
            let viewController = WalkerWalkDetailViewController(viewModel: WalkerWalkDetailViewModel(id: id))
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.$getWalkRequestListResponse.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            self?.noWalkLabel.isHidden = response.isEmpty ? false : true
            for item in response {
                let marker = NMFMarker()
                marker.iconImage = NMFOverlayImage(image: UIImage(named: "dogMarker") ?? UIImage())
                marker.position = NMGLatLng(lat: item.pickupY, lng: item.pickupX)
                marker.width = 24
                marker.height = 24
                marker.userInfo = ["id": item.pk]
                marker.mapView = self?.mapView
                
                marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
                    if let marker = overlay as? NMFMarker, let id = marker.userInfo["id"] as? Int {
                        let viewController = WalkerWalkDetailViewController(viewModel: WalkerWalkDetailViewModel(id: id))
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                    return true
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.$tappedResult.receive(on: DispatchQueue.main).dropFirst().sink { [weak self] response in
            self?.dismiss(animated: true)
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: response.y, lng: response.x))
            cameraUpdate.animation = .fly
            self?.mapView.moveCamera(cameraUpdate)
        }.store(in: &subscriptions)
    }
}
extension FindWalkViewController {
    
    @objc private func locationButtonTapped() {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: viewModel.myLocation.y, lng: viewModel.myLocation.x))
        cameraUpdate.animation = .fly
        mapView.moveCamera(cameraUpdate)
        
    }
    private func setupLocation() {
        LocationManager.shared.startUpdatingLocation()
        LocationManager.shared.onLocationUpdate = { [weak self] coordinate in
            guard let self = self else { return }
            let position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            if !self.didInitialLocationSet {
                self.didInitialLocationSet = true
                let update = NMFCameraUpdate(scrollTo: position)
                update.animation = .easeIn
                mapView.positionMode = .direction
                self.mapView.moveCamera(update) 
                viewModel.nowLocation = .init(y: coordinate.latitude, x: coordinate.longitude, zoom: mapView.zoomLevel)
                viewModel.myLocation = .init(y: coordinate.latitude, x: coordinate.longitude, zoom: mapView.zoomLevel)
            }
        }
    }
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        if didInitialLocationSet {
            let zoom = mapView.zoomLevel
            let lat = mapView.cameraPosition.target.lat
            let lng = mapView.cameraPosition.target.lng
            viewModel.nowLocation = .init(y: lat, x: lng, zoom: zoom)
        }
    }
}
// MARK: - Layout & Gesture
extension FindWalkViewController {
    
    private func setupLayouts() {
        [mapView, tableView, locationButton, headerView, noWalkLabel].forEach {
            view.addSubview($0)
        }
        headerView.addSubview(penView)
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        headerView.snp.makeConstraints {
            $0.height.equalTo(21)
            $0.leading.trailing.equalToSuperview()
            self.headerTopConstraint = $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200).constraint
        }
        noWalkLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(77)
            $0.centerX.equalToSuperview()
        }
        penView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(4)
        }
        locationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalTo(headerView.snp.top).offset(-8)
            $0.size.equalTo(32)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).inset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func setupUI() {
        setupLayouts()
        setupConstraints()
        view.backgroundColor = .systemBackground
    }
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        headerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard let constraint = headerTopConstraint else { return }
        
        let currentTop = headerView.frame.origin.y
        let proposedTop = currentTop + translation.y
        
        let minTop = view.safeAreaInsets.top
        let maxTop = view.safeAreaLayoutGuide.layoutFrame.maxY - 200
        
        let clampedTop: CGFloat
        if translation.y < 0 {
            clampedTop = max(proposedTop, minTop)
        } else {
            clampedTop = min(proposedTop, maxTop)
        }
        
        let offsetFromBottom = clampedTop - view.safeAreaLayoutGuide.layoutFrame.maxY
        
        switch gesture.state {
        case .changed:
            constraint.update(offset: offsetFromBottom)
            UIView.performWithoutAnimation {
                view.layoutIfNeeded()
            }
            
        case .ended, .cancelled:
            // 애니메이션 추가
            constraint.update(offset: offsetFromBottom)
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
                self.view.layoutIfNeeded()
            }
            
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: view)
    }
}
