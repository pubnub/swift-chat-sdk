//
//  BaseAsyncIntegrationTestCase.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSwiftChatSDK
import XCTest

class BaseAsyncIntegrationTestCase: BaseIntegrationTestCase {
  override func setUp() async throws {
    try await super.setUp()
    try await chat.initialize()
    try await customSetup()
  }

  override func tearDown() async throws {
    try await customTearDown()
    _ = try await chat.deleteUser(id: chat.currentUser.id)

    chat = nil

    try await super.tearDown()
  }
}

// An extension to provide custom setup and teardown logic in test cases. This extension introduces helper methods
// that are called after the basic setup or before the teardown logic. These methods allow test cases to perform
// additional, custom configuration or cleanup without duplicating common setup and teardown code.
extension BaseAsyncIntegrationTestCase {
  func customSetup() async throws {}
  func customTearDown() async throws {}
}
