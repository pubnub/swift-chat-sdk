//
//  PubNubSwiftChatSDKIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubChat
import PubNubSDK
import PubNubSwiftChatSDK
import XCTest

<<<<<<< Updated upstream:Tests/PubNubSwiftChatSDKIntegrationTests.swift
class PubNubSwiftChatSDKIntegrationTests: XCTestCase {
  var chat: PubNubSwiftChatSDK.ChatImpl!

  private lazy var configuration: [String: String] = readPropertyList()

=======
class BaseClosureIntegrationTestCase: BaseIntegrationTestCase {
>>>>>>> Stashed changes:Tests/BaseClosureIntegrationTestCase.swift
  override func setUpWithError() throws {
    try super.setUpWithError()

    try awaitResultValue { chat.initialize(completion: $0) }
    try customSetUpWitError()
  }

  override func tearDownWithError() throws {
    try customTearDownWithError()
<<<<<<< Updated upstream:Tests/PubNubSwiftChatSDKIntegrationTests.swift
    try awaitResultValue { chat.deleteUser(id: chat.currentUser.id, completion: $0) }

=======
    try awaitResult { chat.deleteUser(id: chat.currentUser.id, completion: $0) }
    
>>>>>>> Stashed changes:Tests/BaseClosureIntegrationTestCase.swift
    chat = nil

    try super.tearDownWithError()
  }
}

// An extension to provide custom setup and teardown logic in test cases. This extension introduces helper methods
// that are called after the basic setup or before the teardown logic. These methods allow test cases to perform
// additional, custom configuration or cleanup without duplicating common setup and teardown code.
extension BaseClosureIntegrationTestCase {
  func customSetUpWitError() throws {}
  func customTearDownWithError() throws {}
}

<<<<<<< Updated upstream:Tests/PubNubSwiftChatSDKIntegrationTests.swift
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
    return String((0 ..< length).map { _ in letters.randomElement()! })
  }
}

extension PubNubSwiftChatSDKIntegrationTests {
=======
// An extension to simplify testing of closure-based methods by providing a cleaner, linear syntax.
//
// This extension uses `XCTestExpectation` to flatten the structure of closure-based tests,
// reducing the need for nested closures. It allows tests to appear sequential and easier
// to follow without changing the underlying closure-based behavior.
///
// This is not a replacement for Swift's native `async-await` but rather a way to improve
// the readability of tests that involve multiple asynchronous calls with completion handlers.
extension BaseClosureIntegrationTestCase {
>>>>>>> Stashed changes:Tests/BaseClosureIntegrationTestCase.swift
  // Synchronously waits for an asynchronous operation that returns a `Result`
  // and retrieves the successful value
  @discardableResult
  func awaitResultValue<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    description: String = "Waiting for the operation to complete",
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> T {
    try awaitResult(
      delay: delay,
      timeout: timeout,
      description: description,
      operation: operation
    ).get()
  }

  // Synchronously waits for an asynchronous operation that returns a `Result`
  // and retrieves the `Error` value
  @discardableResult
  func awaitResultError<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    description: String = "Waiting for the operation to complete",
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> E {
    switch try awaitResult(delay: delay, timeout: timeout, description: description, operation: operation) {
    case .success:
      fatalError("Unexpected condition")
    case let .failure(error):
      error
    }
  }

  // Synchronously waits for an asynchronous operation that returns a Result,
  // and then returns it to the caller
  @discardableResult
  func awaitResult<T, E: Error>(
    delay: TimeInterval = 0,
    timeout: TimeInterval = 5,
    description: String = "Waiting for the operation to complete",
    operation: (@escaping (Swift.Result<T, E>) -> Void) throws -> Void
  ) throws -> Swift.Result<T, E> {
    // Waits for the specified number of seconds if the call needs to be delayed
    if delay > 0 {
      wait(delay)
    }

    // Create an XCTestExpectation to pause the test execution
    // until the asynchronous operation completes
    let expectation = expectation(description: description)
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
  
  private func wait(_ duration: TimeInterval) {
    // Define the expectation to fulfill
    let expectation = expectation(description: "Waiting for \(duration) seconds")
    
    // Dispatch a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      expectation.fulfill()
    }
    
    // Wait for the expectation to be fulfilled
    wait(for: [expectation], timeout: duration + 1)
  }
}