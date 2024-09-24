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

public struct InputFile {
  public var name: String
  public var type: String
  public var source: PubNub.FileUploadContent

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
