//
//  PubNubChat.KotlinArray.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubChat

func transformKotlinArray<T, U>(_ array: KotlinArray<T>, mapper: (T) -> U) -> [U] {
  var iterator: KotlinIterator? = array.iterator()
  var resultingItems: [U] = []

  while iterator?.hasNext() ?? false {
    guard let item = iterator?.next() as? T else {
      continue
    }
    resultingItems.append(mapper(item))

    if iterator?.hasNext() ?? false {
      iterator = iterator?.next() as? KotlinIterator
    }
  }

  return resultingItems
}
