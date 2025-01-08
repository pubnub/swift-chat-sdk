//
//  MessageDraft+AsyncAwait.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK

///
/// Extension providing `async-await` support for ``MessageDraft``.
///
public extension MessageDraft {
  /// Send the ``MessageDraft``, along with its ``files`` and ``quotedMessage`` if any, on the ``channel``.
  ///
  /// The `ttl` defines if/how long (in hours) the message should be stored in Message Persistence:
  ///  * - if `shouldStore` = `true`, and `ttl` = `0`, the message is stored with no expiry time
  ///  * - if `shouldStore` =  `true` and ttl = `X`, the message is stored with an expiry time of `X` hours
  ///  * - if `shouldStore` = `false`, the `ttl` parameter is ignored
  ///  * - if `ttl` is not specified, then the expiration of the message defaults back to the expiry value for the keyset
  ///
  /// - Parameters:
  ///   - meta: Publish additional details with the request
  ///   - shouldStore: If true, the messages are stored in Message Persistence if enabled in Admin Portal
  ///   - usePost: Use HTTP POST
  ///   - ttl: Defines if/how long (in hours) the message should be stored in Message Persistence
  /// - Returns: The `Timetoken` of the sent message
  func send(
    meta: [String: JSONCodable]? = nil,
    shouldStore: Bool = true,
    usePost: Bool = false,
    ttl: Int? = nil
  ) async throws -> Timetoken {
    try await withCheckedThrowingContinuation { continuation in
      send(
        meta: meta,
        shouldStore: shouldStore,
        usePost: usePost,
        ttl: ttl
      ) {
        switch $0 {
        case let .success(timetoken):
          continuation.resume(returning: timetoken)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
