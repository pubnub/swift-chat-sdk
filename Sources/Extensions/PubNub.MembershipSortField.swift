//
//  PubNub.MembershipSortField.swift
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

extension PubNub.MembershipSortField {
  func transform() -> PNSortKey<PNMembershipKey>? {
    switch property {
    case let .object(objectSortProperty):
      switch objectSortProperty {
      case .id:
        return ascending ? PNSortKeyPNAsc(key: PNMembershipKey.channelId) : PNSortKeyPNDesc(key: .channelId)
      case .name:
        return ascending ? PNSortKeyPNAsc(key: PNMembershipKey.channelName) : PNSortKeyPNDesc(key: .channelName)
      case .updated:
        return ascending ? PNSortKeyPNAsc(key: PNMembershipKey.channelUpdated) : PNSortKeyPNDesc(key: .channelUpdated)
      case .type, .status:
        return nil
      }
    case .type, .status:
      return nil
    case .updated:
      return ascending ? PNSortKeyPNAsc(key: PNMembershipKey.updated) : PNSortKeyPNDesc(key: .updated)
    }
  }
}
