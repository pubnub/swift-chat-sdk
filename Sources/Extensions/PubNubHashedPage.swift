//
//  PubNubHashedPage.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat
import PubNubSDK

extension PubNubHashedPage {
  func transform() -> PNPage? {
    if let start {
      PNPage.PNNext(pageHash: start)
    } else if let end {
      PNPage.PNPrev(pageHash: end)
    } else {
      nil
    }
  }
}
