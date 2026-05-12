//
//  Log.swift
//  PetPath
//
//  Created by 김나훈 on 4/15/25.
//

import Foundation
import OSLog

enum Log {
  static func make() -> Logger {
    .init(subsystem: Bundle.main.bundleIdentifier ?? "NONE", category: "")
  }
}
