//
//  UserIntegrationTests.swift
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

final class UserIntegrationTests: BaseClosureIntegrationTestCase {
  func testableUser() -> PubNubSwiftChatSDK.UserImpl {
    UserImpl(
      chat: chat,
      id: randomString(),
      name: "Marian Salazar",
      externalId: "5445888223",
      profileUrl: "https://picsum.photos/100/200",
      email: "marian.salazar@pubnub.com",
      custom: ["age": 36, "city": "London"],
      status: "active",
      type: "admin"
    )
  }

  func testUser_CreateUser() throws {
    let user = testableUser()
    let createdUser = try awaitResultValue { chat.createUser(user: user, completion: $0) }

    XCTAssertEqual(createdUser.id, user.id)
    XCTAssertEqual(createdUser.name, user.name)
    XCTAssertEqual(createdUser.externalId, user.externalId)
    XCTAssertEqual(createdUser.profileUrl, user.profileUrl)
    XCTAssertEqual(createdUser.email, user.email)
    XCTAssertEqual(createdUser.custom?.mapValues { $0.scalarValue }, user.custom?.mapValues { $0.scalarValue })
    XCTAssertEqual(createdUser.status, user.status)
    XCTAssertEqual(createdUser.type, user.type)

    addTeardownBlock { [unowned self] in
      try awaitResult { chat.deleteUser(
        id: user.id,
        completion: $0
      ) }
    }
  }

  func testUser_UpdateUser() throws {
    let newCustom: [String: JSONCodableScalar] = [
      "age": 21,
      "city": "Birmingham"
    ]
    let updatedUser = try awaitResultValue {
      chat.currentUser.update(
        name: "Markus Koller",
        externalId: "11111111",
        profileUrl: "https://picsum.photos/200/300",
        email: "markus.koller@pubnub.com",
        custom: newCustom,
        status: "inactive",
        type: "regular",
        completion: $0
      )
    }

    XCTAssertEqual(updatedUser.name, "Markus Koller")
    XCTAssertEqual(updatedUser.externalId, "11111111")
    XCTAssertEqual(updatedUser.profileUrl, "https://picsum.photos/200/300")
    XCTAssertEqual(updatedUser.email, "markus.koller@pubnub.com")
    XCTAssertEqual(updatedUser.custom?.compactMapValues { $0.scalarValue }, newCustom.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedUser.status, "inactive")
    XCTAssertEqual(updatedUser.type, "regular")
  }

  func testUser_UpdateNotExistingUser() throws {
    let someUser = testableUser()
    let error = try awaitResultError {
      someUser.update(
        name: "NewName",
        externalId: "NewExternalId",
        completion: $0
      )
    }

    XCTAssertEqual((error as? ChatError)?.message, "User does not exist")
  }

  func testUser_IsPresentOn() throws {
    let channelId = randomString()
    let createdChannel = try awaitResultValue { chat.createChannel(id: channelId, name: channelId, completion: $0) }
    let closeable = createdChannel.connect(callback: { _ in })

    XCTAssertTrue(try awaitResultValue(delay: 4) {
      chat.currentUser.isPresentOn(
        channelId: createdChannel.id,
        completion: $0
      )
    })
    addTeardownBlock { [unowned self] in
      try awaitResult {
        chat.deleteChannel(
          id: createdChannel.id,
          completion: $0
        )
      }
      closeable.close()
    }
  }

  func testUser_Delete() throws {
    let createdUser = try awaitResultValue {
      chat.createUser(
        user: testableUser(),
        completion: $0
      )
    }
    let deletedUser = try awaitResultValue {
      createdUser.delete(
        soft: false,
        completion: $0
      )
    }

    XCTAssertNil(deletedUser)
  }

  func testUser_SoftDelete() throws {
    let createdUser = try awaitResultValue {
      chat.createUser(
        user: testableUser(),
        completion: $0
      )
    }
    let deletedUser = try awaitResultValue {
      createdUser.delete(
        soft: true,
        completion: $0
      )
    }

    XCTAssertEqual(
      createdUser.id,
      deletedUser?.id
    )
  }

  func testUser_DeleteNotExistingUser() throws {
    let someUser = testableUser()
    let resultValue = try awaitResultValue { someUser.delete(soft: false, completion: $0) }

    XCTAssertNil(resultValue)
  }

