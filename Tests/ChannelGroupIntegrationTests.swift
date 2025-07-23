//
//  ChannelGroupIntegrationTests.swift
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

final class ChannelGroupIntegrationTests: BaseClosureIntegrationTestCase {
  var channelGroup: ChannelGroupImpl!
  var channel: ChannelImpl!
  var secondChannel: ChannelImpl!

  override func customSetUpWitError() throws {
    channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    secondChannel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    channelGroup = chat.getChannelGroup(id: randomString())
  }

  override func customTearDownWithError() throws {
    try awaitResult {
      chat.removeChannelGroup(
        id: channelGroup.id,
        completion: $0
      )
    }
    try awaitResult {
      channel.delete(
        soft: false,
        completion: $0
      )
    }
    try awaitResult {
      secondChannel.delete(
        soft: false,
        completion: $0
      )
    }
  }

  func testChannelGroup_AddChannels() throws {
    try awaitResultValue {
      channelGroup.add(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    let responseValue = try awaitResultValue {
      channelGroup.listChannels(
        completion: $0
      )
    }

    XCTAssertEqual(responseValue.page?.totalCount, 2)
    XCTAssertEqual(Set(responseValue.channels.map { $0.id }), Set([channel.id, secondChannel.id]))
  }

  func testChannelGroup_AddChannelIdentifiers() throws {
    try awaitResultValue {
      channelGroup.addChannelIdentifiers(
        [channel.id, secondChannel.id],
        completion: $0
      )
    }

    let responseValue = try awaitResultValue {
      channelGroup.listChannels(
        completion: $0
      )
    }

    XCTAssertEqual(responseValue.page?.totalCount, 2)
    XCTAssertEqual(Set(responseValue.channels.map { $0.id }), Set([channel.id, secondChannel.id]))
  }

  func testChannelGroup_RemoveChannels() throws {
    try awaitResultValue {
      channelGroup.add(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    try awaitResultValue {
      channelGroup.remove(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    let responseValue = try awaitResultValue {
      channelGroup.listChannels(
        completion: $0
      )
    }

    XCTAssertEqual(responseValue.page?.totalCount, 0)
    XCTAssertTrue(responseValue.channels.isEmpty)
  }

  func testChannelGroup_RemoveChannelIdentifiers() throws {
    try awaitResultValue {
      channelGroup.addChannelIdentifiers(
        [channel.id, secondChannel.id],
        completion: $0
      )
    }

    try awaitResultValue {
      channelGroup.removeChannelIdentifiers(
        [channel.id, secondChannel.id],
        completion: $0
      )
    }

    let responseValue = try awaitResultValue {
      channelGroup.listChannels(
        completion: $0
      )
    }

    XCTAssertEqual(responseValue.page?.totalCount, 0)
    XCTAssertTrue(responseValue.channels.isEmpty)
  }

  func testChannelGroup_WhoIsPresent() throws {
    try awaitResultValue {
      channelGroup.add(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    let autoCloseable = channelGroup.connect {
      debugPrint("Did receive message: \($0)")
    }
    let whoIsPresentValue = try awaitResultValue(delay: 3) {
      channelGroup.whoIsPresent(
        completion: $0
      )
    }

    XCTAssertEqual(whoIsPresentValue.count, 2)
    XCTAssertEqual(whoIsPresentValue[channel.id], [chat.currentUser.id])
    XCTAssertEqual(whoIsPresentValue[secondChannel.id], [chat.currentUser.id])

    addTeardownBlock {
      autoCloseable.close()
    }
  }

  func testChannelGroup_StreamPresence() throws {
    let expectation = expectation(description: "StreamPresence")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try awaitResultValue {
      channelGroup.add(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    let autoCloseable = channelGroup.connect {
      debugPrint("Did receive message: \($0)")
    }

    let presenceCloseable = channelGroup.streamPresence { [unowned self] in
      if $0.count == 2 {
        XCTAssertEqual($0[channel.id], [chat.currentUser.id])
        XCTAssertEqual($0[secondChannel.id], [chat.currentUser.id])
        expectation.fulfill()
      }
    }

    wait(
      for: [expectation],
      timeout: 6
    )

    addTeardownBlock {
      autoCloseable.close()
      presenceCloseable.close()
    }
  }

  func testChannelGroup_Connect() throws {
    let expectation = XCTestExpectation(description: "Connect")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    try awaitResultValue {
      channelGroup.add(
        channels: [channel, secondChannel],
        completion: $0
      )
    }

    let closeable = channelGroup.connect(
      callback: { [unowned self] in
        XCTAssertEqual($0.text, "This is a text")
        XCTAssertEqual($0.channelId, channel.id)
        expectation.fulfill()
      }
    )

    try awaitResultValue(delay: 4) {
      channel.sendText(
        text: "This is a text",
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
