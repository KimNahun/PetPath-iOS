//
//  PushWalkPositionManager.swift
//  PetPath
//
//  Created by 김나훈 on 5/16/25.
//

import Foundation
import CoreLocation
import Combine

final class PushWalkPositionManager {

    static let shared = PushWalkPositionManager()
    private let pushWalkPositionUseCase = PushWalkPositionUseCaseImpl(repository: WalkRepositoryImpl())

    private var cancellable: AnyCancellable?
    private var isRunning = false
    private(set) var walkId: Int?

    // Timer 대신 마지막 전송 시각으로 간격 제어 (백그라운드에서도 동작)
    private var lastPushTime: Date = .distantPast
    private let pushInterval: TimeInterval = 3.0

    private init() {}

    func setWalkId(id: Int) {
        walkId = id
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastPushTime = .distantPast

        LocationManager.shared.startUpdatingLocation()

        // 위치 업데이트마다 호출됨 (백그라운드 포함)
        // 3초 간격 제어는 Date 비교로 처리
        cancellable = LocationManager.shared.locationPublisher
            .sink { [weak self] coordinate in
                guard let self else { return }
                let now = Date()
                guard now.timeIntervalSince(self.lastPushTime) >= self.pushInterval else { return }
                self.lastPushTime = now
                self.pushWalkPosition(y: coordinate.latitude, x: coordinate.longitude)
            }
    }

    func stop() {
        LocationManager.shared.stopUpdatingLocation()
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
    }

    private func pushWalkPosition(y: Double, x: Double) {
        guard let id = walkId else { return }
        Task {
            do {
                _ = try await pushWalkPositionUseCase.execute(request: .init(walk: id, x: x, y: y))
            } catch let error as CommonAPIError<PushWalkPositionError> {
                switch error.code {
                case .common: break
                case .specific: break
                }
            }
        }
    }
}
