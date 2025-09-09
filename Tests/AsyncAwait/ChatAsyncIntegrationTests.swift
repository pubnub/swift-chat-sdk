//
//  ChatAsyncIntegrationTests.swift
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

class ChatAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
  func testChatAsync_CreateUser() async throws {
    let user = try await chat.createUser(
      id: randomString(),
      name: "randomUser",
      status: "active",
      type: "type"
    )

    XCTAssertEqual(user.name, "randomUser")
    XCTAssertEqual(user.status, "active")
    XCTAssertEqual(user.type, "type")

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: user.id)
    }
  }

  func testChatAsync_GetUser() async throws {
    let user = try await chat.getUser(userId: chat.currentUser.id)

    XCTAssertEqual(user?.id, chat.currentUser.id)
    XCTAssertEqual(user?.name, chat.currentUser.name)
  }

  func testChatAsync_GetUsers() async throws {
    let user = try await chat.createUser(id: randomString())
    let secondUser = try await chat.createUser(id: randomString())
    let getUsersResponse = try await chat.getUsers(filter: "id LIKE 'swift-chat*'")

    XCTAssertEqual(
      Set(getUsersResponse.users.map { $0.id }),
      Set([user.id, secondUser.id])
    )

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: user.id)
      _ = try? await chat.deleteUser(id: secondUser.id)
    }
  }

  func testChatAsync_UpdateUser() async throws {
    let userId = randomString()
    _ = try await chat.createUser(id: userId)

    let newCustom: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let updatedUser = try await chat.updateUser(
      id: userId,
      name: "NewName",
      externalId: "NewExternalId",
      profileUrl: "https://picsum.photos/200/400",
      email: "some.user@pubnub.com",
      custom: newCustom,
      status: "offline",
      type: "regular"
    )

    XCTAssertEqual(updatedUser.id, userId)
    XCTAssertEqual(updatedUser.name, "NewName")
    XCTAssertEqual(updatedUser.externalId, "NewExternalId")
    XCTAssertEqual(updatedUser.profileUrl, "https://picsum.photos/200/400")
    XCTAssertEqual(updatedUser.email, "some.user@pubnub.com")
    XCTAssertEqual(updatedUser.custom?.mapValues { $0.scalarValue }, newCustom.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedUser.status, "offline")
    XCTAssertEqual(updatedUser.type, "regular")

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: userId)
    }
  }

  func testChatAsync_Delete() async throws {
    let user = try await chat.createUser(id: randomString())
    _ = try await chat.deleteUser(id: user.id)
    let retrievedUser = try await chat.getUser(userId: user.id)

    XCTAssertNil(
      retrievedUser
    )
    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: user.id)
    }
  }

  func testChatAsync_GetUsersWithPagination() async throws {
    let user1 = try await chat.createUser(id: randomString(), name: "User1")
    let user2 = try await chat.createUser(id: randomString(), name: "User2")
    let user3 = try await chat.createUser(id: randomString(), name: "User3")

    let firstPageResponse = try await chat.getUsers(filter: "id LIKE 'swift-chat*'", limit: 2)
    let secondPageResponse = try await chat.getUsers(filter: "id LIKE 'swift-chat*'", page: firstPageResponse.page)

    XCTAssertTrue(firstPageResponse.users.count == 2)
    XCTAssertTrue(secondPageResponse.users.count == 1)

    let idsFromFirstPage = Set(firstPageResponse.users.map { $0.id })
    let idsFromSecondPage = Set(secondPageResponse.users.map { $0.id })

    XCTAssertTrue(idsFromFirstPage.isDisjoint(with: idsFromSecondPage))
    XCTAssertEqual(idsFromSecondPage.union(idsFromFirstPage), Set([user1.id, user2.id, user3.id]))

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: user1.id)
      _ = try? await chat.deleteUser(id: user2.id)
      _ = try? await chat.deleteUser(id: user3.id)
    }
  }

  func testChatAsync_WherePresent() async throws {
    let channelId = randomString()
    let channel = try await chat.createChannel(id: channelId, name: channelId)

    // Keeps a strong reference to the returned AsyncStream to prevent it from being deallocated. If this object is not retained,
    // the AsyncStream will be deallocated, which would cause the behavior being tested to fail.
    let connectResult = channel.connect()
    debugPrint(connectResult)

    try await Task.sleep(nanoseconds: 5_000_000_000)
    let channelIdentifiers = try await chat.wherePresent(userId: chat.currentUser.id)
    let expectedChannelIdentifiers = [channelId]

    XCTAssertEqual(expectedChannelIdentifiers, channelIdentifiers)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channelId)
    }
  }

  func testChatAsync_IsPresent() async throws {
    let channelId = randomString()
    let channel = try await chat.createChannel(id: channelId, name: channelId)

    // Keeps a strong reference to the returned AsyncStream to prevent it from being deallocated. If this object is not retained,
    // the AsyncStream will be deallocated, which would cause the behavior being tested to fail.
    let connectResult = channel.connect()
    let joinResult = try await channel.join()

    debugPrint(connectResult)
    debugPrint(joinResult)

    try await Task.sleep(nanoseconds: 3_000_000_000)

    let isPresent = try await chat.isPresent(userId: chat.currentUser.id, channelId: channelId)
    XCTAssertTrue(isPresent)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channelId)
    }
  }

  func testChatAsync_CreateChannel() async throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let channel = try await chat.createChannel(
      id: randomString(),
      name: "ChannelName",
      description: "ChannelDescription",
      custom: customField,
      type: .unknown,
      status: "status"
    )

    XCTAssertEqual(channel.name, "ChannelName")
    XCTAssertEqual(channel.channelDescription, "ChannelDescription")
    XCTAssertEqual(channel.type, .unknown)
    XCTAssertEqual(channel.status, "status")
    XCTAssertEqual(channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_GetChannel() async throws {
    let channel = try await chat.createChannel(id: randomString(), name: "ChannelName")
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)

    XCTAssertEqual(
      retrievedChannel?.id,
      channel.id
    )

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_GetChannels() async throws {
    let channel = try await chat.createChannel(id: randomString())
    let secondChannel = try await chat.createChannel(id: randomString())
    let getChannelsResponse = try await chat.getChannels(filter: "id LIKE 'swift-chat*'")

    XCTAssertEqual(
      Set(getChannelsResponse.channels.map { $0.id }),
      Set([channel.id, secondChannel.id])
    )

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
      _ = try? await chat.deleteChannel(id: secondChannel.id)
    }
  }

  func testChatAsync_UpdateChannel() async throws {
    let channel = try await chat.createChannel(id: randomString())
    let customField: [String: JSONCodableScalar] = ["someValue": 17_253_575_019_298_112, "someStr": "str"]

    let updatedChannel = try await chat.updateChannel(
      id: channel.id,
      name: "NewName",
      custom: customField,
      description: "NewDescription",
      status: "status",
      type: .unknown
    )

    XCTAssertEqual(updatedChannel.id, channel.id)
    XCTAssertEqual(updatedChannel.name, "NewName")
    XCTAssertEqual(updatedChannel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedChannel.channelDescription, "NewDescription")
    XCTAssertEqual(updatedChannel.status, "status")
    XCTAssertEqual(updatedChannel.type, .unknown)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_DeleteChannel() async throws {
    let channel = try await chat.createChannel(id: randomString())
    _ = try await chat.deleteChannel(id: channel.id)
    let retrievedChannel = try await chat.getChannel(channelId: channel.id)

    XCTAssertNil(
      retrievedChannel
    )
    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_GetChannelsWithPagination() async throws {
    let channel1 = try await chat.createChannel(id: randomString(), name: "Channel1")
    let channel2 = try await chat.createChannel(id: randomString(), name: "Channel2")
    let channel3 = try await chat.createChannel(id: randomString(), name: "Channel3")

    let firstPageResponse = try await chat.getChannels(filter: "id LIKE 'swift-chat*'", limit: 2)
    let secondPageResponse = try await chat.getChannels(filter: "id LIKE 'swift-chat*'", page: firstPageResponse.page)

    XCTAssertTrue(firstPageResponse.channels.count == 2)
    XCTAssertTrue(secondPageResponse.channels.count == 1)

    let idsFromFirstPage = Set(firstPageResponse.channels.map { $0.id })
    let idsFromSecondPage = Set(secondPageResponse.channels.map { $0.id })

    XCTAssertTrue(idsFromFirstPage.isDisjoint(with: idsFromSecondPage))
    XCTAssertEqual(idsFromSecondPage.union(idsFromFirstPage), Set([channel1.id, channel2.id, channel3.id]))

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel1.id)
      _ = try? await chat.deleteChannel(id: channel2.id)
      _ = try? await chat.deleteChannel(id: channel3.id)
    }
  }

  func testChatAsync_WhoIsPresent() async throws {
    let channel = try await chat.createChannel(
      id: randomString(),
      name: "ChannelName"
    )

    // Keeps a strong reference to the returned AsyncStream to prevent it from being deallocated. If this object is not retained,
    // the AsyncStream will be deallocated, which would cause the behavior being tested to fail.
    let joinValue = try await channel.join()
    debugPrint(joinValue)

    try await Task.sleep(nanoseconds: 4_000_000_000)

    let whoIsPresentValue = try await chat.whoIsPresent(channelId: channel.id)
    XCTAssertEqual(whoIsPresentValue.count, 1)
    XCTAssertEqual(whoIsPresentValue.first, chat.currentUser.id)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_EmitEvent() async throws {
    let expectation = expectation(description: "Emit Event")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let channel = try await chat.createChannel(
      id: randomString(),
      name: "ChannelName"
    )

    let task = Task {
      for await typpingUsers in channel.getTyping() {
        XCTAssertEqual(typpingUsers, [chat.currentUser.id])
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await chat.emitEvent(channelId: channel.id, payload: EventContent.Typing(value: true))

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock { [unowned self] in
      task.cancel()
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_CreatePublicConversation() async throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let channel = try await chat.createPublicConversation(
      channelName: "ChannelName",
      channelDescription: "ChannelDescription",
      channelCustom: customField,
      channelStatus: "status"
    )

    XCTAssertEqual(channel.name, "ChannelName")
    XCTAssertEqual(channel.channelDescription, "ChannelDescription")
    XCTAssertEqual(channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(channel.status, "status")
    XCTAssertEqual(channel.type, .public)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_CreateDirectConversation() async throws {
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let membershipCustom: [String: JSONCodableScalar] = [
      "val1": 123,
      "val2": "lorem ipsum"
    ]

    let anotherUser = try await chat.createUser(
      id: randomString(),
      name: "AnotherUser"
    )

    let resultValue = try await chat.createDirectConversation(
      invitedUser: anotherUser,
      channelName: "ChannelName",
      channelDescription: "ChannelDescription",
      channelCustom: customField,
      channelStatus: "status",
      membershipCustom: membershipCustom
    )

    XCTAssertEqual(resultValue.channel.name, "ChannelName")
    XCTAssertEqual(resultValue.channel.channelDescription, "ChannelDescription")
    XCTAssertEqual(resultValue.channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(resultValue.channel.status, "status")
    XCTAssertEqual(resultValue.channel.type, .direct)

    let inviteeMembership = try XCTUnwrap(resultValue.inviteeMembership)
    let hostMembership = try XCTUnwrap(resultValue.hostMembership)

    XCTAssertEqual(inviteeMembership.user.id, anotherUser.id)
    XCTAssertEqual(hostMembership.user.id, chat.currentUser.id)
    XCTAssertEqual(hostMembership.custom?.mapValues { $0.scalarValue }, membershipCustom.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: resultValue.channel.id)
      _ = try? await chat.deleteUser(id: anotherUser.id)
    }
  }

  func testChatAsync_CreateGroupConversation() async throws {
    let anotherUser = try await chat.createUser(
      id: randomString(),
      name: "AnotherUser"
    )
    let customField: [String: JSONCodableScalar] = [
      "someValue": 17_253_575_019_298_112,
      "someStr": "str"
    ]
    let membershipCustom: [String: JSONCodableScalar] = [
      "val1": 123,
      "val2": "lorem ipsum"
    ]

    let resultValue = try await chat.createGroupConversation(
      invitedUsers: [anotherUser],
      channelName: "ChannelName",
      channelDescription: "ChannelDescription",
      channelCustom: customField,
      channelStatus: "status",
      membershipCustom: membershipCustom
    )

    XCTAssertEqual(resultValue.channel.name, "ChannelName")
    XCTAssertEqual(resultValue.channel.channelDescription, "ChannelDescription")
    XCTAssertEqual(resultValue.channel.custom?.mapValues { $0.scalarValue }, customField.mapValues { $0.scalarValue })
    XCTAssertEqual(resultValue.channel.status, "status")
    XCTAssertEqual(resultValue.channel.type, .group)

    let inviteeMembership = try XCTUnwrap(resultValue.inviteeMemberships.first)
    let hostMembership = try XCTUnwrap(resultValue.hostMembership)

    XCTAssertEqual(inviteeMembership.user.id, anotherUser.id)
    XCTAssertEqual(hostMembership.user.id, chat.currentUser.id)
    XCTAssertEqual(hostMembership.custom?.mapValues { $0.scalarValue }, membershipCustom.mapValues { $0.scalarValue })

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: resultValue.channel.id)
      _ = try? await chat.deleteUser(id: anotherUser.id)
    }
  }

  func testChatAsync_ListenForEvents() async throws {
    let expectation = expectation(description: "Listen For Events")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let channel = try await chat.createChannel(id: randomString())

    let task = Task {
      for await event in chat.listenForEvents(type: EventContent.Typing.self, channelId: channel.id) {
        XCTAssertTrue(event.event.payload.value)
        XCTAssertEqual(event.event.channelId, channel.id)
        XCTAssertEqual(event.event.userId, chat.currentUser.id)
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)
    try await channel.startTyping()
    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock { [unowned self] in
      task.cancel()
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_RegisterUnregisterPushChannels() async throws {
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

    let anotherChannel = try await anotherChat.createChannel(id: randomString())
    try await anotherChat.registerPushChannels(channels: [anotherChannel.id])
    try await anotherChat.unregisterPushChannels(channels: [anotherChannel.id])

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: anotherChannel.id)
    }
  }

  func testChatAsync_UnregisterAllPushChannels() async throws {
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

    let anotherChannel = try await anotherChat.createChannel(id: randomString())
    try await anotherChat.registerPushChannels(channels: [anotherChannel.id])
    try await anotherChat.unregisterAllPushChannels()

    let pushChannels = try await anotherChat.getPushChannels()
    XCTAssertTrue(pushChannels.isEmpty)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: anotherChannel.id)
    }
  }

  func testChatAsync_GetUnreadMessagesCount() async throws {
    let channel = try await chat.createChannel(id: randomString())

    try await channel.invite(user: chat.currentUser)
    try await channel.sendText(text: "Some new text")
    try await channel.sendText(text: "Some new text")
    try await channel.sendText(text: "Some new text")

    let getUnreadMessagesCount = try await chat.getUnreadMessagesCount().first

    XCTAssertEqual(getUnreadMessagesCount?.count, 3)
    XCTAssertEqual(getUnreadMessagesCount?.channel.id, channel.id)
    XCTAssertEqual(getUnreadMessagesCount?.membership.user.id, chat.currentUser.id)

    addTeardownBlock { [unowned self] in
      _ = try? await channel.leave()
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_FetchUnreadMessagesCounts() async throws {
    let channel = try await chat.createChannel(id: randomString())
    let channel2 = try await chat.createChannel(id: randomString())
    let channel3 = try await chat.createChannel(id: randomString())

    try await channel.invite(user: chat.currentUser)
    try await channel2.invite(user: chat.currentUser)
    try await channel3.invite(user: chat.currentUser)

    try await Task.sleep(nanoseconds: 2_000_000_000)

    try await channel.sendText(text: "Some new text")
    try await channel2.sendText(text: "Some new text")
    try await channel3.sendText(text: "Some new text")

    try await Task.sleep(nanoseconds: 2_000_000_000)

    let firstFetchResponse = try await chat.fetchUnreadMessagesCounts(limit: 1)
    let firstPage = try XCTUnwrap(firstFetchResponse.page)

    XCTAssertEqual(firstFetchResponse.countsByChannel.count, 1)
    XCTAssertTrue(firstFetchResponse.countsByChannel.allSatisfy { $0.count == 1 })

    let secondFetchResponse = try await chat.fetchUnreadMessagesCounts(page: firstPage)
    let secondPage = try XCTUnwrap(secondFetchResponse.page)

    XCTAssertEqual(secondFetchResponse.countsByChannel.count, 2)
    XCTAssertTrue(secondFetchResponse.countsByChannel.allSatisfy { $0.count == 1 })

    let thirdFetchResponse = try await chat.fetchUnreadMessagesCounts(page: secondPage)
    XCTAssertTrue(thirdFetchResponse.countsByChannel.isEmpty)

    addTeardownBlock { [unowned self] in
      _ = try? await channel.leave()
      _ = try? await channel2.leave()
      _ = try? await channel3.leave()
      _ = try? await chat.deleteChannel(id: channel.id)
      _ = try? await chat.deleteChannel(id: channel2.id)
      _ = try? await chat.deleteChannel(id: channel3.id)
    }
  }

  func testChatAsync_MarkAllMessagesAsRead() async throws {
    let channel = try await chat.createChannel(id: randomString())

    try await channel.invite(user: chat.currentUser)
    try await channel.sendText(text: "Some new text")
    try await channel.sendText(text: "Some new text")
    try await channel.sendText(text: "Some new text")

    try await Task.sleep(nanoseconds: 4_000_000_000)
    try await chat.markAllMessagesAsRead()

    try await Task.sleep(nanoseconds: 4_000_000_000)
    let getUnreadMessagesCount = try await chat.getUnreadMessagesCount()

    XCTAssertTrue(getUnreadMessagesCount.isEmpty)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_GetEventsHistory() async throws {
    let channel = try await chat.createChannel(
      id: randomString(),
      name: "Channel name"
    )

    try await channel.invite(user: chat.currentUser)
    try await Task.sleep(nanoseconds: 4_000_000_000)

    let history = try await chat.getEventsHistory(channelId: chat.currentUser.id)
    let inviteEvent = try XCTUnwrap(history.events.compactMap { $0.event.payload as? EventContent.Invite }.first)

    XCTAssertEqual(inviteEvent.channelId, channel.id)
    XCTAssertEqual(inviteEvent.channelType, .unknown)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_GetCurrentUserMentions() async throws {
    let channel = try await chat.createChannel(
      id: randomString(),
      name: "Channel name"
    )

    try await channel.invite(user: chat.currentUser)
    let tt = try await channel.sendText(text: "Some text")
    try await Task.sleep(nanoseconds: 2_000_000_000)

    try await chat.emitEvent(
      channelId: chat.currentUser.id,
      payload: EventContent.Mention(messageTimetoken: tt, channel: channel.id)
    )

    try await Task.sleep(nanoseconds: 3_000_000_000)
    let userMentionData = try await chat.getCurrentUserMentions().mentions.first

    XCTAssertEqual(userMentionData?.userMentionData.userId, chat.currentUser.id)
    XCTAssertEqual(userMentionData?.userMentionData.event.channel, channel.id)
    XCTAssertEqual(userMentionData?.userMentionData.message?.timetoken, tt)
    XCTAssertEqual(userMentionData?.userMentionData.message?.text, "Some text")

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_CustomPayload() async throws {
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

    let channel = try await anotherChat.createChannel(id: randomString())

    try await channel.sendText(text: "Some text")
    try await Task.sleep(nanoseconds: 2_000_000_000)

    let message = try await channel.getHistory(count: 1).messages.first

    XCTAssertEqual(message?.text, "Some text")
    XCTAssertTrue(message?.files.isEmpty ?? false)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testChatAsync_MutedUsers() async throws {
    let userToMute = randomString()

    try await chat.mutedUsersManager.muteUser(userId: userToMute)
    XCTAssertEqual(chat.mutedUsersManager.mutedUsers, [userToMute])

    try await chat.mutedUsersManager.unmuteUser(userId: userToMute)
    XCTAssertTrue(chat.mutedUsersManager.mutedUsers.isEmpty)
  }

  func testChatAsync_RemoveChannelGroup() async throws {
    let channelGroup = chat.getChannelGroup(id: randomString())
    try await channelGroup.addChannelIdentifiers([randomString()])
    try await chat.removeChannelGroup(id: channelGroup.id)
  }

  func testChatAsync_ConnectionStatusListener() async throws {
    let expectation = expectation(description: "Status Listener")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 2

    let channel = try await chat.createChannel(id: randomString())

    let statusStreamTask = Task { [weak chat] in
      if let chat {
        for await status in chat.connectionStatusStream().prefix(2) {
          if status == .online {
            expectation.fulfill()
            chat.disconnectSubscriptions()
          } else if status == .offline {
            expectation.fulfill()
          } else {
            XCTFail("Unexpected condition")
          }
        }
      } else {
        XCTFail("Unexpected condition")
      }
    }

    let connectTask = Task {
      for await message in channel.connect() {
        debugPrint(message)
      }
    }

    addTeardownBlock { [unowned self] in
      statusStreamTask.cancel()
      connectTask.cancel()
      _ = try? await chat.deleteChannel(id: channel.id)
    }

    await fulfillment(of: [expectation], timeout: 4)
  }

  func testChatAsync_ReconnectSubscriptions() async throws {
    let expectation = expectation(description: "Status Listener")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 3

    let channel = try await chat.createChannel(id: randomString())

    let statusStreamTask = Task { [weak chat] in
      if let chat {
        for await status in chat.connectionStatusStream().prefix(3) {
          if status == .online {
            expectation.fulfill()
            chat.disconnectSubscriptions()
          } else if status == .offline {
            expectation.fulfill()
            chat.reconnectSubscriptions()
          } else {
            XCTFail("Unexpected condition")
          }
        }
      } else {
        XCTFail("Unexpected condition")
      }
    }

    let connectTask = Task {
      for await message in channel.connect() {
        debugPrint(message)
      }
    }

    addTeardownBlock { [unowned self] in
      statusStreamTask.cancel()
      connectTask.cancel()
      _ = try? await chat.deleteChannel(id: channel.id)
    }

    await fulfillment(of: [expectation], timeout: 4)
  }

  // swiftlint:disable:next file_length
}
