//
//  AddDogViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/17/25.
//

import Foundation
import Combine

// TODO: 강아지 숫자 제한, 텍스트 입력시 클라 검증? . 괜히 뒤돌아 올듯. 03이랑 3 둘다 되는지 확인 필요.
// TODO: 컬렉션뷰 동적 높이 전체적으로 수정필요

final class AddDogViewModel {
    
    private let getDogCertInfoValidUseCase = GetDogCertInfoValidUseCaseImpl(repository: DogRepositoryImpl())
    private let getKeywordTagListUseCase = GetKeywordTagListUseCaseImpl(repository: DogRepositoryImpl())
    private let registMyDogUseCase = RegistMyDogUseCaseImpl(repository: DogRepositoryImpl())
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var registRequest = RegistMyDogRequest()
    private(set) var registMyDogResponse: RegistMyDogDTO?
    
    @Published var charTags: [KeywordTag] = []
    @Published var requireTags: [KeywordTag] = []
    
    @Published private(set) var isCertButtonEnabled: Bool = false
    @Published private(set) var primaryNextButtonEnabled: Bool = false
    @Published private(set) var personalityNextButtonEnabled: Bool = false
    
    let certSuccessPublisher = PassthroughSubject<Void, Never>()
    let registerSuccessPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        setupBindings()
    }
    
   
    func registMyDog() {
        Task {
            do {
                registMyDogResponse = try await registMyDogUseCase.execute(request: registRequest)
                registerSuccessPublisher.send()
            } catch let error as CommonAPIError<RegistMyDogError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific:
                    ToastMessenger.shared.showToast(message: error.message ?? "")
                }
            }
        }
    }
    
    func getCertInfo() {
        
        Task {
            do {
                _ = try await getDogCertInfoValidUseCase.execute(request: GetDogCertInfoValidRequest(ownerName: registRequest.ownerName ?? "", registNumber: registRequest.registNumber ?? ""))
                certSuccessPublisher.send()
            } catch let error as CommonAPIError<GetDogCertInfoValidError> {
                switch error.code {
                case .common(let commonError):
                    switch commonError {
                    case .network, .decode, .unknown:
                        ToastMessenger.shared.showToast(message: "네트워크 오류가 발생했습니다.")
                    case .unidentified:
                        ToastMessenger.shared.showToast(message: error.message ?? "")
                    }
                case .specific:
                    ToastMessenger.shared.showToast(message: error.message ?? "")
                }
            }
        }
        
    }
    
    func getKeywordTagList() {
        
        Task {
            do {
                let response = try await getKeywordTagListUseCase.execute()
                charTags = response.charTags
                requireTags = response.requireTags
            }
        }
        
    }
}

extension AddDogViewModel {
    private func setupBindings() {
        Publishers.CombineLatest4(
            $registRequest.map { $0.registNumber ?? "" },
            $registRequest.map { $0.ownerName ?? "" },
            $registRequest.map { $0.birthYear ?? "" },
            $registRequest.map { $0.birthMonth ?? "" }
        )
        .map { registerNumber, ownerName, birthYear, birthMonth in
            return !registerNumber.isEmpty && !ownerName.isEmpty && !birthYear.isEmpty && !birthMonth.isEmpty
        }
        .assign(to: &$isCertButtonEnabled)
        let firstCombine = Publishers.CombineLatest4(
            $registRequest.map { $0.species ?? "" },
            $registRequest.map { $0.dogName ?? "" },
            $registRequest.map { $0.birthYear ?? "" },
            $registRequest.map { $0.birthMonth ?? "" }
        )
        
        let secondCombine = Publishers.CombineLatest(
            $registRequest.map { $0.gender != nil },
            $registRequest.map { $0.isNeuter != nil }
        )
        
        Publishers.CombineLatest(firstCombine, secondCombine)
            .map { firstValues, secondValues in
                let (species, dogName, birthYear, birthMonth) = firstValues
                let (hasGender, hasNeuter) = secondValues
                
                return !species.isEmpty && !dogName.isEmpty &&
                !birthYear.isEmpty && !birthMonth.isEmpty &&
                hasGender && hasNeuter
            }
            .assign(to: &$primaryNextButtonEnabled)
        
        Publishers.CombineLatest(
                $registRequest.map { $0.char.count >= 2 },
                $registRequest.map { $0.size != nil }
            )
            .map { hasEnoughCharacters, hasSize in
                return hasEnoughCharacters && hasSize
            }
            .assign(to: &$personalityNextButtonEnabled)
        
        $charTags.sink { [weak self] updatedTags in
                guard let self = self else { return }
                self.registRequest.char = updatedTags.filter { $0.isSelected }.map { $0.name }
            }.store(in: &cancellables)
        
        
        $requireTags.sink { [weak self] updatedTags in
            guard let self = self else { return }
            self.registRequest.require = updatedTags.filter { $0.isSelected }.map { $0.name }
        }.store(in: &cancellables)
    }
}
