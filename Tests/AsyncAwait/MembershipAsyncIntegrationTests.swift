//
//  MembershipAsyncIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import XCTest

@testable import PubNubSwiftChatSDK

class MembershipAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  var channel: ChannelImpl!
  var membership: MembershipImpl!

  override func customSetup() async throws {
    channel = try await chat.createChannel(id: randomString())
    membership = try await channel.invite(user: chat.currentUser)
  }

  override func customTearDown() async throws {
    try await chat.deleteChannel(id: channel.id)

    channel = nil
    membership = nil
  }

  func testMembershipAsync_SetLastReadMessage() async throws {
    let message = MessageImpl(
      chat: chat,
      timetoken: Timetoken(Int(Date().timeIntervalSince1970 * 10_000_000)),
      content: .init(text: "Lorem ipsum"),
      channelId: channel.id,
      userId: chat.currentUser.id
    )

    let updatedMembership = try await membership.setLastReadMessage(message: message)
    XCTAssertEqual(updatedMembership.lastReadMessageTimetoken, message.timetoken)
  }

  func testMembershipAsync_Update() async throws {
    let newCustom: [String: JSONCodableScalar] = ["a": 1, "b": "Lorem ipsum", "c": 3.557]
    let updatedMembership = try await membership.update(custom: newCustom)

    XCTAssertEqual(
      newCustom.mapValues { $0.scalarValue },
      updatedMembership.custom?.mapValues { $0.scalarValue }
    )
  }

  func testMembershipAsync_SetLastReadMessageTimetoken() async throws {
    let timetoken = Timetoken(Int(Date().timeIntervalSince1970 * 10_000_000))
    let updatedMembership = try await membership.setLastReadMessageTimetoken(timetoken)

    XCTAssertEqual(updatedMembership.lastReadMessageTimetoken, timetoken)
  }

  func testMembershipAsync_GetUnreadMessagesCount() async throws {
    try await channel.sendText(text: "Some text 1")
    try await channel.sendText(text: "Some text 2")
    try await channel.sendText(text: "Some text 3")
    try await Task.sleep(nanoseconds: 2_000_000_000)

    let unreadMessagesCount = try await membership.getUnreadMessagesCount()
    XCTAssertEqual(unreadMessagesCount, 3)
  }

  func testMembershipAsync_GetUnreadMessagesCountForEmptyChannel() async throws {
    let someMembership = MembershipImpl(
      chat: chat,
      channel: channel,
      user: UserImpl(chat: chat, id: randomString())
    )

    let unreadMessagesCount = try await someMembership.getUnreadMessagesCount()
    XCTAssertNil(unreadMessagesCount)
  }

  func testMembershipAsync_StreamUpdates() async throws {
    let expectation = expectation(description: "MembershipStreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let expectedCustom: [String: JSONCodableScalar] = [
      "a": 1,
      "b": "Text"
    ]

    let task = Task {
      for await updatedMembership in membership.streamUpdates() {
        XCTAssertEqual(updatedMembership?.channel.id, membership.channel.id)
        XCTAssertEqual(updatedMembership?.user.id, membership.user.id)
        XCTAssertEqual(updatedMembership?.custom?.mapValues { $0.scalarValue }, expectedCustom.mapValues { $0.scalarValue })
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await membership.update(custom: expectedCustom)

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock {
      task.cancel()
    }
  }

  func testMembershipAsync_GlobalStreamUpdates() async throws {
    let expectation = expectation(description: "MembershipStreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let expectedCustom: [String: JSONCodableScalar] = [
      "a": 1,
      "b": "Text"
    ]

    let task = Task {
      for await receivedMembership in MembershipImpl.streamUpdatesOn(memberships: [membership]) {
        XCTAssertEqual(receivedMembership.first?.channel.id, membership.channel.id)
        XCTAssertEqual(receivedMembership.first?.user.id, membership.user.id)
        XCTAssertEqual(receivedMembership.first?.custom?.mapValues { $0.scalarValue }, expectedCustom.mapValues { $0.scalarValue })
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await membership.update(custom: expectedCustom)

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock {
      task.cancel()
    }
  }
}
