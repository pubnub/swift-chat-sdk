//
//  ConnectionStatus.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation

/// The connection status of the Chat SDK.
public enum ConnectionStatus: Equatable {
  /// The client is connected to the PubNub network.
  case online
  /// The client is disconnected from the PubNub network.
  case offline
  /// The client is experiencing an error while connecting to the PubNub network.
  case connectionError(error: Error)

  /// Returns an error (if any) associated with the connection status.
  public var error: Error? {
    switch self {
    case let .connectionError(error):
      return error
    default:
      return nil
    }
  }

  /// Returns `true` if the connection status is `online`, otherwise `false`.
  public var isConnected: Bool {
    switch self {
    case .online:
      return true
    default:
      return false
    }
  }

  public static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
    switch (lhs, rhs) {
    case (.online, .online):
      return true
    case (.offline, .offline):
      return true
    case (.connectionError, .connectionError):
      return true
    default:
      return false
    }
  }
}
