//
//  MessageDraftIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest

@testable import PubNubSwiftChatSDK

class MessageDraftIntegrationTests: BaseClosureIntegrationTestCase {
  private var user: UserImpl!
  private var channel: ChannelImpl!

  override func customSetUpWitError() throws {
    let channelId = "cchnl\(randomString())"
    let userId = "uuser\(randomString())"

    channel = try awaitResultValue {
      chat.createChannel(
        id: channelId,
        name: channelId,
        completion: $0
      )
    }
    user = try awaitResultValue {
      chat.createUser(
        user: UserImpl(chat: chat, id: userId, name: userId),
        completion: $0
      )
    }

    try awaitResultValue {
      channel.invite(
        user: user,
        completion: $0
      )
    }
  }

  override func customTearDownWithError() throws {
    try awaitResult { [unowned self] in
      chat.deleteUser(
        id: user.id,
        completion: $0
      )
    }
    try awaitResult { [unowned self] in
      chat.deleteChannel(
        id: channel.id,
        completion: $0
      )
    }
  }

  func testMessageDraft_WithUserMention() throws {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let messageDraft = channel.createMessageDraft()
    let listener = ClosureMessageDraftChangeListener { elements, future in
      if !elements.containsAnyMention() {
        future.async {
          switch $0 {
          case let .success(suggestedMentions):
            if let mention = suggestedMentions.first {
              messageDraft.insertSuggestedMention(mention: mention, text: mention.replaceWith)
              expectation.fulfill()
            } else {
              XCTFail("Unexpected condition. There's no suggested mentions")
            }
          case let .failure(error):
            XCTFail("Unexpected condition due to error: \(error)")
          }
        }
      }
    }

    messageDraft.addChangeListener(listener)
    messageDraft.update(text: "This is a @uuser")

    wait(for: [expectation], timeout: 6)

    let timetoken = try awaitResultValue {
      messageDraft.send(completion: $0)
    }

    let message = try awaitResultValue(delay: 3) {
      channel.getMessage(
        timetoken: timetoken,
        completion: $0
      )
    }
    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: user.id, target: .user(userId: user.id))
    ]

    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }

  func testMessageDraft_WithChannelMention() throws {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let messageDraft = channel.createMessageDraft()
    let listener = ClosureMessageDraftChangeListener { elements, future in
      if !elements.containsAnyMention() {
        future.async {
          switch $0 {
          case let .success(suggestedMentions):
            if let mention = suggestedMentions.first {
              messageDraft.insertSuggestedMention(mention: mention, text: mention.replaceWith)
              expectation.fulfill()
            } else {
              XCTFail("Unexpected condition. There's no suggested mentions")
            }
          case let .failure(error):
            XCTFail("Unexpected condition due to error: \(error)")
          }
        }
      }
    }

    messageDraft.addChangeListener(listener)
    messageDraft.update(text: "This is a #cchnl")

    wait(for: [expectation], timeout: 6)

    let timetoken = try awaitResultValue {
      messageDraft.send(completion: $0)
    }

    let message = try awaitResultValue(delay: 3) {
      channel.getMessage(
        timetoken: timetoken,
        completion: $0
      )
    }
    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: channel.id, target: .channel(channelId: channel.id))
    ]

    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }

  func testMessageDraft_InsertText() {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let messageDraft = channel.createMessageDraft()
    messageDraft.update(text: "This is a #cchnl")

    let suggestedMention = SuggestedMention(
      offset: 10,
      replaceFrom: "#cchnl",
      replaceWith: channel.name ?? "",
      target: .channel(channelId: channel.id)
    )

    messageDraft.insertSuggestedMention(
      mention: suggestedMention,
      text: suggestedMention.replaceWith
    )

    let listener = ClosureMessageDraftChangeListener { [unowned self] elements, _ in
      XCTAssertEqual(elements.count, 2)
      XCTAssertEqual(elements[0], .plainText(text: "Some prefix. This is a "))
      XCTAssertEqual(elements[1], .link(text: channel.name ?? "", target: .channel(channelId: channel.id)))
      expectation.fulfill()
    }

    messageDraft.addChangeListener(listener)
    messageDraft.insertText(offset: 0, text: "Some prefix. ")

    wait(for: [expectation], timeout: 6)
  }

  func testMessageDraft_RemoveText() {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let messageDraft = channel.createMessageDraft()
    messageDraft.update(text: "This is a #cchnl")

    let suggestedMention = SuggestedMention(
      offset: 10,
      replaceFrom: "#cchnl",
      replaceWith: channel.name ?? "",
      target: .channel(channelId: channel.id)
    )

    messageDraft.insertSuggestedMention(
      mention: suggestedMention,
      text: suggestedMention.replaceWith
    )

    let listener = ClosureMessageDraftChangeListener { [unowned self] elements, _ in
      XCTAssertEqual(elements.count, 1)
      XCTAssertEqual(elements[0], .link(text: channel.name ?? "", target: .channel(channelId: channel.id)))
      expectation.fulfill()
    }

    messageDraft.addChangeListener(listener)
    messageDraft.removeText(offset: 0, length: 10)

    wait(for: [expectation], timeout: 6)
  }

  func testMessageDraft_RemoveMention() {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let messageDraft = channel.createMessageDraft()
    messageDraft.update(text: "This is a #cchnl")

    let suggestedMention = SuggestedMention(
      offset: 10,
      replaceFrom: "#cchnl",
      replaceWith: channel.name ?? "",
      target: .channel(channelId: channel.id)
    )

    messageDraft.insertSuggestedMention(
      mention: suggestedMention,
      text: suggestedMention.replaceWith
    )

    let listener = ClosureMessageDraftChangeListener { [unowned self] elements, _ in
      XCTAssertEqual(elements[0], .plainText(text: "This is a \(channel.name ?? "")"))
      expectation.fulfill()
    }

    messageDraft.addChangeListener(listener)
    messageDraft.removeMention(offset: suggestedMention.offset)

    wait(for: [expectation], timeout: 6)
  }

  func testMessageDraft_InsertingTextInCurrentMentionRange() {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let originalText = "This is a #cchnl"
    let messageDraft = channel.createMessageDraft()

    messageDraft.update(text: originalText)

    let suggestedMention = SuggestedMention(
      offset: 10,
      replaceFrom: "#cchnl",
      replaceWith: channel.name ?? "",
      target: .channel(channelId: channel.id)
    )

    messageDraft.insertSuggestedMention(
      mention: suggestedMention,
      text: suggestedMention.replaceWith
    )

    let listener = ClosureMessageDraftChangeListener { elements, _ in
      XCTAssertEqual(elements.count, 1)
      XCTAssertFalse(elements[0].isLink())
      expectation.fulfill()
    }

    messageDraft.addChangeListener(listener)
    messageDraft.insertText(offset: 12, text: "_!!!!!_")

    wait(for: [expectation], timeout: 6)
  }

  func testMessageDraft_RemovingTextInCurrentMentionRange() {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let originalText = "This is a #cchnl"
    let messageDraft = channel.createMessageDraft()

    messageDraft.update(text: originalText)

    let suggestedMention = SuggestedMention(
      offset: 10,
      replaceFrom: "#cchnl",
      replaceWith: channel.name ?? "",
      target: .channel(channelId: channel.id)
    )

    messageDraft.insertSuggestedMention(
      mention: suggestedMention,
      text: suggestedMention.replaceWith
    )

    let listener = ClosureMessageDraftChangeListener { elements, _ in
      XCTAssertEqual(elements.count, 1)
      XCTAssertFalse(elements[0].isLink())
      expectation.fulfill()
    }

    messageDraft.addChangeListener(listener)
    messageDraft.removeText(offset: 12, length: 5)

    wait(for: [expectation], timeout: 6)
  }

  func testMessageDraft_WithQuotedMessage() throws {
    let originalText = "This is some text"
    let messageDraft = channel.createMessageDraft()

    let quotedMessage = MessageImpl(
      chat: chat,
      timetoken: 17_296_737_530_374_172,
      content: .init(text: "Lorem ipsum"),
      channelId: channel.id,
      userId: user.id
    )

    messageDraft.update(text: originalText)
    messageDraft.quotedMessage = quotedMessage

    let timetoken = try awaitResultValue {
      messageDraft.send(
        completion: $0
      )
    }
    let message = try awaitResultValue(delay: 2) {
      channel.getMessage(
        timetoken: timetoken,
        completion: $0
      )
    }

    let receivedQuotedMessage = try XCTUnwrap(message?.quotedMessage)

    XCTAssertEqual(receivedQuotedMessage.timetoken, 17_296_737_530_374_172)
    XCTAssertEqual(receivedQuotedMessage.text, "Lorem ipsum")
  }
}
