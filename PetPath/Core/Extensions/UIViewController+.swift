//
//  UIViewController+.swift
//  PetPath
//
//  Created by 김나훈 on 3/8/25.
//

import UIKit
import AVFoundation

enum PermissionType {
    case notification
    case location
    case camera
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) 
    }
    func requestPermissionsIfNeeded(_ types: [PermissionType], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        var results: [PermissionType: Bool] = [:]

        for type in types {
            switch type {
            case .notification:
                group.enter()
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            switch settings.authorizationStatus {
                            case .authorized, .provisional:
                                results[.notification] = true
                            default:
                                results[.notification] = false
                            }
                            group.leave()
                        }
                    }
                }

            case .location:
                group.enter()
                LocationManager.shared.onAuthorizationChanged = { status in
                    let granted = (status == .authorizedWhenInUse || status == .authorizedAlways)
                    results[.location] = granted

                    if status != .notDetermined {
                        LocationManager.shared.onAuthorizationChanged = nil
                        group.leave()
                    }
                }
                LocationManager.shared.requestAuthorizationIfNeeded()

            case .camera:
                group.enter()
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                switch status {
                case .authorized:
                    results[.camera] = true
                    group.leave()
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        results[.camera] = granted
                        group.leave()
                    }
                default:
                    results[.camera] = false
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            let allGranted = types.allSatisfy { results[$0] == true }
            completion(allGranted)
        }
    }
}
