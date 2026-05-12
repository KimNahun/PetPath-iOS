//
//  ModifyDogViewModel.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Combine
import Foundation
// TODO: 이미지 수정 버그 대응. 로딩 스피너 추가? 완료 handler?
final class ModifyDogViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let dogId: Int
    private let getMyDogListUseCase = GetMyDogListUseCaseImpl(repository: DogRepositoryImpl())
    private let getKeywordTagListUseCase = GetKeywordTagListUseCaseImpl(repository: DogRepositoryImpl())
    private let getMyDogDetailUseCase = GetMyDogDetailUseCaseImpl(repository: DogRepositoryImpl())
    private let modifyDogInfoUseCase = ModifyDogInfoUseCaseImpl(repository: DogRepositoryImpl())
    private let getDogCertInfoValidUseCase = GetDogCertInfoValidUseCaseImpl(repository: DogRepositoryImpl())
    private let fileUploadUseCase = FileUploadUseCaseImpl(repository: UtilRepositoryImpl())
    @Published var charTags: [KeywordTag] = []
    @Published var requireTags: [KeywordTag] = []
    
    let dogInfoPublisher = PassthroughSubject<GetMyDogDetailDTO, Never>()
    let modifySuccessPublisher = PassthroughSubject<Void, Never>()
    let certSuccessPublisher = PassthroughSubject<Void, Never>()
    @Published var modifyDogInfoRequest = ModifyDogInfoRequest()
    @Published var getDogCertInfoValidRequest = GetDogCertInfoValidRequest(ownerName: "", registNumber: "")
    
    @Published private(set) var certButtonEnabled: Bool = false
    init(dogId: Int) {
        self.dogId = dogId
        bind()
    }
    
    func fileUpload(imageData: Data) {
        Task {
            do {
                let token = try await fileUploadUseCase.execute(fileData: imageData, fileName: "dog_profile5.jpg")
                modifyDogInfoRequest.profileImage = token
            } catch let error as CommonAPIError<FileUploadError> {
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
    
    func getDogCertValidInfo() {
        Task {
            do {
                let response = try await getDogCertInfoValidUseCase.execute(request: getDogCertInfoValidRequest)
                modifyDogInfoRequest.dogName = response.dogName
                modifyDogInfoRequest.species = response.species
                modifyDogInfoRequest.registNumber = getDogCertInfoValidRequest.registNumber
                modifyDogInfoRequest.ownerName = getDogCertInfoValidRequest.ownerName
                modifyDogInfoRequest.isVerified = true
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
                getMyDogDetail()
            } catch let error as CommonAPIError<GetKeywordTagListError> {
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
    
    func getMyDogDetail() {
        Task {
            do {
                let response =  try await getMyDogDetailUseCase.execute(id: dogId)
                modifyDogInfoRequest = response.toModifyDogInfo()
                dogInfoPublisher.send(response)
                
                charTags = charTags.map { tag in
                    var updatedTag = tag
                    updatedTag.isSelected = response.char.contains(tag.name)
                    return updatedTag
                }
                requireTags = requireTags.map { tag in
                    var updatedTag = tag
                    updatedTag.isSelected = response.char.contains(tag.name)
                    return updatedTag
                }
            } catch let error as CommonAPIError<GetMyDogDetailError> {
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
    
    func modifyDogInfo() {
        Task {
            do {
                _ =  try await modifyDogInfoUseCase.execute(request: modifyDogInfoRequest)
                modifySuccessPublisher.send()
            } catch let error as CommonAPIError<ModifyDogInfoError> {
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
    
    private func bind() {
        $charTags.sink { [weak self] updatedTags in
            guard let self = self else { return }
            self.modifyDogInfoRequest.char = updatedTags.filter { $0.isSelected }.map { $0.name }
        }.store(in: &subscriptions)
        
        
        $requireTags.sink { [weak self] updatedTags in
            guard let self = self else { return }
            self.modifyDogInfoRequest.require = updatedTags.filter { $0.isSelected }.map { $0.name }
        }.store(in: &subscriptions)
        
        $getDogCertInfoValidRequest  
            .map { !$0.registNumber.isEmpty && !$0.ownerName.isEmpty }
            .assign(to: \.certButtonEnabled, on: self)
            .store(in: &subscriptions)
    }
}

