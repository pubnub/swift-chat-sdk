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
    _ = try await channel.delete(soft: false)
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)
    XCTAssertNil(retrievedChannel)
  }

  func testChannelAsync_SoftDelete() async throws {
    _ = try await channel.delete(soft: true)
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)
    XCTAssertNotNil(retrievedChannel)
    XCTAssertEqual(retrievedChannel?.id, channel.id)
  }

  func testChannelAsync_Forward() async throws {
    let anotherChannel = try await chat.createChannel(id: randomString())
    let tt = try await anotherChannel.sendText(text: "Some text to send")

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let message = try await anotherChannel.getMessage(timetoken: tt)
    let unwrappedMessage = try XCTUnwrap(message)
    try await channel.forward(message: unwrappedMessage)

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let retrievedMssgsFromForwardedChannel = try await channel.getHistory()

    XCTAssertEqual(retrievedMssgsFromForwardedChannel.messages.count, 1)
    XCTAssertEqual(retrievedMssgsFromForwardedChannel.messages.first?.channelId, channel.id)

    addTeardownBlock { [unowned self] in
      _ = try await chat.deleteChannel(id: anotherChannel.id)
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
    // Keeping a strong reference to this object for test purposes to simulate that someone is already present on the given channel.
    // If this object is not retained, it will be deallocated, resulting in no subscription to the channel,
    // which would cause the behavior being tested to fail.
    let joinResult = try await channel.join()
    debugPrint(joinResult)

    try await Task.sleep(nanoseconds: 4_000_000_000)
    let whoIsPresent = try await channel.whoIsPresent()

    XCTAssertEqual(whoIsPresent.count, 1)
    XCTAssertEqual(whoIsPresent.first, chat.currentUser.id)
  }

  func testChannelAsync_IsPresent() async throws {
    // Keeping a strong reference to this object for test purposes to simulate that someone is already present on the given channel.
    // If this object is not retained, it will be deallocated, resulting in no subscription to the channel,
    // which would cause the behavior being tested to fail.
    let joinResult = try await channel.join()
    debugPrint(joinResult)

    try await Task.sleep(nanoseconds: 4_000_000_000)
    let isPresent = try await channel.isPresent(userId: chat.currentUser.id)
    XCTAssertTrue(isPresent)
  }

  func testChannelAsync_GetHistory() async throws {
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

  func testChannelAsync_SendText() async throws {
    let tt = try await channel.sendText(
      text: "Some text to send",
      meta: ["a": 123, "b": "someString"],
      shouldStore: true,
      usersToMention: nil
    )

    try await Task.sleep(nanoseconds: 2_000_000_000)
    let retrievedMessage = try await channel.getMessage(timetoken: tt)

    XCTAssertEqual(retrievedMessage?.text, "Some text to send")
    XCTAssertEqual(retrievedMessage?.meta?["a"]?.codableValue.rawValue as? Int, 123)
    XCTAssertEqual(retrievedMessage?.meta?["b"]?.codableValue.rawValue as? String, "someString")
  }

  func testChannelAsync_SendTextWithFiles() async throws {
    let downloadExpect = expectation(description: "Download File Expect")
    downloadExpect.expectedFulfillmentCount = 1
    downloadExpect.assertForOverFulfill = true

    let fileUrlSession = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: FileSessionManager(),
      delegateQueue: .main
    )
    let newPubNub = PubNub(
      configuration: chat.pubNub.configuration,
      fileSession: fileUrlSession
    )
    let newChat = ChatImpl(
      pubNub: newPubNub,
      configuration: chat.config
    )

    let data = Data("Lorem ipsum".utf8)
    let newChannel = try await newChat.createChannel(id: randomString())
    let inputFile = InputFile(name: "TxtFile", type: "text/plain", source: .data(data, contentType: "text/plain"))

    try await newChannel.sendText(text: "Text", files: [inputFile])
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let getFilesResult = try await newChannel.getFiles()
    let file = try XCTUnwrap(getFilesResult.files.first)

    let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    let outputPath = temporaryDirectory.appendingPathComponent(UUID().uuidString + ".txt")

    let fileToDownload = PubNubFileBase(
      channel: newChannel.id,
      fileId: file.id,
      filename: file.name,
      size: Int64(data.count),
      contentType: "text/plain"
    )

    newPubNub.download(file: fileToDownload, toFileURL: outputPath) { downloadResult in
      switch downloadResult {
      case let .success(downloadResponse):
        XCTAssertEqual(try? Data(contentsOf: downloadResponse.file.fileURL), data)
      case let .failure(error):
        XCTFail("Unexpected error: \(error)")
      }
      downloadExpect.fulfill()
    }

    await fulfillment(
      of: [downloadExpect],
      timeout: 20
    )

    addTeardownBlock {
      newPubNub.remove(
        fileId: file.id,
        filename: file.name,
        channel: newChannel.id,
        completion: nil
      )
      newChat.deleteChannel(
        id: newChannel.id,
        completion: nil
      )
      try FileManager.default.removeItem(
        at: outputPath
      )
    }
  }

  func testChannelAsync_Invite() async throws {
    try await channel.invite(user: chat.currentUser)
    let member = try await channel.getMembers().memberships.first
    XCTAssertEqual(member?.user.id, chat.currentUser.id)
  }

  func testChannelAsync_InviteMultiple() async throws {
    let someUser = try await chat.createUser(user: UserImpl(chat: chat, id: randomString()))
    let invitationResult = try await channel.inviteMultiple(users: [chat.currentUser, someUser])

    let firstMatch = try XCTUnwrap(
      invitationResult.first {
        $0.user.id == chat.currentUser.id && $0.channel.id == channel.id
      }
    )
    let secondMatch = try XCTUnwrap(
      invitationResult.first {
        $0.user.id == someUser.id && $0.channel.id == channel.id
      }
    )

    XCTAssertEqual(invitationResult.count, 2)
    XCTAssertNotNil(firstMatch)
    XCTAssertNotNil(secondMatch)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: someUser.id)
    }
  }

  func testChannelAsync_GetMembers() async throws {
    let someUser = try await chat.createUser(user: UserImpl(chat: chat, id: randomString()))
    try await channel.inviteMultiple(users: [chat.currentUser, someUser])

    let memberships = try await channel.getMembers().memberships

    let firstMatch = try XCTUnwrap(
      memberships.first {
        $0.user.id == chat.currentUser.id && $0.channel.id == channel.id
      }
    )
    let secondMatch = try XCTUnwrap(
      memberships.first {
        $0.user.id == someUser.id && $0.channel.id == channel.id
      }
    )

    XCTAssertEqual(memberships.count, 2)
    XCTAssertNotNil(firstMatch)
    XCTAssertNotNil(secondMatch)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: someUser.id)
    }
  }

  func testChannelAsync_Connect() async throws {
    let expectation = XCTestExpectation(description: "Connect")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await message in channel.connect() {
        XCTAssertEqual(message.text, "This is a text")
        XCTAssertEqual(message.channelId, channel.id)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 2_000_000_000)
    try await channel.sendText(text: "This is a text")

    await fulfillment(of: [expectation], timeout: 6)
    addTeardownBlock { task.cancel() }
  }

  func testChannelAsync_Join() async throws {
    let expectation = XCTestExpectation(description: "Connect")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let joinResult = try await channel.join()

    XCTAssertEqual(joinResult.membership.channel.id, channel.id)
    XCTAssertEqual(joinResult.membership.user.id, chat.currentUser.id)

    let task = Task {
      for await message in joinResult.messagesStream {
        XCTAssertEqual(message.text, "This is a text")
        XCTAssertEqual(message.channelId, channel.id)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 2_000_000_000)
    try await channel.sendText(text: "This is a text")

    await fulfillment(of: [expectation], timeout: 7)
    addTeardownBlock { task.cancel() }
  }

  func testChannelAsync_Leave() async throws {
    try await channel.join()
    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await channel.leave()

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let membershipsResult = try await channel.getMembers()

    XCTAssertTrue(membershipsResult.memberships.isEmpty)
  }

  func testChannelAsync_PinMessageGetPinnedMessage() async throws {
    let tt = try await channel.sendText(text: "Pinned message")
    try await Task.sleep(nanoseconds: 2_000_000_000)

    let message = try await channel.getMessage(timetoken: tt)
    let unwrappedMessage = try XCTUnwrap(message)

    let updatedChannel = try await channel.pinMessage(message: unwrappedMessage)
    try await Task.sleep(nanoseconds: 2_000_000_000)
    let pinnedMessage = try await updatedChannel.getPinnedMessage()

    XCTAssertNotNil(pinnedMessage)
    XCTAssertEqual(pinnedMessage?.channelId, channel.id)
  }

  func testChannelAsync_GetMessage() async throws {
    let tt = try await channel.sendText(text: "Message text")
    try await Task.sleep(nanoseconds: 2_000_000_000)

    let message = try await channel.getMessage(timetoken: tt)

    XCTAssertEqual(message?.channelId, channel.id)
    XCTAssertEqual(message?.userId, chat.currentUser.id)
  }

  func testChannelAsync_RegisterUnregisterFromPush() async throws {
    let pushNotificationsConfig = PushNotificationsConfig(
      sendPushes: false,
      deviceToken: "4d3f92b6d7a9348e5f2b8c6d1e4f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f",
      deviceGateway: .fcm,
      apnsEnvironment: .development
    )
    let anotherChat = ChatImpl(
      chatConfiguration: ChatConfiguration(pushNotificationsConfig: pushNotificationsConfig),
      pubNubConfiguration: chat.pubNub.configuration
    )

    let anotherChannel = try await anotherChat.createChannel(id: randomString())
    try await anotherChannel.registerForPush()
    try await anotherChannel.unregisterFromPush()

    addTeardownBlock {
      _ = try? await anotherChat.deleteChannel(id: anotherChannel.id)
    }
  }

  func testChannelAsync_StreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await receivedChannel in channel.streamUpdates() {
        XCTAssertEqual(receivedChannel?.name, "NewName")
        XCTAssertEqual(receivedChannel?.status, "NewStatus")
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    _ = try await channel.update(name: "NewName", status: "NewStatus")

    await fulfillment(of: [expectation], timeout: 6)
    addTeardownBlock { task.cancel() }
  }

  func testChannelAsync_StreamReadReceipts() async throws {
    let expectation = expectation(description: "StreamReadReceipts")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    _ = try await chat.createUser(user: UserImpl(chat: chat, id: randomString()))

    let anotherUser = try await chat.createUser(user: UserImpl(chat: chat, id: randomString()))
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let membership = try await channel.invite(user: chat.currentUser)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    let anotherMembership = try await channel.invite(user: anotherUser)

    let timetoken = try XCTUnwrap(membership.lastReadMessageTimetoken)
    let secondTimetoken = try XCTUnwrap(anotherMembership.lastReadMessageTimetoken)
    let currentUserId = chat.currentUser.id
    let anotherUserId = anotherUser.id

    let task = Task {
      for await readReceipt in channel.streamReadReceipts() {
        XCTAssertEqual(readReceipt[timetoken]?.count, 1)
        XCTAssertEqual(readReceipt[timetoken]?.first, currentUserId)
        XCTAssertEqual(readReceipt[secondTimetoken]?.count, 1)
        XCTAssertEqual(readReceipt[secondTimetoken]?.first, anotherUserId)
        expectation.fulfill()
      }
    }

    await fulfillment(of: [expectation], timeout: 6)
    addTeardownBlock { [unowned self] in
      task.cancel()
      _ = try? await chat.deleteUser(id: anotherUserId)
    }
  }

  func testChannelAsync_GetFiles() async throws {
    let fileUrlSession = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: FileSessionManager(),
      delegateQueue: .main
    )
    let newPubNub = PubNub(
      configuration: chat.pubNub.configuration,
      fileSession: fileUrlSession
    )
    let newChat = ChatImpl(
      pubNub: newPubNub,
      configuration: chat.config
    )
    let newChannel = try await newChat.createChannel(
      id: randomString()
    )
    let inputFile = InputFile(
      name: "TxtFile",
      type: "text/plain",
      source: .data(Data("Lorem ipsum".utf8), contentType: "text/plain")
    )

    try await newChannel.sendText(text: "Text", files: [inputFile])
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let getFilesResult = try await newChannel.getFiles()
    let file = try XCTUnwrap(getFilesResult.files.first)

    XCTAssertEqual(getFilesResult.files.count, 1)
    XCTAssertEqual(file.name, "TxtFile")

    addTeardownBlock {
      newPubNub.remove(
        fileId: file.id,
        filename: file.name,
        channel: newChannel.id,
        completion: nil
      )
      newChat.deleteChannel(
        id: newChannel.id,
        completion: nil
      )
    }
  }

  func testChannelAsync_DeleteFile() async throws {
    let fileUrlSession = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate: FileSessionManager(),
      delegateQueue: .main
    )
    let newPubNub = PubNub(
      configuration: chat.pubNub.configuration,
      fileSession: fileUrlSession
    )
    let newChat = ChatImpl(
      pubNub: newPubNub,
      configuration: chat.config
    )
    let newChannel = try await newChat.createChannel(
      id: randomString()
    )
    let inputFile = InputFile(
      name: "TxtFile",
      type: "text/plain",
      source: .data(Data("Lorem ipsum".utf8), contentType: "text/plain")
    )

    try await newChannel.sendText(text: "Text", files: [inputFile])
    try await Task.sleep(nanoseconds: 3_000_000_000)

    let getFilesResult = try await newChannel.getFiles()
    let file = try XCTUnwrap(getFilesResult.files.first)

    try await channel.deleteFile(id: file.id, name: file.name)
    let getFilesResultAfterRemoval = try await channel.getFiles()

    XCTAssertTrue(getFilesResultAfterRemoval.files.isEmpty)

    addTeardownBlock {
      _ = try? await newChat.deleteChannel(id: newChannel.id)
    }
  }

  func testChannelAsync_StreamPresence() async throws {
    let expectation = expectation(description: "StreamPresence")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let task = Task {
      for await message in channel.connect() {
        debugPrint("Did receive message: \(message)")
      }
    }

    let presenceStreamTask = Task {
      for await userIdentifiers in channel.streamPresence() where !userIdentifiers.isEmpty {
        XCTAssertEqual(userIdentifiers.count, 1)
        XCTAssertEqual(userIdentifiers.first, chat.currentUser.id)
        expectation.fulfill()
      }
    }

    await fulfillment(of: [expectation], timeout: 5)

    addTeardownBlock {
      presenceStreamTask.cancel()
      task.cancel()
    }
  }

  func testChannelAsync_GetUserSuggestions() async throws {
    let usersToCreate = [
      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())"),
      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())"),
      UserImpl(chat: chat, id: randomString(), name: "user_\(randomString())")
    ]

    for user in usersToCreate {
      _ = try await chat.createUser(user: user)
    }

    try await channel.inviteMultiple(users: usersToCreate)
    let users = try await channel.getUserSuggestions(text: "user_")

    XCTAssertEqual(
      users.compactMap(\.user.name).sorted(by: <),
      usersToCreate.compactMap(\.name).sorted(by: <)
    )

    addTeardownBlock { [unowned self] in
      for user in usersToCreate {
        _ = try? await chat.deleteUser(id: user.id)
      }
    }
  }

  func testChannelAsync_StreamMessageReports() async throws {
    let expectation = expectation(description: "StreamMessageReports")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let tt = try await channel.sendText(text: "Some text")
    try await Task.sleep(nanoseconds: 2_000_000_000)
    let message = try await channel.getMessage(timetoken: tt)

    let task = Task {
      for await report in channel.streamMessageReports() {
        XCTAssertEqual(report.event.payload.reason, "reportReason")
        XCTAssertEqual(report.event.payload.text, "Some text")
        XCTAssertEqual(report.event.payload.reportedUserId, chat.currentUser.id)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 4_000_000_000)
    try await message?.report(reason: "reportReason")

    await fulfillment(of: [expectation], timeout: 10)

    addTeardownBlock {
      task.cancel()
      _ = try? await message?.delete()
    }
  }

  // swiftlint:disable:next file_length
}
