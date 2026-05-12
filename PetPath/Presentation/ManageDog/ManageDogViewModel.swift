//
//  ManageDogViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Combine

final class ManageDogViewModel {
    
    private let getMyDogListUseCase = GetMyDogListUseCaseImpl(repository: DogRepositoryImpl())
    @Published var dogList: [DogData] = []
 
    
    
    func getMyDogList()  {
        Task {
            do {
                dogList = try await getMyDogListUseCase.execute()
            }
        }
    }
}
