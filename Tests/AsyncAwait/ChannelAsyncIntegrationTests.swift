//
//  ChannelAsyncIntegrationTests.swift
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

class ChannelIntegrationTests: BaseAsyncIntegrationTestCase {
  var channel: ChannelImpl!

  override func customSetup() async throws {
    channel = try await chat.createChannel(id: randomString())
  }

  override func customTearDown() async throws {
    _ = try? await channel.delete()
    channel = nil
  }

  func testChannelAsync_Update() async throws {
    let newCustom: [String: JSONCodableScalar] = [
      "a": 123,
      "b": "xyz"
    ]
    let updatedChannel = try await channel.update(
      name: "NewName",
      custom: newCustom,
      status: "NewStatus",
      type: .public
    )

    XCTAssertEqual(updatedChannel.id, channel.id)
    XCTAssertEqual(updatedChannel.name, "NewName")
    XCTAssertEqual(updatedChannel.custom?.mapValues { $0.scalarValue }, newCustom.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedChannel.status, "NewStatus")
    XCTAssertEqual(updatedChannel.type, .public)
  }

  func testChannelAsync_Delete() async throws {
    try await channel.delete(soft: false)
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)
    XCTAssertNil(retrievedChannel)
  }
  

  func testChannelAsync_SoftDelete() async throws {
    try await channel.delete(soft: true)
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)
    XCTAssertNotNil(retrievedChannel)
    XCTAssertEqual(retrievedChannel?.id, channel.id)
  }
  

  func testChannelAsync_Forward() async throws {
    let anotherChannel = try await chat.createChannel(id: randomString())
    let tt = try await anotherChannel.sendText(text: "Some text to send")
    
    try await Task.sleep(nanoseconds: 2_000_000_000)
    let message = try await channel.getMessage(timetoken: tt)
    let unwrappedMessage = try XCTUnwrap(message)
    try await channel.forward(message: unwrappedMessage)

    let retrievedMssgsFromForwardedChannel = try await channel.getHistory()
    XCTAssertEqual(retrievedMssgsFromForwardedChannel.messages.count, 1)
    XCTAssertEqual(retrievedMssgsFromForwardedChannel.messages.first?.channelId, channel.id)

    addTeardownBlock { [unowned self] in
      try await chat.deleteChannel(id: anotherChannel.id)
    }
  }

  func testChannelAsync_StartTyping() async throws {
    let expectation = expectation(description: "GetTyping")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await userIdentifiers in channel.getTyping() {
        XCTAssertEqual(userIdentifiers.first, chat.currentUser.id)
        expectation.fulfill()
      }
    }
    
    try await Task.sleep(nanoseconds: 2_000_000_000)
    try await channel.startTyping()

    await fulfillment(of: [expectation], timeout: 3)
    addTeardownBlock { task.cancel() }
  }
  
  func testChannelAsync_StopTyping() async throws {
    try await channel.stopTyping()
  }

  func testChannelAsync_WhoIsPresent() async throws {
    try await channel.join()
    try await Task.sleep(nanoseconds: 4_000_000_000)
    let whoIsPresent = try await channel.whoIsPresent()
    
    XCTAssertEqual(whoIsPresent.count, 1)
    XCTAssertEqual(whoIsPresent.first, chat.currentUser.id)
  }

  func testChannelAsync_IsPresent() async throws {
    try await channel.join()
    try await Task.sleep(nanoseconds: 4_000_000_000)
    let isPresent = try await channel.isPresent(userId: chat.currentUser.id)
    XCTAssertTrue(isPresent)
  }
    
  func testChannel_GetHistory() async throws {
    for counter in 1 ... 3 {
      try await channel.sendText(text: "Text \(counter)")
    }
    
    try await Task.sleep(nanoseconds: 2_000_000_000)
    let messages = try await channel.getHistory()

    XCTAssertEqual(messages.messages.count, 3)
    XCTAssertEqual(messages.messages[0].text, "Text 1")
    XCTAssertEqual(messages.messages[1].text, "Text 2")
    XCTAssertEqual(messages.messages[2].text, "Text 3")
  }

