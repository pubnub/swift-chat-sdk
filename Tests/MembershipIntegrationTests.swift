//
//  MembershipTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest
import PubNubSwiftChatSDK
import PubNubSDK

final class MembershipTests: PubNubSwiftChatSDKIntegrationTests {
  var channel: ChannelImpl!
  var membership: MembershipImpl!

  override func customSetUpWitError() throws {
    channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    membership = try awaitResultValue {
      channel.invite(
        user: chat.currentUser,
        completion: $0
      )
    }
  }

  override func customTearDownWithError() throws {
    try awaitResult {
      chat.deleteChannel(
        id: channel.id,
        completion: $0
      )
    }
    channel = nil
    membership = nil
  }

  func testSetLastReadMessage() throws {
    let message = MessageImpl(
      chat: chat,
      timetoken: Timetoken(Int(Date().timeIntervalSince1970 * 10000000)),
      content: .init(text: "Lorem ipsum"),
      channelId: channel.id,
      userId: chat.currentUser.id
    )
    let value = try awaitResultValue {
      membership.setLastReadMessage(
        message: message,
        completion: $0
      )
    }
    XCTAssertEqual(
      value.lastReadMessageTimetoken,
      message.timetoken
    )
  }

  func testUpdate() throws {
    let newCustom: [String: JSONCodableScalar] = [
      "a": 1,
      "b": "Lorem ipsum",
      "c": 3.557
    ]
    let newValue = try awaitResultValue {
      membership.update(
        custom: newCustom,
        completion: $0
      )
    }
    XCTAssertEqual(
      newCustom.mapValues { $0.scalarValue },
      newValue.custom?.mapValues { $0.scalarValue }
    )
  }

  func testSetLastReadMessageTimetoken() throws {
    let timetoken = Timetoken(Int(Date().timeIntervalSince1970 * 10000000))
    let value = try awaitResultValue { membership.setLastReadMessageTimetoken(timetoken, completion: $0) }

    XCTAssertEqual(
      value.lastReadMessageTimetoken,
      timetoken
    )
  }

  func testGetUnreadMessagesCount() throws {
    for _ in (1...3) {
      try awaitResultValue {
        channel.sendText(
          text: "Some new text",
          completion: $0
        )
      }
    }
    XCTAssertEqual(
      try awaitResultValue(delay: 2) { membership.getUnreadMessagesCount(completion: $0) }, 3
    )
  }

  func testStreamUpdates() throws {
    let expectation = expectation(description: "MembershipStreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let closeable = membership.streamUpdates { [unowned self] membership in
      XCTAssertEqual(membership?.channel.id, self.membership.channel.id)
      XCTAssertEqual(membership?.user.id, self.membership.user.id)
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      membership.update(
        custom: ["a": 1, "b": "Text"],
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock {
      closeable.close()
    }
  }

  func testGlobalStreamUpdates() throws {
    let expectation = expectation(description: "MembershipStreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let closeable = MembershipImpl.streamUpdatesOn(memberships: [membership]) { [unowned self] in
      let receivedMembership = $0[0]
      XCTAssertEqual(receivedMembership.channel.id, membership.channel.id)
      XCTAssertEqual(receivedMembership.user.id, membership.user.id)
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      membership.update(
        custom: ["a": 1, "b": "Text"],
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock {
      closeable.close()
    }
  }
}
