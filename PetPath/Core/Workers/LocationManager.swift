//
//  LocationManager.swift
//  PetPath
//
//  Created by 김나훈 on 3/25/25.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    // Combine 퍼블리셔
    let locationPublisher = PassthroughSubject<CLLocationCoordinate2D, Never>()
    var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)?
    // 클로저 방식
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    var onAuthorizationDenied: (() -> Void)? // 남겨두긴 함 (필요 시)

    private var isSingleRequest = false

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }

    // MARK: - 1회 요청
    func requestSingleLocation() {
        isSingleRequest = true
        locationManager.requestLocation()
    }
    func requestAuthorizationIfNeeded() {
        let status = locationManager.authorizationStatus // ✅ 기존 인스턴스에서 가져와야 정확
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            onAuthorizationChanged?(status)
            onAuthorizationChanged = nil
        }
    }

    // ✅ iOS 14+ 위치 권한 변경 콜백
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 locationManagerDidChangeAuthorization: \(status.rawValue)")
        onAuthorizationChanged?(status)
    }
    // MARK: - 지속 요청
    func startUpdatingLocation() {
        isSingleRequest = false
        locationManager.allowsBackgroundLocationUpdates = true // ✅ 백그라운드 위치 허용
        locationManager.pausesLocationUpdatesAutomatically = false // ✅ 자동 중단 방지
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let coordinate = location.coordinate
        print("📍 [\(isSingleRequest ? "1회" : "지속")] 위치 업데이트: \(coordinate.latitude), \(coordinate.longitude)")

        locationPublisher.send(coordinate)
        onLocationUpdate?(coordinate)

        if isSingleRequest {
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚨 위치 실패: \(error.localizedDescription)")
    }
}
