//
//  UserAsyncIntegrationTests.swift
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

class UserAsyncIntegrationTests: BaseAsyncIntegrationTestCase {
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

  func testUserAsync_CreateUser() async throws {
    let user = testableUser()
    let createdUser = try await chat.createUser(user: user)

    XCTAssertEqual(createdUser.id, user.id)
    XCTAssertEqual(createdUser.name, user.name)
    XCTAssertEqual(createdUser.externalId, user.externalId)
    XCTAssertEqual(createdUser.profileUrl, user.profileUrl)
    XCTAssertEqual(createdUser.email, user.email)
    XCTAssertEqual(createdUser.custom?.mapValues { $0.scalarValue }, user.custom?.mapValues { $0.scalarValue })
    XCTAssertEqual(createdUser.status, user.status)
    XCTAssertEqual(createdUser.type, user.type)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: user.id)
    }
  }

  func testUserAsync_UpdateUser() async throws {
    let newCustom: [String: JSONCodableScalar] = [
      "age": 21,
      "city": "Birmingham"
    ]
    let updatedUser = try await chat.currentUser.update(
      name: "Markus Koller",
      externalId: "11111111",
      profileUrl: "https://picsum.photos/200/300",
      email: "markus.koller@pubnub.com",
      custom: newCustom,
      status: "inactive",
      type: "regular"
    )

    XCTAssertEqual(updatedUser.name, "Markus Koller")
    XCTAssertEqual(updatedUser.externalId, "11111111")
    XCTAssertEqual(updatedUser.profileUrl, "https://picsum.photos/200/300")
    XCTAssertEqual(updatedUser.email, "markus.koller@pubnub.com")
    XCTAssertEqual(updatedUser.custom?.compactMapValues { $0.scalarValue }, newCustom.mapValues { $0.scalarValue })
    XCTAssertEqual(updatedUser.status, "inactive")
    XCTAssertEqual(updatedUser.type, "regular")
  }

  func testUserAsync_UpdateUserCallback() async throws {
    _ = try await chat.currentUser.update(
      name: "Markus Koller",
      externalId: "11111111",
      profileUrl: "https://picsum.photos/200/300",
      email: "markus.koller@pubnub.com",
      status: "inactive",
      type: "regular"
    )

    // Simulates updating an outdated version of the User object.
    // We expect the fresh object from the server to be returned first, and then subsequent updates to be applied on top of it
    let updateResult = try await chat.currentUser.update {
      [
        .stringOptional(\.name, $0.name?.uppercased()),
        .stringOptional(\.status, $0.status?.uppercased())
      ]
    }

    XCTAssertEqual(updateResult.name, "MARKUS KOLLER")
    XCTAssertEqual(updateResult.status, "INACTIVE")
  }

  func testUserAsync_UpdateNotExistingUser() async throws {
    let errorExpectation = XCTestExpectation(description: "ErrorExpectation")
    errorExpectation.assertForOverFulfill = true
    errorExpectation.expectedFulfillmentCount = 1

    let someUser = testableUser()

    do {
      _ = try await someUser.update(name: "NewName", externalId: "NewExternalId")
    } catch {
      XCTAssertEqual((error as? ChatError)?.message, "User does not exist")
      errorExpectation.fulfill()
    }

    await fulfillment(of: [errorExpectation], timeout: 4)
  }

  func testUserAsync_IsPresentOn() async throws {
    let channelId = randomString()
    let createdChannel = try await chat.createChannel(id: channelId, name: channelId)

    // Keeps a strong reference to the returned AsyncStream to prevent it from being deallocated. If this object is not retained,
    // the AsyncStream will be deallocated, which would cause the behavior being tested to fail.
    let connectResult = createdChannel.connect()
    debugPrint(connectResult)

    try await Task.sleep(nanoseconds: 4_000_000_000)
    let isPresent = try await chat.currentUser.isPresentOn(channelId: createdChannel.id)
    XCTAssertTrue(isPresent)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channelId)
    }
  }

  func testUserAsync_Delete() async throws {
    let createdUser = try await chat.createUser(user: testableUser())
    let deletedUser = try await createdUser.delete(soft: false)

    XCTAssertNil(deletedUser)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: createdUser.id)
    }
  }

  func testUserAsync_SoftDelete() async throws {
    let createdUser = try await chat.createUser(user: testableUser())
    let deletedUser = try await createdUser.delete(soft: true)

    XCTAssertFalse(deletedUser?.active ?? true)
    XCTAssertEqual(createdUser.id, deletedUser?.id)

     addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteUser(id: createdUser.id)
    }
  }

  func testUserAsync_DeleteNotExistingUser() async throws {
    let someUser = testableUser()
    let resultValue = try await someUser.delete(soft: false)

    XCTAssertNil(resultValue)
  }

  func testUserAsync_WherePresent() async throws {
    let channelId = randomString()
    let channel = try await chat.createChannel(id: channelId, name: channelId)

    // Keeps a strong reference to the returned AsyncStream to prevent it from being deallocated. If this object is not retained,
    // the AsyncStream will be deallocated, which would cause the behavior being tested to fail.
    let connectResult = channel.connect()
    debugPrint(connectResult)

    try await Task.sleep(nanoseconds: 5_000_000_000)

    let channelIdentifiers = try await chat.currentUser.wherePresent()
    let expectedChannelIdentifiers = [channelId]

    XCTAssertEqual(
      expectedChannelIdentifiers,
      channelIdentifiers
    )

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testUserAsync_GetMemberships() async throws {
    let channel = try await chat.createChannel(id: randomString())

    try await channel.invite(user: chat.currentUser)
    let getMembershipsValue = try await chat.currentUser.getMemberships()

    XCTAssertEqual(try (XCTUnwrap(getMembershipsValue.memberships.first)).user.id, chat.currentUser.id)
    XCTAssertEqual(try (XCTUnwrap(getMembershipsValue.memberships.first)).channel.id, channel.id)

    addTeardownBlock { [unowned self] in
      _ = try? await chat.deleteChannel(id: channel.id)
    }
  }

  func testUserAsync_StreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    let createdUser = try await chat.createUser(user: testableUser())

    let task = Task {
      for await updatedUser in createdUser.streamUpdates() {
        XCTAssertEqual(updatedUser?.name, "NewName")
        XCTAssertEqual(updatedUser?.externalId, "NewExternalId")
        XCTAssertEqual(updatedUser?.profileUrl, "NewProfileUrl")
        XCTAssertEqual(updatedUser?.email, "NewEmail")
        XCTAssertEqual(updatedUser?.custom?.mapValues { $0.scalarValue }, ["city": "Manchester"].mapValues { $0.scalarValue })
        XCTAssertEqual(updatedUser?.status, "NewStatus")
        XCTAssertEqual(updatedUser?.type, "NewType")
        expectation.fulfill()
      }
    }

    try await Task.sleep(nanoseconds: 3_000_000_000)

    _ = try await createdUser.update(
      name: "NewName",
      externalId: "NewExternalId",
      profileUrl: "NewProfileUrl",
      email: "NewEmail",
      custom: ["city": "Manchester"],
      status: "NewStatus",
      type: "NewType"
    )

    await fulfillment(of: [expectation], timeout: 6)

    addTeardownBlock { [unowned self] in
      task.cancel()
      _ = try? await chat.deleteUser(id: createdUser.id)
    }
  }

  func testUserAsync_GlobalStreamUpdates() async throws {
    let expectation = expectation(description: "StreamUpdates")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 2

    let firstUser = try await chat.createUser(user: testableUser())
    let secondUser = try await chat.createUser(user: testableUser())

    let task = Task {
      for await users in UserImpl.streamUpdatesOn(users: [firstUser, secondUser]) {
        if users.first?.id ?? "" == firstUser.id {
          expectation.fulfill()
        } else if users.first?.id ?? "" == secondUser.id {
          expectation.fulfill()
        } else {
          XCTFail("Unexpected condition")
        }
      }
    }

    for user in [firstUser, secondUser] {
      try await Task.sleep(nanoseconds: 3_000_000_000)
      _ = try await user.update(
        name: randomString(),
        externalId: nil,
        profileUrl: nil,
        email: nil,
        custom: nil,
        status: nil,
        type: nil
      )
    }

    await fulfillment(
      of: [expectation],
      timeout: 6
    )

    addTeardownBlock { [unowned self] in
      task.cancel()
      _ = try? await chat.deleteUser(id: firstUser.id)
      _ = try? await chat.deleteUser(id: secondUser.id)
    }
  }
}
