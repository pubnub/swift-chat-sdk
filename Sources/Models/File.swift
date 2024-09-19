//
//  File.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

public struct File {
  public var name: String
  public var id: String
  public var url: String
  public var type: String?

  public init(name: String, id: String, url: String, type: String?) {
    self.name = name
    self.id = id
    self.url = url
    self.type = type
  }
}
