//
//  GetFileItem.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

public class GetFileItem {
  public var name: String
  public var id: String
  public var url: String

  init(name: String, id: String, url: String) {
    self.name = name
    self.id = id
    self.url = url
  }
}
