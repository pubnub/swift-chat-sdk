//
//  MessageDraft.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import PubNubChat

/// An object that refers to a single message that has not been published yet.
public protocol MessageDraft {
  /// An associated Channel type
  associatedtype C: Channel
  /// An associated Message type
  associatedtype M: Message

  /// The ``Channel`` where this ``MessageDraft`` will be published
  var channel: C { get }
  /// Whether modifying the message text triggers the typing indicator on ``channel``
  var isTypingIndicatorTriggered: Bool { get }
  /// The limit on the number of users returned when searching for users to mention
  var userLimit: Int { get }
  /// The limit on the number of channels returned when searching for channels to reference
  var channelLimit: Int { get }
  /// Can be used to set a ``Message`` to quote when sending this ``MessageDraft``
  var quotedMessage: M? { get set }
  /// Can be used to attach files to send with this ``MessageDraft``
  var files: [InputFile] { get set }

  /// Add a ``MessageDraftChangeListener`` to listen for changes to the contents of this ``MessageDraft``, as well as
  /// to retrieve the current mention suggestions for users and channels (e.g. when the message draft contains "... @name ..." or "... #chann ...").
  ///
  /// - Parameter listener: The ``MessageDraftChangeListener`` that will receive the most current message elements list and suggestions list
  func addChangeListener(_ listener: MessageDraftChangeListener)

  /// Remove the given ``MessageDraftChangeListener`` from active listeners.
  ///
  /// - Parameter listener: A listener to remove
  func removeChangeListener(_ listener: MessageDraftChangeListener)

  /// Insert some text into the ``MessageDraft`` text at the given offset.
  ///
  /// - Parameters:
  ///   - offset: The position from the start of the message draft where insertion will occur
  ///   - text: The text to insert at the given offset
  func insertText(offset: Int, text: String)

  /// Remove a number of characters from the ``MessageDraft`` text at the given offset.
  ///
  /// - Parameters:
  ///   - offset: The position from the start of the message draft where removal will occur
  ///   - length: The number of characters to remove, starting at the given offset
  func removeText(offset: Int, length: Int)

  /// Insert mention into the ``MessageDraft`` according to ``SuggestedMention/offset``, ``SuggestedMention/replaceFrom`` and ``SuggestedMention/target``.
  ///
  /// - Parameters:
  ///   - mention: A ``SuggestedMention`` that can be obtained from ``MessageDraftStateListener``
  ///   - text: The text to replace ``SuggestedMention/replaceFrom`` with. ``SuggestedMention/replaceTo`` can be used for example
  func insertSuggestedMention(mention: SuggestedMention, text: String)

  /// Add a mention to a user, channel or link specified by `target` at the given offset.
  ///
  /// - Parameters:
  ///   - offset: The start of the mention
  ///   - length: The number of characters (length) of the mention
  ///   - target: The target of the mention, e.g. ``MentionTarget/user(userId:)``, ``MentionTarget/channel(channelId:)`` or ``MentionTarget/url(url:)``
  func addMention(offset: Int, length: Int, target: MentionTarget)

  /// Remove a mention starting at the given offset, if any.
  ///
  /// - Parameter offset: The start of the mention to remove
  func removeMention(offset: Int)

  /// Update the whole message draft text with a new value.
  ///
  /// Internally, ``MessageDraft`` will try to calculate the most optimal set of insertions and removals that will convert the current text
  /// to the provided `text`,, in order to preserve any mentions.
  /// This is a best effort operation, and if any mention text is found to be modified, the mention will be invalidated and removed.
  ///
  /// - Parameter text: A new text value
  func update(text: String)

  /// Send the ``MessageDraft``, along with its ``files`` and ``quotedMessage`` if any, on the ``channel``.
  ///
  /// The `ttl` defines if/how long (in hours) the message should be stored in Message Persistence:
  ///  * - if `shouldStore` = `true`, and `ttl` = `0`, the message is stored with no expiry time
  ///  * - if `shouldStore` =  `true` and ttl = `X`, the message is stored with an expiry time of `X` hours
  ///  * - if `shouldStore` = `false`, the `ttl` parameter is ignored
  ///  * - if `ttl` is not specified, then the expiration of the message defaults back to the expiry value for the keyset
  ///
  /// - Parameters:
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  ///   - completion: The async `Result` of the method call
  ///     - **Success**: The timetoken of the sent message
  ///     - **Failure**: An `Error` describing the failure
  func send(
    meta: [String: JSONCodable]?,
    shouldStore: Bool,
    usePost: Bool,
    ttl: Int?,
    completion: ((Swift.Result<Timetoken, Error>) -> Void)?
  )
}

