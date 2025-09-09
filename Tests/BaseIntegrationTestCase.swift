//
//  BaseIntegrationTestCase.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSDK
import PubNubSwiftChatSDK
import XCTest

class BaseIntegrationTestCase: XCTestCase {
  lazy var chat: ChatImpl! = IntegrationTestCaseConfiguration.createChatObject()
}

extension BaseIntegrationTestCase {
  func randomString(length: Int = 6, withPrefix: Bool = true) -> String {
    let randomStr = RandomStringGenerator().randomString(length: length)
    return withPrefix ? "swift-chat" + randomStr : randomStr
  }
}
