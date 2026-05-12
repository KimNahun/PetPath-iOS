//
//  FindIdViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/2/25.
//

import Combine

final class FindIdViewModel {

    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private(set) var userId: FindUserIdDTO?
    
    init(userId: FindUserIdDTO?) {
        self.userId = userId
    }
    
}
