//
//  MessageDraftAsyncIntegrationTests.swift
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

class MessageDraftIntegrationTests: BaseAsyncIntegrationTestCase {
  private var user: UserImpl!
  private var channel: ChannelImpl!

  override func customSetup() async throws {
    let channelId = "cchnl\(randomString())"
    let userId = "uuser\(randomString())"
    
    channel = try await chat.createChannel(id: channelId, name: channelId)
    user = try await chat.createUser(user: UserImpl(chat: chat, id: userId, name: userId))
    
    try await channel.invite(user: user)
  }
  
  override func customTearDown() async throws {
    _ = try? await chat.deleteUser(id: user.id)
    _ = try? await chat.deleteChannel(id: channel.id)
  }

  func testMessageDraft_WithUserMention() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
    
    let timetoken = try await messageDraft.send()
    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await channel.getMessage(timetoken: timetoken)

    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: user.id, target: .user(userId: user.id))
    ]

    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }

  func testMessageDraft_WithChannelMention() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
    
    let timetoken = try await messageDraft.send()
    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await channel.getMessage(timetoken: timetoken)

    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: channel.id, target: .channel(channelId: channel.id))
    ]

    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }

  func testMessageDraft_InsertText() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testMessageDraft_RemoveText() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testMessageDraft_RemoveMention() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testMessageDraft_InsertingTextInCurrentMentionRange() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testMessageDraft_RemovingTextInCurrentMentionRange() async throws {
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

    await fulfillment(of: [expectation], timeout: 6)
  }

  func testMessageDraft_WithQuotedMessage() async throws {
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

    let timetoken = try await messageDraft.send()
    try await Task.sleep(nanoseconds: 2_000_000_000)
    let message = try await channel.getMessage(timetoken: timetoken)
    let receivedQuotedMessage = try XCTUnwrap(message?.quotedMessage)

    XCTAssertEqual(receivedQuotedMessage.timetoken, 17_296_737_530_374_172)
    XCTAssertEqual(receivedQuotedMessage.text, "Lorem ipsum")
  }
}
