//
//  DogRepository.swift
//  PetPath
//
//  Created by 김나훈 on 3/12/25.
//

import Foundation

protocol DogRepository {
    func getMyDogList() async throws -> [DogData]
    func getDogCertInfoValid(request: GetDogCertInfoValidRequest) async throws -> GetDogCertInfoValidDTO
    func getKeywordTagList() async throws -> GetKeywordTagListDTO
    func registMyDog(request: RegistMyDogRequest) async throws -> RegistMyDogDTO
    func getMyDogDetail(id: Int) async throws -> GetMyDogDetailDTO
    func modifyDogInfo(request: ModifyDogInfoRequest) async throws -> EmptyResponse
    func deleteMyDog(id: Int) async throws -> EmptyResponse
}

