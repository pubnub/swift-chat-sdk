//
//  MessageDraftIntegrationTests.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import XCTest

@testable import PubNubSwiftChatSDK

class MessageDraftIntegrationTests: PubNubSwiftChatSDKIntegrationTests {
  private var user: UserImpl!
  private var channel: ChannelImpl!
  
  override func customSetUpWitError() throws {
    let channelId = "chnl\(randomString())"
    let userId = "user\(randomString())"
    
    channel = try awaitResultValue {
      chat.createChannel(
        id: channelId,
        name: channelId,
        completion: $0
      )
    }
    user = try awaitResultValue {
      chat.createUser(
        user: UserImpl(chat: chat, id: userId, name: userId),
        completion: $0
      )
    }
    
    try awaitResultValue {
      channel.invite(
        user: user,
        completion: $0
      )
    }
  }
  
  override func customTearDownWithError() throws {
    try awaitResult { [unowned self] in
      chat.deleteUser(
        id: user.id,
        completion: $0
      )
    }
    try awaitResult { [unowned self] in
      chat.deleteChannel(
        id: channel.id,
        completion: $0
      )
    }
  }
  
  func test_MessageDraftWithUserMention() throws {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1
        
    let messageDraft = channel.createMessageDraft()
    let listener = ExampleMessageDraftListener(onChange: { elements, future in
      if !elements.containsAnyMention() {
        future.async() {
          switch $0 {
          case let .success(suggestedMentions):
            suggestedMentions.forEach {
              messageDraft.insertSuggestedMention(
                mention: $0,
                text: $0.replaceTo
              )
            }
            expectation.fulfill()
          case let .failure(error):
            XCTFail("Unexpected condition due to error: \(error)")
          }
        }
      }      
    })
    
    messageDraft.addMessageElementsListener(listener)
    messageDraft.update(text: "This is a @user")
    
    wait(for: [expectation], timeout: 6)
    
    let timetoken = try awaitResultValue {
      messageDraft.send(
        meta: nil,
        shouldStore: true,
        usePost: false,
        ttl: nil,
        completion: $0
      )
    }
    
    let message = try awaitResultValue(delay: 3) {
      channel.getMessage(
        timetoken: timetoken,
        completion: $0
      )
    }
    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: user.id, target: .user(userId: user.id))
    ]
    
    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }
  
  func test_MessageDraftWithChannelMention() throws {
    let expectation = expectation(description: "MessageDraft")
    expectation.assertForOverFulfill = true
    expectation.expectedFulfillmentCount = 1
        
    let messageDraft = channel.createMessageDraft()
    let listener = ExampleMessageDraftListener(onChange: { elements, future in
      if !elements.containsAnyMention() {
        future.async() {
          switch $0 {
          case let .success(suggestedMentions):
            suggestedMentions.forEach {
              messageDraft.insertSuggestedMention(
                mention: $0,
                text: $0.replaceTo
              )
            }
            expectation.fulfill()
          case let .failure(error):
            XCTFail("Unexpected condition due to error: \(error)")
          }
        }
      }
    })
    
    messageDraft.addMessageElementsListener(listener)
    messageDraft.update(text: "This is a #chnl")
    
    wait(for: [expectation], timeout: 6)
    
    let timetoken = try awaitResultValue {
      messageDraft.send(
        meta: nil,
        shouldStore: true,
        usePost: false,
        ttl: nil,
        completion: $0
      )
    }
    
    let message = try awaitResultValue(delay: 3) {
      channel.getMessage(
        timetoken: timetoken,
        completion: $0
      )
    }
    let expectedElements: [MessageElement] = [
      .plainText(text: "This is a "),
      .link(text: channel.id, target: .channel(channelId: channel.id))
    ]
    
    XCTAssertEqual(
      expectedElements,
      message?.getMessageElements() ?? []
    )
  }
}

class ExampleMessageDraftListener: MessageDraftStateListener {
  let onChangeClosure: (([MessageElement], SuggestedMentionsFuture) -> Void)
  
  init(onChange: @escaping ([MessageElement], SuggestedMentionsFuture) -> Void) {
    self.onChangeClosure = onChange
  }
  
  func onChange(messageElements: [MessageElement], suggestedMentions: SuggestedMentionsFuture) {
    onChangeClosure(messageElements, suggestedMentions)
  }
}
