//
//  ChatIntegrationTests.swift
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

class ChatIntegrationTests: BaseClosureIntegrationTestCase {
  func testChat_CreateUser() throws {
    let user = try awaitResultValue {
      chat.createUser(
        id: randomString(),
        name: "randomUser",
        status: "active",
        type: "type",
        completion: $0
      )
    }

    XCTAssertEqual(user.name, "randomUser")
    XCTAssertEqual(user.status, "active")
    XCTAssertEqual(user.type, "type")

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteUser(
          id: user.id,
          completion: $0
        )
      }
    }
  }

  func testChat_GetUser() throws {
    let user = try awaitResultValue {
      chat.getUser(
        userId: chat.currentUser.id,
        completion: $0
      )
    }

    XCTAssertEqual(user?.id, chat.currentUser.id)
    XCTAssertEqual(user?.name, chat.currentUser.name)
  }

  func testChat_GetUsers() throws {
    let user = try awaitResultValue {
      chat.createUser(
        id: randomString(),
        completion: $0
      )
    }
    let users = try awaitResultValue {
      chat.getUsers(
        limit: 10,
        completion: $0
      )
    }

    XCTAssertFalse(
      users.users.isEmpty
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteUser(
          id: user.id,
          completion: $0
        )
      }
    }
  }

  func testChat_UpdateUser() throws {
    let newCustom: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]

    let userId = randomString()

    try awaitResultValue {
      chat.createUser(
        id: userId,
        completion: $0
      )
    }

    let updatedUser = try awaitResultValue {
      chat.updateUser(
        id: userId,
        name: "NewName",
        externalId: "NewExternalId",
        profileUrl: "https://picsum.photos/200/400",
        email: "some.user@pubnub.com",
        custom: newCustom,
        status: "offline",
        type: "regular",
        completion: $0
      )
    }

    XCTAssertEqual(updatedUser.id, userId)
    XCTAssertEqual(updatedUser.name, "NewName")
    XCTAssertEqual(updatedUser.externalId, "NewExternalId")
    XCTAssertEqual(updatedUser.profileUrl, "https://picsum.photos/200/400")
    XCTAssertEqual(updatedUser.email, "some.user@pubnub.com")
    XCTAssertEqual(updatedUser.custom?.mapValues { $0.scalarValue }, newCustom.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedUser.status, "offline")
    XCTAssertEqual(updatedUser.type, "regular")

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteUser(
          id: userId,
          completion: $0
        )
      }
    }
  }

  func testChat_Delete() throws {
    let user = try awaitResultValue {
      chat.createUser(
        id: randomString(),
        completion: $0
      )
    }
    try awaitResultValue {
      chat.deleteUser(
        id: user.id,
        completion: $0
      )
    }
    let retrievedUser = try awaitResultValue {
      chat.getUser(
        userId: user.id,
        completion: $0
      )
    }

    XCTAssertNil(
      retrievedUser
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteUser(
          id: user.id,
          completion: $0
        )
      }
    }
  }

  func testChat_WherePresent() throws {
    let channelId = randomString()
    let channel = try awaitResultValue { chat.createChannel(id: channelId, name: channelId, completion: $0) }
    let closeable = channel.connect(callback: { _ in })

    XCTAssertEqual(
      try awaitResultValue(delay: 5) {
        chat.wherePresent(
          userId: chat.currentUser.id,
          completion: $0
        )
      }, [channelId]
    )

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
      closeable.close()
    }
  }

  func testChat_IsPresent() throws {
    let channelId = randomString()
    let channel = try awaitResultValue { chat.createChannel(id: channelId, name: channelId, completion: $0) }
    let closeable = channel.connect(callback: { _ in })

    let joinValue = try awaitResultValue {
      channel.join(
        completion: $0
      )
    }

    XCTAssertTrue(try awaitResultValue(delay: 3) {
      chat.isPresent(
        userId: chat.currentUser.id,
        channelId: channelId,
        completion: $0
      )
    })

    addTeardownBlock { [unowned self] in
      joinValue.disconnect?.close()
      closeable.close()

      try awaitResult {
        chat.deleteChannel(
          id: channelId,
          completion: $0
        )
      }
    }
  }

  func testChat_CreateChannel() throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "ChannelName",
        description: "ChannelDescription",
        custom: customField,
        type: .unknown,
        status: "status",
        completion: $0
      )
    }

    XCTAssertEqual(channel.name, "ChannelName")
    XCTAssertEqual(channel.description, "ChannelDescription")
    XCTAssertEqual(channel.type, .unknown)
    XCTAssertEqual(channel.status, "status")
    XCTAssertEqual(channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_GetChannel() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "ChannelName",
        completion: $0
      )
    }
    let retrievedChannel = try awaitResultValue {
      chat.getChannel(
        channelId: channel.id,
        completion: $0
      )
    }

    XCTAssertEqual(retrievedChannel?.id, channel.id)
  }

  func testChat_GetChannels() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    let retrievedChannels = try awaitResultValue {
      chat.getChannels(
        limit: 10,
        completion: $0
      )
    }

    XCTAssertFalse(
      retrievedChannels.channels.isEmpty
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_UpdateChannel() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let updatedChannel = try awaitResultValue {
      chat.updateChannel(
        id: channel.id,
        name: "NewName",
        custom: customField,
        description: "NewDescription",
        status: "status",
        type: .unknown,
        completion: $0
      )
    }

    XCTAssertEqual(updatedChannel.id, channel.id)
    XCTAssertEqual(updatedChannel.name, "NewName")
    XCTAssertEqual(updatedChannel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedChannel.description, "NewDescription")
    XCTAssertEqual(updatedChannel.status, "status")
    XCTAssertEqual(updatedChannel.type, .unknown)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_DeleteChannel() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    try awaitResultValue {
      chat.deleteChannel(
        id: channel.id,
        completion: $0
      )
    }
    let retrievedChannel = try awaitResultValue {
      chat.getChannel(
        channelId: channel.id,
        completion: $0
      )
    }

    XCTAssertNil(
      retrievedChannel
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_WhoIsPresent() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "ChannelName",
        completion: $0
      )
    }
    let joinValue = try awaitResultValue {
      channel.join(
        completion: $0
      )
    }
    let whoIsPresentValue = try awaitResultValue(delay: 4) {
      chat.whoIsPresent(
        channelId: channel.id,
        completion: $0
      )
    }

    XCTAssertEqual(whoIsPresentValue.count, 1)
    XCTAssertEqual(whoIsPresentValue.first, chat.currentUser.id)

    addTeardownBlock { [unowned self] in
      joinValue.disconnect?.close()
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_EmitEvent() throws {
    let expectation = expectation(description: "Emit Event")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "ChannelName",
        completion: $0
      )
    }

    let closeable = channel.getTyping { [unowned self] in
      XCTAssertEqual($0, [chat.currentUser.id])
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      chat.emitEvent(
        channelId: channel.id,
        payload: EventContent.Typing(value: true),
        completion: $0
      )
    }
    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      closeable.close()
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_CreatePublicConversation() throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let channel = try awaitResultValue {
      chat.createPublicConversation(
        channelName: "ChannelName",
        channelDescription: "ChannelDescription",
        channelCustom: customField,
        channelStatus: "status",
        completion: $0
      )
    }

    XCTAssertEqual(channel.name, "ChannelName")
    XCTAssertEqual(channel.description, "ChannelDescription")
    XCTAssertEqual(channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(channel.status, "status")
    XCTAssertEqual(channel.type, .public)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_CreateDirectConversation() throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let membershipCustom: [String: JSONCodableScalar] = [
      "val1": 123,
      "val2": "lorem ipsum"
    ]

    let anotherUser = try awaitResultValue {
      chat.createUser(
        id: randomString(),
        name: "AnotherUser",
        completion: $0
      )
    }

    let resultValue = try awaitResultValue {
      chat.createDirectConversation(
        invitedUser: anotherUser,
        channelName: "ChannelName",
        channelDescription: "ChannelDescription",
        channelCustom: customField,
        channelStatus: "status",
        membershipCustom: membershipCustom,
        completion: $0
      )
    }

    XCTAssertEqual(resultValue.channel.name, "ChannelName")
    XCTAssertEqual(resultValue.channel.description, "ChannelDescription")
    XCTAssertEqual(resultValue.channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(resultValue.channel.status, "status")
    XCTAssertEqual(resultValue.channel.type, .direct)

    let inviteeMembership = try XCTUnwrap(resultValue.inviteeMembership)
    let hostMembership = try XCTUnwrap(resultValue.hostMembership)

    XCTAssertEqual(inviteeMembership.user.id, anotherUser.id)
    XCTAssertEqual(hostMembership.user.id, chat.currentUser.id)
    XCTAssertEqual(hostMembership.custom?.mapValues { $0.scalarValue }, membershipCustom.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: resultValue.channel.id,
          completion: $0
        )
      }
      try awaitResult {
        chat.deleteUser(
          id: anotherUser.id,
          completion: $0
        )
      }
    }
  }

  func testChat_CreateGroupConversation() throws {
    let anotherUser = try awaitResultValue {
      chat.createUser(
        id: randomString(),
        name: "AnotherUser",
        completion: $0
      )
    }

    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let membershipCustom: [String: JSONCodableScalar] = [
      "val1": 123,
      "val2": "lorem ipsum"
    ]

    let resultValue = try awaitResultValue {
      chat.createGroupConversation(
        invitedUsers: [anotherUser],
        channelName: "ChannelName",
        channelDescription: "ChannelDescription",
        channelCustom: customField,
        channelStatus: "status",
        membershipCustom: membershipCustom,
        completion: $0
      )
    }

    XCTAssertEqual(resultValue.channel.name, "ChannelName")
    XCTAssertEqual(resultValue.channel.description, "ChannelDescription")
    XCTAssertEqual(resultValue.channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(resultValue.channel.status, "status")
    XCTAssertEqual(resultValue.channel.type, .group)

    let inviteeMembership = try XCTUnwrap(resultValue.inviteeMemberships.first)
    let hostMembership = try XCTUnwrap(resultValue.hostMembership)

    XCTAssertEqual(inviteeMembership.user.id, anotherUser.id)
    XCTAssertEqual(hostMembership.user.id, chat.currentUser.id)
    XCTAssertEqual(hostMembership.custom?.mapValues { $0.scalarValue }, membershipCustom.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: resultValue.channel.id,
          completion: $0
        )
      }
      try awaitResult {
        chat.deleteUser(
          id: anotherUser.id,
          completion: $0
        )
      }
    }
  }

  func testChat_ListenForEvents() throws {
    let expectation = expectation(description: "Listen For Events")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    let closeable = chat.listenForEvents(
      type: EventContent.Typing.self,
      channelId: channel.id
    ) { [unowned self] in
      XCTAssertTrue($0.event.payload.value)
      XCTAssertEqual($0.event.channelId, channel.id)
      XCTAssertEqual($0.event.userId, chat.currentUser.id)
      expectation.fulfill()
    }

    try awaitResult(delay: 3) {
      channel.startTyping(
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      closeable.close()
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_RegisterUnregisterPushChannels() throws {
    let pushNotificationsConfig = PushNotificationsConfig(
      sendPushes: false,
      deviceToken: "4d3f92b6d7a9348e5f2b8c6d1e4f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f",
      deviceGateway: .fcm,
      apnsEnvironment: .development
    )
    let anotherChat = ChatImpl(
      pubNub: chat.pubNub,
      configuration: ChatConfiguration(pushNotificationsConfig: pushNotificationsConfig)
    )
    let anotherChannel = try awaitResultValue {
      anotherChat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    try awaitResultValue {
      anotherChat.registerPushChannels(
        channels: [anotherChannel.id],
        completion: $0
      )
    }
    try awaitResultValue {
      anotherChat.unregisterPushChannels(
        channels: [anotherChannel.id],
        completion: $0
      )
    }

    addTeardownBlock { [unowned self] in
      try awaitResult {
        anotherChat.deleteChannel(
          id: anotherChannel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_UnregisterAllPushChannels() throws {
    let pushNotificationsConfig = PushNotificationsConfig(
      sendPushes: false,
      deviceToken: "4d3f92b6d7a9348e5f2b8c6d1e4f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f",
      deviceGateway: .fcm,
      apnsEnvironment: .development
    )
    let anotherChat = ChatImpl(
      pubNub: chat.pubNub,
      configuration: ChatConfiguration(pushNotificationsConfig: pushNotificationsConfig)
    )

    let anotherChannel = try awaitResultValue {
      anotherChat.createChannel(
        id: randomString(),
        completion: $0
      )
    }
    try awaitResultValue {
      anotherChat.registerPushChannels(
        channels: [anotherChannel.id],
        completion: $0
      )
    }
    try awaitResultValue {
      anotherChat.unregisterAllPushChannels(
        completion: $0
      )
    }
    let pushChannels = try awaitResultValue {
      anotherChat.getPushChannels(
        completion: $0
      )
    }

    XCTAssertTrue(
      pushChannels.isEmpty
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        anotherChat.deleteChannel(
          id: anotherChannel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_GetUnreadMessagesCount() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }

    try awaitResultValue {
      channel.invite(
        user: chat.currentUser,
        completion: $0
      )
    }

    for _ in 1 ... 3 {
      try awaitResultValue {
        channel.sendText(
          text: "Some new text",
          completion: $0
        )
      }
    }

    let getUnreadMessagesCount = try XCTUnwrap(
      awaitResultValue {
        chat.getUnreadMessagesCount(
          completion: $0
        )
      }.first
    )

    XCTAssertEqual(getUnreadMessagesCount.count, 3)
    XCTAssertEqual(getUnreadMessagesCount.channel.id, channel.id)
    XCTAssertEqual(getUnreadMessagesCount.membership.user.id, chat.currentUser.id)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_MarkAllMessagesAsRead() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        completion: $0
      )
    }

    try awaitResultValue {
      channel.invite(
        user: chat.currentUser,
        completion: $0
      )
    }

    for _ in 1 ... 3 {
      try awaitResultValue {
        channel.sendText(
          text: "Some new text",
          completion: $0
        )
      }
    }

    try awaitResultValue(delay: 4) {
      chat.markAllMessagesAsRead(
        completion: $0
      )
    }

    let getUnreadMessagesCount = try awaitResultValue(delay: 4) {
      chat.getUnreadMessagesCount(
        completion: $0
      )
    }

    XCTAssertTrue(
      getUnreadMessagesCount.isEmpty
    )
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_GetEventsHistory() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "Channel name",
        completion: $0
      )
    }

    try awaitResultValue {
      channel.invite(
        user: chat.currentUser,
        completion: $0
      )
    }

    let history = try awaitResultValue(delay: 3) {
      chat.getEventsHistory(
        channelId: chat.currentUser.id,
        completion: $0
      )
    }

    let inviteEvent = try XCTUnwrap(history.events.compactMap { $0.event.payload as? EventContent.Invite }.first)

    XCTAssertEqual(inviteEvent.channelId, channel.id)
    XCTAssertEqual(inviteEvent.channelType, .unknown)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_GetCurrentUserMentions() throws {
    let channel = try awaitResultValue {
      chat.createChannel(
        id: randomString(),
        name: "Channel name",
        completion: $0
      )
    }
    try awaitResultValue {
      channel.invite(
        user: chat.currentUser,
        completion: $0
      )
    }

    let tt = try awaitResultValue {
      channel.sendText(
        text: "Some text",
        completion: $0
      )
    }

    try awaitResultValue(delay: 2) {
      chat.emitEvent(
        channelId: chat.currentUser.id,
        payload: EventContent.Mention(
          messageTimetoken: tt,
          channel: channel.id
        ),
        completion: $0
      )
    }

    let userMentionData = try XCTUnwrap(
      awaitResultValue(delay: 3) {
        chat.getCurrentUserMentions(
          completion: $0
        )
      }.mentions.first
    )

    XCTAssertEqual(userMentionData.userMentionData.userId, chat.currentUser.id)
    XCTAssertEqual(userMentionData.userMentionData.event.channel, channel.id)
    XCTAssertEqual(userMentionData.userMentionData.message?.timetoken, tt)
    XCTAssertEqual(userMentionData.userMentionData.message?.text, "Some text")

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_CustomPayload() throws {
    let getMessagePublishBody: GetMessagePublishBody? = { txtContent, _, _ in
      ["payload": txtContent.text]
    }
    let getMessageResponseBody: GetMessageResponseBody? = { value, _, _ in
      if let decodedValue = try? value.decode([String: String].self) {
        EventContent.TextMessageContent(text: decodedValue["payload"] ?? "")
      } else {
        nil
      }
    }

    let customPayloads = CustomPayloads(
      getMessagePublishBody: getMessagePublishBody,
      getMessageResponseBody: getMessageResponseBody
    )
    let anotherChat = ChatImpl(
      pubNub: chat.pubNub,
      configuration: ChatConfiguration(customPayloads: customPayloads)
    )
    let channel = try awaitResultValue {
      anotherChat.createChannel(
        id: randomString(),
        completion: $0
      )
    }

    try awaitResultValue {
      channel.sendText(
        text: "Some text",
        completion: $0
      )
    }

    let message = try XCTUnwrap(
      awaitResultValue(delay: 2) {
        channel.getHistory(
          count: 1,
          completion: $0
        )
      }.messages.first
    )

    XCTAssertEqual(message.text, "Some text")
    XCTAssertTrue(message.files.isEmpty)

    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testChat_MutedUsers() throws {
    let userToMute = randomString()

    try awaitResultValue {
      chat.mutedUsersManager.muteUser(
        userId: userToMute,
        completion: $0
      )
    }

    XCTAssertEqual(
      chat.mutedUsersManager.mutedUsers, [userToMute]
    )

    try awaitResultValue {
      chat.mutedUsersManager.unmuteUser(
        userId: userToMute,
        completion: $0
      )
    }

    XCTAssertTrue(
      chat.mutedUsersManager.mutedUsers.isEmpty
    )
  }

  // swiftlint:disable:next file_length
}