/// Enum describing the source for getting user suggestions for mentions.
public enum UserSuggestionSource {
  /// Search for users globally
  case global
  /// Search only for users that are members of this channel
  case channel

  func transform() -> PubNubChat.MessageDraftUserSuggestionSource {
    switch self {
    case .global:
      return .global
    case .channel:
      return .channel
    }
  }
}

/// Part of a ``Message`` or ``MessageDraft`` content.
public enum MessageElement: Equatable {
  /// Element that contains plain text, without any additional metadata or links
  case plainText(text: String)
  /// Element that has attached metadata, specifically a mention described by `target`
  case link(text: String, target: MentionTarget)

  static func from(element: PubNubChat.MessageElement) -> MessageElement? {
    if let plainTextElement = element as? PubNubChat.MessageElementPlainText {
      return .plainText(text: plainTextElement.text)
    } else if let linkElement = element as? PubNubChat.MessageElementLink, let target = MentionTarget.from(target: linkElement.target) {
      return .link(text: linkElement.text, target: target)
    } else {
      return nil
    }
  }
  
  func isLink() -> Bool {
    switch self {
    case .plainText:
      return false
    case .link:
      return true
    }
  }

  func transform() -> PubNubChat.MessageElement {
    switch self {
    case let .plainText(text):
      return MessageElementPlainText(text: text)
    case let .link(text, target):
      return MessageElementLink(text: text, target: target.transform())
    }
  }
}

public extension Array where Element == MessageElement {
  /// Returns `true` if the underlying Array contains any mention (user/channel)
  func containsAnyMention() -> Bool {
    reduce(into: false) { accumulatedResult, currentElement in
      accumulatedResult = accumulatedResult || currentElement.isLink()
    }
  }
}

/// Defines the target of the mention attached to a ``MessageDraft``.
public enum MentionTarget: Equatable {
  /// Mention a user identified by `userId`
  case user(userId: String)
  /// Reference a channel identified by `channelId`
  case channel(channelId: String)
  /// Link to `url`
  case url(url: String)

  func transform() -> PubNubChat.MentionTarget {
    switch self {
    case let .channel(channelId):
      return MentionTargetChannel(channelId: channelId)
    case let .user(userId):
      return MentionTargetUser(userId: userId)
    case let .url(url):
      return MentionTargetUrl(url: url)
    }
  }

  static func from(target: PubNubChat.MentionTarget) -> MentionTarget? {
    if let channelTarget = target as? PubNubChat.MentionTargetChannel {
      return .channel(channelId: channelTarget.channelId)
    } else if let userTarget = target as? PubNubChat.MentionTargetUser {
      return .user(userId: userTarget.userId)
    } else if let urlTarget = target as? PubNubChat.MentionTargetUrl {
      return .url(url: urlTarget.url)
    } else {
      return nil
    }
  }
}

/// A potential mention suggestion received from ``MessageDraftStateListener``.
///
/// It can be used with ``MessageDraft/insertSuggestedMention(mention:text:)`` to accept the suggestion and attach a mention to a message draft.
public struct SuggestedMention {
  /// The offset where the mention starts
  public let offset: Int
  /// The original text at the `offset` in the message draft text
  public let replaceFrom: String
  /// The suggested replacement for the `replaceFrom` text, e.g. the user's full name
  public let replaceWith: String
  /// The target of the mention, such as a user, channel or URL
  public let target: MentionTarget

  func transform() -> PubNubChat.SuggestedMention {
    PubNubChat.SuggestedMention(
      offset: Int32(offset),
      replaceFrom: replaceFrom,
      replaceWith: replaceWith,
      target: target.transform()
    )
  }

  static func from(mention: PubNubChat.SuggestedMention) -> SuggestedMention? {
    guard let target = MentionTarget.from(target: mention.target) else {
      return nil
    }
    return SuggestedMention(
      offset: Int(mention.offset),
      replaceFrom: mention.replaceFrom,
      replaceWith: mention.replaceWith,
      target: target
    )
  }
}

public extension Array where Element == SuggestedMention {
  /// Utility function for filtering suggestions for a specific position in the message draft text.
  ///
  /// - Parameter position: The cursor position in the message draft text
  func getSuggestionsFor(position: Int) -> [SuggestedMention] {
    MessageDraftKt.getSuggestionsFor(compactMap { $0.transform() }, position: Int32(position)).compactMap { SuggestedMention.from(mention: $0) }
  }
}
