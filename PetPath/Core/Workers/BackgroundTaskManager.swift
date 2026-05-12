//
//  BackgroundTaskManager.swift
//  PetPath
//
//  Created by 김나훈 on 5/12/26.
//

import BackgroundTasks
import Foundation

final class BackgroundTaskManager {

    static let shared = BackgroundTaskManager()
    private init() {}

    static let appRefreshIdentifier = "com.petpath.app.refresh"

    private let currentWalkCacheKey = "cachedCurrentWalks"
    private let getMainCurrentWalkUseCase = GetMainCurrentWalkListUsecaseImpl(repository: WalkRepositoryImpl())

    // MARK: - 등록 (AppDelegate에서 호출)
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.appRefreshIdentifier,
            using: nil
        ) { [weak self] task in
            guard let appRefreshTask = task as? BGAppRefreshTask else { return }
            self?.handleAppRefresh(task: appRefreshTask)
        }
    }

    // MARK: - 스케줄 (sceneDidEnterBackground에서 호출)
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.appRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("BGTask 스케줄 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 캐시된 산책 목록 조회
    func cachedCurrentWalks() -> [GetMainCurrentWalkListDTO] {
        guard let data = UserDefaults.standard.data(forKey: currentWalkCacheKey),
              let walks = try? JSONDecoder().decode([GetMainCurrentWalkListDTO].self, from: data) else {
            return []
        }
        return walks
    }

    // MARK: - 핸들러
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let backgroundTask = Task {
            do {
                let walks = try await getMainCurrentWalkUseCase.execute()
                if let data = try? JSONEncoder().encode(walks) {
                    UserDefaults.standard.set(data, forKey: currentWalkCacheKey)
                }
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            backgroundTask.cancel()
            task.setTaskCompleted(success: false)
        }
    }
}
