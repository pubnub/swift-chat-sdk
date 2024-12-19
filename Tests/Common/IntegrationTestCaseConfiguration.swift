//
//  IntegrationTestCaseConfiguration.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import PubNubSwiftChatSDK

// A class that reduces the effort of creating the Chat object required for each test case.
//
// This class centralizes the logic for creating the Chat object which is needed across multiple test cases.
// By using this class, you can avoid repeating setup code in each test, simplifying test initialization.
// Each test case should instantiate its own `createChatObject(from:pubNubConfiguration:) to ensure there is no shared global state between tests.
enum IntegrationTestCaseConfiguration {
  // Static factory method to create a new instance of Chat for each test case. This method ensures that each test case
  // gets a fresh configuration instance, preventing shared state and ensuring tests are independent of each other.
  static func createChatObject(
    from chatConfiguration: ChatConfiguration? = nil,
    pubNubConfiguration: PubNubConfiguration? = nil
  ) -> ChatImpl {
    let pubNubConfigurationToApply = pubNubConfiguration ?? createPubNubConfigurationFromDefaultPropertyList()
    let chatConfigurationToApply = chatConfiguration ?? ChatConfiguration(storeUserActivityTimestamps: true)

    return ChatImpl(
      chatConfiguration: chatConfigurationToApply,
      pubNubConfiguration: pubNubConfigurationToApply
    )
  }

  static func createPubNubConfigurationFromDefaultPropertyList() -> PubNubConfiguration {
    let resourceName = "PubNubSwiftChatSDKTests"
    let resourceExtension = "plist"

    guard let infoPlistPath = Bundle(
      for: BaseIntegrationTestCase.self
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

    return PubNubConfiguration(
      publishKey: dictionary["publishKey"]!,
      subscribeKey: dictionary["subscribeKey"]!,
      userId: RandomStringGenerator().randomString()
    )
  }
}
