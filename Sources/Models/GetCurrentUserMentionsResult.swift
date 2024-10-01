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

/// Represents the result of fetching all instances where a specific user was mentioned in channels or threads
public struct GetCurrentUserMentionsResult<M: Message> {
  /// An array of ``UserMentionDataWrapper`` objects representing the details of each mention of the user
  public var enhancedMentionsData: [UserMentionDataWrapper<M>]
  /// Indicates whether there are more mentions available beyond the current result set
  public var isMore: Bool
}

// This class was introduced due to the lack of support for runtime parameterized protocols, which are available starting from iOS 16.
// We will be able to remove this class once we increase the deployment target.

/// A struct that wraps ``UserMentionData``
public struct UserMentionDataWrapper<M> {
  /// Stores the underlying mention data
  public var userMentionData: any UserMentionData<M>
}

/// A protocol representing the data related to a user mention event
public protocol UserMentionData<M> {
  associatedtype M: Message

  /// The content containing information about the mention event
  var event: EventContent.Mention { get }
  /// The message object associated with the mention, if available
  var message: M? { get }
  /// The ID of the user who was mentioned
  var userId: String { get }
}

/// Represents data related to a mention of a user in a channel
public struct ChannelMentionData<M: Message>: UserMentionData {
  /// The content containing information about the mention event
  public var event: EventContent.Mention
  /// The message object associated with the mention, if available
  public var message: M?
  /// The ID of the user who was mentioned
  public var userId: String
  /// The ID of the channel in which the user was mentioned
  public var channelId: String
}

/// Represents data related to a mention of a user in a thread channel
public struct ThreadMentionData<M: Message>: UserMentionData {
  /// The content containing information about the mention event
  public var event: EventContent.Mention
  /// The message object associated with the mention, if available
  public var message: M?
  /// The ID of the user who was mentioned
  public var userId: String
  /// The ID of the parent channel where the thread exists
  public var parentChannelId: String
  /// The ID of the thread channel in which the user was mentioned
  public var threadChannelId: String
}
