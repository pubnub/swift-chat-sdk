//
//  BaseIntegrationTestCase.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import XCTest
import PubNubSDK
import PubNubSwiftChatSDK

class BaseIntegrationTestCase: XCTestCase {
  var chat: ChatImpl! = IntegrationTestCaseConfiguration.createChatObject()
}

extension BaseIntegrationTestCase {
  func randomString(length: Int = 6) -> String {
    RandomStringGenerator().randomString(length: length)
  }
}