  func testUser_WherePresent() throws {
    let channelId = randomString()
    let channel = try awaitResultValue { chat.createChannel(id: channelId, name: channelId, completion: $0) }
    let closeable = channel.connect(callback: { _ in })

    XCTAssertEqual(
      try awaitResultValue(delay: 5) {
        chat.currentUser.wherePresent(completion: $0)
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

  func testUser_IsActive() throws {
    let channelId = randomString()
    let channel = try awaitResultValue { chat.createChannel(id: channelId, name: channelId, completion: $0) }
    let closeable = channel.connect(callback: { _ in })

    XCTAssertTrue(
      try awaitResultValue(delay: 4) {
        chat.currentUser.active(
          completion: $0
        )
      }
    )

    addTeardownBlock { [unowned self] in
      try awaitResultValue {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
      closeable.close()
    }
  }

  func testUser_GetMemberships() throws {
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
    let resultValue = try awaitResultValue {
      chat.currentUser.getMemberships(
        limit: nil,
        page: nil,
        filter: nil,
        sort: [],
        completion: $0
      )
    }

    XCTAssertEqual(try (XCTUnwrap(resultValue.memberships.first)).user.id, chat.currentUser.id)
    XCTAssertEqual(try (XCTUnwrap(resultValue.memberships.first)).channel.id, channel.id)

    addTeardownBlock { [unowned self] in
      try awaitResultValue {
        chat.deleteChannel(
          id: channel.id,
          completion: $0
        )
      }
    }
  }

  func testUser_StreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let createdUser = try awaitResultValue {
      chat.createUser(
        user: testableUser(),
        completion: $0
      )
    }
    let closeable = createdUser.streamUpdates { user in
      XCTAssertEqual(user?.name, "NewName")
      XCTAssertEqual(user?.externalId, "NewExternalId")
      XCTAssertEqual(user?.profileUrl, "NewProfileUrl")
      XCTAssertEqual(user?.email, "NewEmail")
      XCTAssertEqual(user?.custom?.mapValues { $0.scalarValue }, ["city": "Manchester"].mapValues { $0.scalarValue })
      XCTAssertEqual(user?.status, "NewStatus")
      XCTAssertEqual(user?.type, "NewType")
      expectation.fulfill()
    }

    try awaitResultValue(delay: 3) {
      createdUser.update(
        name: "NewName",
        externalId: "NewExternalId",
        profileUrl: "NewProfileUrl",
        email: "NewEmail",
        custom: ["city": "Manchester"],
        status: "NewStatus",
        type: "NewType",
        completion: $0
      )
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      // First, close AutoCloseable to prevent receiving stream updates while performing
      // cleanup at the end of the test
      closeable.close()

      try awaitResult {
        chat.deleteUser(
          id: createdUser.id,
          completion: $0
        )
      }
    }
  }

  func testUser_GlobalStreamUpdates() throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 2

    let firstUser = try awaitResultValue { chat.createUser(user: testableUser(), completion: $0) }
    let secondUser = try awaitResultValue { chat.createUser(user: testableUser(), completion: $0) }

    let closeable = UserImpl.streamUpdatesOn(users: [firstUser, secondUser]) { users in
      if users.first?.id ?? "" == firstUser.id {
        expectation.fulfill()
      } else if users.first?.id ?? "" == secondUser.id {
        expectation.fulfill()
      } else {
        XCTFail("Unexpected condition")
      }
    }

    for user in [firstUser, secondUser] {
      try awaitResultValue(delay: 3) {
        user.update(
          name: randomString(),
          externalId: nil,
          profileUrl: nil,
          email: nil,
          custom: nil,
          status: nil,
          type: nil,
          completion: $0
        )
      }
    }

    wait(
      for: [expectation],
      timeout: 6
    )
    addTeardownBlock { [unowned self] in
      // First, close AutoCloseable to prevent receiving stream updates while performing
      // cleanup at the end of the test
      closeable.close()

      try awaitResult {
        chat.deleteUser(
          id: firstUser.id,
          completion: $0
        )
      }
      try awaitResult {
        chat.deleteUser(
          id: secondUser.id,
          completion: $0
        )
      }
    }
  }
}