//
//  func testChannel_SendText() throws {
//    let tt = try awaitResultValue {
//      channel.sendText(
//        text: "Some text to send",
//        meta: ["a": 123, "b": "someString"],
//        shouldStore: true,
//        usersToMention: nil,
//        completion: $0
//      )
//    }
//
//    let retrievedMessage = try awaitResultValue(delay: 2) {
//      channel.getMessage(
//        timetoken: tt,
//        completion: $0
//      )
//    }
//
//    XCTAssertEqual(retrievedMessage?.text, "Some text to send")
//    XCTAssertEqual(retrievedMessage?.meta?["a"]?.codableValue.rawValue as? Int, 123)
//    XCTAssertEqual(retrievedMessage?.meta?["b"]?.codableValue.rawValue as? String, "someString")
//  }
//
//  func testChannel_Invite() throws {
//    try awaitResultValue {
//      channel.invite(
//        user: chat.currentUser,
//        completion: $0
//      )
//    }
//    let member = try XCTUnwrap(
//      awaitResultValue {
//        channel.getMembers(
//          completion: $0
//        )
//      }.memberships.first
//    )
//
//    XCTAssertEqual(member.user.id, chat.currentUser.id)
//  }
//
//  func testChannel_InviteMultiple() throws {
//    let someUser = UserImpl(
//      chat: chat,
//      id: randomString()
//    )
//
//    try awaitResultValue {
//      chat.createUser(
//        user: someUser,
//        completion: $0
//      )
//    }
//
//    let resultValue = try awaitResultValue {
//      channel.inviteMultiple(
//        users: [chat.currentUser, someUser],
//        completion: $0
//      )
//    }
//
//    let firstMatch = try XCTUnwrap(
//      resultValue.first {
//        $0.user.id == chat.currentUser.id && $0.channel.id == channel.id
//      }
//    )
//    let secondMatch = try XCTUnwrap(
//      resultValue.first {
//        $0.user.id == someUser.id && $0.channel.id == channel.id
//      }
//    )
//
//    XCTAssertEqual(resultValue.count, 2)
//    XCTAssertNotNil(firstMatch)
//    XCTAssertNotNil(secondMatch)
//
//    addTeardownBlock { [unowned self] in
//      try awaitResult {
//        chat.deleteUser(id: someUser.id, completion: $0)
//      }
//    }
//  }
//
//  func testChannel_GetMembers() throws {
//    let someUser = UserImpl(
//      chat: chat,
//      id: randomString()
//    )
//
//    try awaitResultValue {
//      chat.createUser(
//        user: someUser,
//        completion: $0
//      )
//    }
//
//    try awaitResultValue {
//      channel.inviteMultiple(
//        users: [chat.currentUser, someUser],
//        completion: $0
//      )
//    }
//
//    let memberships = try XCTUnwrap(
//      awaitResultValue {
//        channel.getMembers(
//          completion: $0
//        )
//      }.memberships
//    )
//
//    let firstMatch = try XCTUnwrap(
//      memberships.first {
//        $0.user.id == chat.currentUser.id && $0.channel.id == channel.id
//      }
//    )
//    let secondMatch = try XCTUnwrap(
//      memberships.first {
//        $0.user.id == someUser.id && $0.channel.id == channel.id
//      }
//    )
//
//    XCTAssertEqual(memberships.count, 2)
//    XCTAssertNotNil(firstMatch)
//    XCTAssertNotNil(secondMatch)
//
//    addTeardownBlock { [unowned self] in
//      try awaitResult {
//        chat.deleteUser(id: someUser.id, completion: $0)
//      }
//    }
//  }
//
//  func testChannel_Connect() throws {
//    let expectation = XCTestExpectation(description: "Connect")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let closeable = channel.connect(
//      callback: { [unowned self] in
//        XCTAssertEqual($0.text, "This is a text")
//        XCTAssertEqual($0.channelId, channel.id)
//        expectation.fulfill()
//      }
//    )
//
//    try awaitResultValue(delay: 3) {
//      channel.sendText(
//        text: "This is a text",
//        completion: $0
//      )
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 6
//    )
//    addTeardownBlock {
//      closeable.close()
//    }
//  }
//
//  func testChannel_Join() throws {
//    let expectation = XCTestExpectation(description: "Connect")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let joinValue = try awaitResultValue { [unowned self] in
//      channel.join(
//        callback: {
//          XCTAssertEqual($0.text, "This is a text")
//          XCTAssertEqual($0.channelId, self.channel.id)
//          expectation.fulfill()
//        },
//        completion: $0
//      )
//    }
//
//    XCTAssertEqual(joinValue.membership.channel.id, channel.id)
//    XCTAssertEqual(joinValue.membership.user.id, chat.currentUser.id)
//
//    try awaitResultValue(delay: 3) {
//      channel.sendText(
//        text: "This is a text",
//        completion: $0
//      )
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 7
//    )
//    addTeardownBlock {
//      joinValue.disconnect?.close()
//    }
//  }
//
//  func testChannel_Leave() throws {
//    let joinValue = try awaitResultValue {
//      channel.join(
//        completion: $0
//      )
//    }
//    try awaitResultValue(delay: 3) {
//      channel.leave(
//        completion: $0
//      )
//    }
//    XCTAssertTrue(
//      try awaitResultValue(delay: 3) {
//        channel.getMembers(
//          completion: $0
//        )
//      }.memberships.isEmpty
//    )
//
//    addTeardownBlock {
//      joinValue.disconnect?.close()
//    }
//  }
//
//  func testChannel_PinMessageGetPinnedMessage() throws {
//    let tt = try awaitResultValue {
//      channel.sendText(
//        text: "Pinned message",
//        completion: $0
//      )
//    }
//    let message = try XCTUnwrap(
//      awaitResultValue(delay: 2) {
//        channel.getMessage(
//          timetoken: tt,
//          completion: $0
//        )
//      }
//    )
//    let updatedChannel = try awaitResultValue {
//      channel.pinMessage(
//        message: message,
//        completion: $0
//      )
//    }
//    let getPinnedMessage = try XCTUnwrap(
//      awaitResultValue(delay: 2) {
//        updatedChannel.getPinnedMessage(
//          completion: $0
//        )
//      }
//    )
//
//    XCTAssertEqual(
//      getPinnedMessage.channelId,
//      channel.id
//    )
//  }
//
//  func testChannel_GetMessage() throws {
//    let tt = try awaitResultValue {
//      channel.sendText(
//        text: "Message text",
//        completion: $0
//      )
//    }
//    let message = try XCTUnwrap(
//      awaitResultValue(delay: 2) {
//        channel.getMessage(
//          timetoken: tt,
//          completion: $0
//        )
//      }
//    )
//
//    XCTAssertEqual(message.channelId, channel.id)
//    XCTAssertEqual(message.userId, chat.currentUser.id)
//  }
//
//  func testChannel_RegisterUnregisterFromPush() throws {
//    let pushNotificationsConfig = PushNotificationsConfig(
//      sendPushes: false,
//      deviceToken: "4d3f92b6d7a9348e5f2b8c6d1e4f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f",
//      deviceGateway: .fcm,
//      apnsEnvironment: .development
//    )
//    let anotherChat = ChatImpl(
//      chatConfiguration: ChatConfiguration(pushNotificationsConfig: pushNotificationsConfig),
//      pubNubConfiguration: chat.pubNub.configuration
//    )
//    let anotherChannel = try awaitResultValue {
//      anotherChat.createChannel(
//        id: randomString(),
//        completion: $0
//      )
//    }
//    try awaitResultValue {
//      anotherChannel.registerForPush(
//        completion: $0
//      )
//    }
//    try awaitResultValue {
//      anotherChannel.unregisterFromPush(
//        completion: $0
//      )
//    }
//
//    addTeardownBlock { [unowned self] in
//      try awaitResult {
//        anotherChat.deleteChannel(
//          id: anotherChannel.id,
//          completion: $0
//        )
//      }
//    }
//  }
//
//  func testChannel_StreamUpdates() throws {
//    let expectation = expectation(description: "StreamUpdates")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let closeable = channel.streamUpdates {
//      XCTAssertEqual($0?.name, "NewName")
//      XCTAssertEqual($0?.status, "NewStatus")
//      expectation.fulfill()
//    }
//
//    try awaitResultValue(delay: 3) {
//      channel.update(
//        name: "NewName",
//        status: "NewStatus",
//        completion: $0
//      )
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 6
//    )
//    addTeardownBlock {
//      closeable.close()
//    }
//  }
//
//  func testChannel_StreamReadReceipts() throws {
//    let expectation = expectation(description: "StreamReadReceipts")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let anotherUser = try awaitResultValue {
//      chat.createUser(
//        user: UserImpl(chat: chat, id: randomString()),
//        completion: $0
//      )
//    }
//    let membership = try awaitResultValue(delay: 3) {
//      channel.invite(
//        user: chat.currentUser,
//        completion: $0
//      )
//    }
//    let anotherMembership = try awaitResultValue(delay: 1) {
//      channel.invite(
//        user: anotherUser,
//        completion: $0
//      )
//    }
//
//    let timetoken = try XCTUnwrap(membership.lastReadMessageTimetoken)
//    let secondTimetoken = try XCTUnwrap(anotherMembership.lastReadMessageTimetoken)
//    let currentUserId = chat.currentUser.id
//    let anotherUserId = anotherUser.id
//
//    let closeable = channel.streamReadReceipts {
//      XCTAssertEqual($0[timetoken]?.count, 1)
//      XCTAssertEqual($0[timetoken]?.first, currentUserId)
//      XCTAssertEqual($0[secondTimetoken]?.count, 1)
//      XCTAssertEqual($0[secondTimetoken]?.first, anotherUserId)
//      expectation.fulfill()
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 6
//    )
//    addTeardownBlock { [unowned self] in
//      closeable.close()
//      try awaitResult {
//        chat.deleteUser(
//          id: anotherUserId,
//          completion: $0
//        )
//      }
//    }
//  }
//
////
////  TODO: Investigate
////
//
////  func testChannel_GetFiles() throws {
////    let fileUrlSession = URLSession(
////      configuration: URLSessionConfiguration.default,
////      delegate: FileSessionManager(),
////      delegateQueue: .main
////    )
////    let newPubNub = PubNub(
////      configuration: chat.pubNub.configuration,
////      fileSession: fileUrlSession
////    )
////    let newChat = ChatImpl(
////      pubNub: newPubNub,
////      configuration: chat.config
////    )
////    let newChannel = try awaitResultValue {
////      newChat.createChannel(
////        id: randomString(),
////        completion: $0
////      )
////    }
////    let inputFile = InputFile(
////      name: "TxtFile",
////      type: "text/plain",
////      source: .data(try XCTUnwrap("Lorem ipsum".data(using: .utf8)), contentType: "text/plain")
////    )
////
////    try awaitResultValue(timeout: 10) {
////      newChannel.sendText(
////        text: "Text",
////        files: [inputFile],
////        completion: $0
////      )
////    }
////
////    let file = try XCTUnwrap(
////      try awaitResultValue {
////        newChannel.getFiles(completion: $0)
////      }.files.first
////    )
////
////    XCTAssertEqual(
////      file.name,
////      "TxtFile"
////    )
////
////    addTeardownBlock { [unowned self] in
////      try awaitResultValue {
////        newPubNub.remove(
////          fileId: file.id,
////          filename: file.name,
////          channel: newChannel.id,
////          completion: $0
////        )
////      }
////      try awaitResult {
////        newChat.deleteChannel(
////          id: newChannel.id,
////          completion: $0
////        )
////      }
////    }
////  }
//
////  func testChannel_DeleteFile() throws {
////    let fileUrlSession = URLSession(
////      configuration: URLSessionConfiguration.default,
////      delegate: FileSessionManager(),
////      delegateQueue: .main
////    )
////    let newPubNub = PubNub(
////      configuration: chat.pubNub.configuration,
////      fileSession: fileUrlSession
////    )
////    let newChat = ChatImpl(
////      pubNub: newPubNub,
////      configuration: chat.config
////    )
////    let newChannel = try awaitResultValue {
////      newChat.createChannel(
////        id: randomString(),
////        completion: $0
////      )
////    }
////    let inputFile = InputFile(
////      name: "TxtFile",
////      type: "text/plain",
////      source: .data(try XCTUnwrap("Lorem ipsum".data(using: .utf8)), contentType: "text/plain")
////    )
////
////    try awaitResultValue(timeout: 30) {
////      newChannel.sendText(
////        text: "Text",
////        files: [inputFile],
////        completion: $0
////      )
////    }
////
////    let file = try XCTUnwrap(
////      try awaitResultValue {
////        newChannel.getFiles(
////          limit: 10,
////          completion: $0
////        )
////      }.files.first
////    )
////
////    try awaitResultValue {
////      channel.deleteFile(
////        id: file.id,
////        name: file.name,
////        completion: $0
////      )
////    }
////
////    XCTAssertTrue(
////      try awaitResultValue {
////        channel.getFiles(
////          limit: 10,
////          completion: $0
////        )
////      }.files.isEmpty
////    )
////
////    addTeardownBlock { [unowned self] in
////      try awaitResult {
////        newChat.deleteChannel(
////          id: newChannel.id,
////          completion: $0
////        )
////      }
////    }
////  }
//
//  func testChannel_StreamPresence() throws {
//    let expectation = expectation(description: "StreamPresence")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let connectCloseable = channel.connect(callback: {
//      debugPrint("Did receive message: \($0)")
//    })
//
//    let presenceCloseable = channel.streamPresence { [unowned self] in
//      if !$0.isEmpty {
//        XCTAssertEqual($0.count, 1)
//        XCTAssertEqual($0.first, chat.currentUser.id)
//        expectation.fulfill()
//      }
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 5
//    )
//    addTeardownBlock {
//      presenceCloseable.close()
//      connectCloseable.close()
//    }
//  }
//
//  func testChannel_GetUserSuggestions() throws {
//    let usersToCreate = [
//      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())"),
//      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())"),
//      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())")
//    ]
//
//    for user in usersToCreate {
//      try awaitResultValue {
//        chat.createUser(
//          user: user,
//          completion: $0
//        )
//      }
//    }
//
//    try awaitResultValue {
//      channel.inviteMultiple(
//        users: usersToCreate,
//        completion: $0
//      )
//    }
//
//    let users = try awaitResultValue {
//      channel.getUserSuggestions(
//        text: "user_",
//        completion: $0
//      )
//    }
//
//    XCTAssertEqual(
//      users.compactMap(\.user.name).sorted(by: <),
//      usersToCreate.compactMap(\.name).sorted(by: <)
//    )
//
//    addTeardownBlock { [unowned self] in
//      for user in usersToCreate {
//        try awaitResult {
//          chat.deleteUser(
//            id: user.id,
//            completion: $0
//          )
//        }
//      }
//    }
//  }
//
//  func testChannel_StreamMessageReports() throws {
//    let expectation = expectation(description: "StreamMessageReports")
//    expectation.assertForOverFulfill = true
//    expectation.expectedFulfillmentCount = 1
//
//    let tt = try awaitResultValue {
//      channel.sendText(
//        text: "Some text",
//        completion: $0
//      )
//    }
//    let message = try awaitResultValue(delay: 2) {
//      channel.getMessage(
//        timetoken: tt,
//        completion: $0
//      )
//    }
//
//    let closeable = channel.streamMessageReports { [unowned self] report in
//      XCTAssertEqual(report.payload.reason, "reportReason")
//      XCTAssertEqual(report.payload.text, "Some text")
//      XCTAssertEqual(report.payload.reportedUserId, chat.currentUser.id)
//      expectation.fulfill()
//    }
//
//    try awaitResultValue(delay: 4) {
//      message?.report(
//        reason: "reportReason",
//        completion: $0
//      )
//    }
//
//    wait(
//      for: [expectation],
//      timeout: 10
//    )
//    addTeardownBlock { [unowned self] in
//      closeable.close()
//      try awaitResult { message?.delete(completion: $0) }
//    }
//  }
}