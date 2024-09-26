//
//  InputFile.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat
import PubNubSDK

/// Represents a file that can be attached to a message when sending text to a channel
public struct InputFile {
  /// The name of the file
  public var name: String
  /// The type or MIME type of the file (e.g., "image/jpeg", "application/pdf")
  public var type: String
  /// The  object representing the file's source, such as the file content or its location
  public var source: PubNub.FileUploadContent

  /// Initializes a new instance of ``InputFile`` with the provided details
  /// - Parameters:
  ///   - name: The name of the file
  ///   - type: The type or MIME type of the file (e.g., "image/jpeg", "application/pdf")
  ///   - source: The  object representing the file's source, such as the file content or its location
  public init(name: String, type: String, source: PubNub.FileUploadContent) {
    self.name = name
    self.type = type
    self.source = source
  }

  func transform() -> PubNubChat.InputFile? {
    switch source {
    case let .file(url):
      PubNubChat.InputFile(
        name: name,
        type: type,
        source: PubNubChat.FileUploadContent(url: url)
      )
    case let .data(data, contentType):
      PubNubChat.InputFile(
        name: name,
        type: type,
        source: PubNubChat.DataUploadContent(data: data, contentType: contentType)
      )
    case let .stream(stream, contentType, contentLength):
      PubNubChat.InputFile(
        name: name,
        type: type,
        source: PubNubChat.StreamUploadContent(
          stream: stream,
          contentType: contentType,
          contentLength: Int32(contentLength)
        )
      )
    }
  }
}
