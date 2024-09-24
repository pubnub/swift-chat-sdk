//
//  GetCurrentUserMentionsResult.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

public struct GetCurrentUserMentionsResult<M: Message> {
  public var enhancedMentionsData: [UserMentionDataWrapper<M>]
  public var isMore: Bool
}

public struct UserMentionDataWrapper<M> {
  public var userMentionData: any UserMentionData<M>
}

public protocol UserMentionData<M> {
  associatedtype M: Message

  var event: EventContent.Mention { get }
  var message: M? { get }
  var userId: String { get }
}

public struct ChannelMentionData<M: Message>: UserMentionData {
  public var event: EventContent.Mention
  public var message: M?
  public var userId: String
  public var channelId: String
}

public struct ThreadMentionData<M: Message>: UserMentionData {
  public var event: EventContent.Mention
  public var message: M?
  public var userId: String
  public var parentChannelId: String
  public var threadChannelId: String
}
