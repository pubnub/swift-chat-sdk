//
//  PubNub.ObjectSortField.swift
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

extension PubNub.ObjectSortField {
  func transform() -> PNSortKey<PNKey>? {
    switch property {
    case .id:
      return ascending ? PNSortKeyPNAsc(key: .id) : PNSortKeyPNDesc(key: .id)
    case .name:
      return ascending ? PNSortKeyPNAsc(key: .name) : PNSortKeyPNDesc(key: .name)
    case .type:
      return ascending ? PNSortKeyPNAsc(key: .type) : PNSortKeyPNDesc(key: .type)
    case .status:
      return ascending ? PNSortKeyPNAsc(key: .status) : PNSortKeyPNDesc(key: .status)
    case .updated:
      return ascending ? PNSortKeyPNAsc(key: .updated) : PNSortKeyPNDesc(key: .updated)
    }
  }
}
