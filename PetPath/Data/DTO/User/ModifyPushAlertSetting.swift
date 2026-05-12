//
//  ModifyPushAlertSetting.swift
//  PetPath
//
//  Created by 김나훈 on 4/27/25.
//

import Foundation

struct ModifyPushAlertSettingRequest: Encodable {
    var marketing: Bool
    var newWalk: Bool
    var newWalkX: Double?
    var newWalkY: Double?
    var newWalkRange: WalkRange?
}
