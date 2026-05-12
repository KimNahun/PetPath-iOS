//
//  CharTag.swift
//  PetPath
//
//  Created by 김나훈 on 3/18/25.
//

import Foundation

struct KeywordTagList {
    let charTags: [KeywordTag]
    let requireTags: [KeywordTag]
}

struct KeywordTag: Hashable {
    let name: String
    var isSelected: Bool
}
