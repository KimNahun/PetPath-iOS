//
//  GetKeywordTagList.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//


struct GetKeywordTagListDTO: Decodable {
    let char, require: [String]
}

extension GetKeywordTagListDTO {
    func toDomain() -> KeywordTagList {
        let charTags = char.map { KeywordTag(name: $0, isSelected: false) }
        let requireTags = require.map { KeywordTag(name: $0, isSelected: false) }
        return KeywordTagList(charTags: charTags, requireTags: requireTags)
    }
}
