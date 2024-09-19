//
//  SwiftChatSDKIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import XCTest
import PubNubChat
import PubNubSwiftChatSDK
import PubNubSDK

// MARK: - SwiftChatSDKIntegrationTests

class PubNubSwiftChatSDKIntegrationTests: XCTestCase {
  var chat: PubNubSwiftChatSDK.ChatImpl!

  private lazy var configuration: [String: String] = {
    readPropertyList()
  }()

  override func setUpWithError() throws {
    try super.setUpWithError()

    let pubNubConfiguration = PubNubConfiguration(
      publishKey: configuration["publishKey"]!,
      subscribeKey: configuration["subscribeKey"]!,
      userId: randomString()
    )
    chat = ChatImpl(
      chatConfiguration: ChatConfiguration(storeUserActivityTimestamps: true),
      pubNubConfiguration: pubNubConfiguration
    )

    try awaitResultValue { chat.initialize(completion: $0) }
    try customSetUpWitError()
  }

  override func tearDownWithError() throws {
    try customTearDownWithError()
    try awaitResultValue { chat.deleteUser(id: chat.currentUser.id, completion: $0) }
    
    chat = nil
    
    try super.tearDownWithError()
  }
}

extension PubNubSwiftChatSDKIntegrationTests {
  func customSetUpWitError() throws {}
  func customTearDownWithError() throws {}
}

// MARK: - Helpers

extension PubNubSwiftChatSDKIntegrationTests {
  private func readPropertyList() -> [String: String] {
    let resourceName = "PubNubSwiftChatSDKTests"
    let resourceExtension = "plist"

    guard let infoPlistPath = Bundle(
      for: PubNubSwiftChatSDKIntegrationTests.self
    ).url(
      forResource: resourceName,
      withExtension: resourceExtension
    ) else {
      fatalError("Cannot read \(resourceName).\(resourceExtension) file")
    }

    guard let infoPlistData = try? Data(contentsOf: infoPlistPath) else {
      fatalError("Cannot read content of \(resourceName).\(resourceExtension) file")
    }

    guard let dictionary = try? PropertyListSerialization.propertyList(
      from: infoPlistData,
      options: [],
      format: nil
    ) as? [String: String] else {
      fatalError("Cannot serialize \(resourceName).\(resourceExtension) into Dictionary")
    }

    return dictionary
  }
}

extension PubNubSwiftChatSDKIntegrationTests {
  func randomString(length: Int = 6) -> String {
    // Define the characters set (alphanumeric)
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    // Ensure length is within the desired range
    let length = max(1, min(length, 6))
    // Generate the random string
    return String((0..<length).map { _ in letters.randomElement()! })
  }
}

extension PubNubSwiftChatSDKIntegrationTests {

  // Synchronously waits for an asynchronous operation that returns a `Result`
  // and retrieves the successful value
  @discardableResult
  func awaitResultValue<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> T {
    try awaitResult(
      delay: delay,
      timeout: timeout,
      operation: operation
    ).get()
  }

  // Synchronously waits for an asynchronous operation that returns a `Result`
  // and retrieves the `Error` value
  @discardableResult
  func awaitResultError<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> E {
    switch try awaitResult(delay: delay, timeout: timeout, operation: operation) {
    case .success:
      fatalError("Unexpected condition")
    case .failure(let error):
      return error
    }
  }

  // Synchronously waits for an asynchronous operation that returns a Result,
  // and then returns it to the caller
  @discardableResult
  func awaitResult<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> Swift.Result<T, E> {

    // Waits for the specified number of seconds if the call needs to be delayed
    if delay > 0 {
      wait(delay)
    }

    // Create an XCTestExpectation to pause the test execution
    // until the asynchronous operation completes
    let expectation = expectation(description: "Waiting for an async operation")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1

    // A variable to store the result of the asynchronous operation
    var result: Swift.Result<T, E>!

    // Execute the asynchronous operation and capture the result
    try operation { res in
      result = res
      expectation.fulfill()
    }

    // Wait for the expectation to be fulfilled or until the timeout occurs
    wait(for: [expectation], timeout: timeout + 1)

    // If the result is a success, return the value
    return result
  }
}

extension PubNubSwiftChatSDKIntegrationTests {
  private func wait(_ duration: TimeInterval) {
    // Define the expectation to fulfill
    let expectation = expectation(description: "Waiting for \(duration) seconds")
    // Dispatch a delay on a background queue
    DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
      expectation.fulfill()
    }
    // Wait for the expectation to be fulfilled or timeout
    wait(for: [expectation], timeout: duration + 1)
  }
}
