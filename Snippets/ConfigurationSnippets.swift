//
//  ConfigurationSnippets.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import PubNubSDK
import PubNubSwiftChatSDK

// MARK: - Basic Initialization

func initializeChat() async throws {
  // snippet.configuration.initialize
  // An example of how to initialize the top-level ChatImpl object
  // Create PubNub configuration
  let pubNubConfiguration = PubNubConfiguration(
    publishKey: "your-publish-key",
    subscribeKey: "your-subscribe-key",
    userId: "your-user-id"
    // Add other required parameters
  )
  
  // Create Chat configuration
  let chatConfiguration = ChatConfiguration(
    // Fill in the necessary parameters for ChatConfiguration
  )
  
  // Important: store the ChatImpl in a property to maintain a strong reference.
  // If it is not retained, it will be deallocated
  let chat = ChatImpl(
    chatConfiguration: chatConfiguration,
    pubNubConfiguration: pubNubConfiguration
  )
  
  try await chat.initialize()
  // snippet.end
}

// MARK: - Typing Indicator Timeout

func initializeChatWithTypingTimeout() async throws {
  // snippet.configuration.typingTimeout
  // An example of how to initialize the top-level ChatImpl object
  // Create PubNub configuration
  let pubNubConfiguration = PubNubConfiguration(
    publishKey: "your-publish-key",
    subscribeKey: "your-subscribe-key",
    userId: "your-user-id"
    // Add other required parameters
  )
  
  // Create Chat configuration
  let chatConfiguration = ChatConfiguration(
    typingTimeout: 3
  )
  
  // Important: store the ChatImpl in a property to maintain a strong reference.
  // If it is not retained, it will be deallocated
  let chat = ChatImpl(
    chatConfiguration: chatConfiguration,
    pubNubConfiguration: pubNubConfiguration
  )
  
  try await chat.initialize()
  // snippet.end
}

// MARK: - Rate Limiting

func initializeChatWithRateLimiting() async throws {
  // snippet.configuration.rateLimiting
  // An example of how to initialize the top-level ChatImpl object
  // Create PubNub configuration
  let pubNubConfiguration = PubNubConfiguration(
    publishKey: "your-publish-key",
    subscribeKey: "your-subscribe-key",
    userId: "your-user-id"
    // Add other required parameters
  )
  
  // Create Chat configuration
  let chatConfiguration = ChatConfiguration(
    rateLimitFactor: 3,
    rateLimitPerChannel: [
      .public: Int64(3 * 1000) // 3 seconds converted to milliseconds
    ]
  )
  
  // Important: store the ChatImpl in a property to maintain a strong reference.
  // If it is not retained, it will be deallocated
  let chat = ChatImpl(
    chatConfiguration: chatConfiguration,
    pubNubConfiguration: pubNubConfiguration
  )
  
  try await chat.initialize()
  // snippet.end
}

// MARK: - Custom Payload (All Channels)

func initializeChatWithCustomPayloadAllChannels() {
  // snippet.configuration.customPayload.allChannels
  // Define custom payloads
  let customPayloads = CustomPayloads(
    getMessagePublishBody: { content, _, _ in
      return [
        "custom": [
          "payload": [
            "text": content.text
          ]
          // Optionally also save files as ["files": content.files]
        ]
      ]
    },
    getMessageResponseBody: { json, _, _ in
      guard
        let custom = try? json.decode([String: AnyJSON].self),
        let payload = custom["payload"],
        let text = payload["text"]?.stringOptional
      else {
        fatalError("Message cannot be parsed")
      }
      
      // Optionally parse files
      return EventContent.TextMessageContent(text: text)
    }
  )
  
  // Create a configuration that you can later provide to the ChatImpl constructor
  let chatConfiguration = ChatConfiguration(
    customPayloads: customPayloads
  )
  // snippet.end
}

// MARK: - Custom Payload (One Channel)

func initializeChatWithCustomPayloadOneChannel() {
  // snippet.configuration.customPayload.oneChannel
  // Define custom payloads
  let customPayloads = CustomPayloads(
    getMessagePublishBody: { content, channelId, defaultHandler in
      if channelId == "support-channel" {
        return [
          "my": [
            "custom": [
              "payload": [
                "structure": content.text
              ]
            ]
          ],
          // Optional parameter
          "files": content.files as Any,
        ] as [String: Any]
      }
      // Default Chat SDK message body structure for other channels
      return defaultHandler(content)
    },
    getMessageResponseBody: { json, channelId, defaultHandler in
      if channelId == "support-channel" {
        guard
          let custom = json.codableValue.dictionaryOptional?["my"] as? [String: Any],
          let payload = custom["custom"] as? [String: Any],
          let structure = payload["payload"] as? [String: Any],
          let text = structure["structure"] as? String
        else {
          fatalError("Message cannot be parsed")
        }
        return EventContent.TextMessageContent(text: text)
      }
      // Default Chat SDK message body structure for other channels
      return defaultHandler(json)
    },
    // Override the default edit action name
    editMessageActionName: "updated",
    // Override the default delete action name
    deleteMessageActionName: "removed"
  )
  // snippet.end
}

// MARK: - Error Logging

func initializeChatWithLogging() {
  // snippet.configuration.logging
  // Create PubNub configuration
  let pubNubConfiguration = PubNubConfiguration(
    publishKey: "your-publish-key",
    subscribeKey: "your-subscribe-key",
    userId: "your-user-id"
    // Add other required parameters
  )
  
  // Create Chat configuration
  let chatConfiguration = ChatConfiguration(
    logLevel: .info
  )
  
  // Create ChatImpl instance
  let yourChat = ChatImpl(
    chatConfiguration: chatConfiguration,
    pubNubConfiguration: pubNubConfiguration
  )
  // snippet.end
}
