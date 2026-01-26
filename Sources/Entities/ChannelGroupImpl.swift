//
//  ChannelGroupImpl.swift
//
//  Copyright (c) PubNub Inc.
//  All rights reserved.
//
//  This source code is licensed under the license found in the
//  LICENSE file in the root directory of this source tree.
//

import Foundation
import PubNubSDK
import PubNubChat

/// A concrete implementation of the ``ChannelGroup`` protocol.
public class ChannelGroupImpl: ChannelGroup {
  public let chat: ChatImpl
  public let id: String

  private let channelGroup: PubNubChat.ChannelGroup_

  init(channelGroup: PubNubChat.ChannelGroup_, chat: ChatImpl) {
    self.channelGroup = channelGroup
    self.id = channelGroup.id
    self.chat = chat
  }

  public func listChannels(
    filter: String? = nil,
    sort: [PubNub.ObjectSortField] = [],
    limit: Int? = nil,
    page: PubNubHashedPage? = nil,
    completion: ((Swift.Result<(channels: [ChannelImpl], page: PubNubHashedPage?), Error>) -> Void)? = nil
  ) {
    channelGroup.listChannels(
      filter: filter,
      sort: sort.compactMap { $0.transform() },
      limit: limit?.asKotlinInt,
      page: page?.transform()
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, PubNubChat.GetChannelsResponse>) in
      switch result.result {
      case let .success(getChannelsResponse):
        completion?(
          .success((
            channels: getChannelsResponse.channels.compactMap {
              ChannelImpl(channel: $0, chat: result.caller.chat)
            },
            page: PubNubHashedPageBase(
              start: getChannelsResponse.next?.pageHash,
              end: getChannelsResponse.prev?.pageHash,
              totalCount: Int(getChannelsResponse.total)
            )
          ))
        )
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func add(channels: [ChannelImpl], completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channelGroup.addChannels(
      channels: channels.map { $0.target.channel }
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func addChannelIdentifiers(_ ids: [String], completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channelGroup.addChannelIdentifiers(
      ids: ids
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func remove(channels: [ChannelImpl], completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channelGroup.removeChannels(
      channels: channels.map { $0.target.channel }
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func removeChannelIdentifiers(_ ids: [String], completion: ((Swift.Result<Void, Error>) -> Void)?) {
    channelGroup.removeChannelIdentifiers(
      ids: ids
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, PubNubChat.KotlinUnit>) in
      switch result.result {
      case .success:
        completion?(.success(()))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func whoIsPresent(
    limit: Int = 1000,
    offset: Int? = 0,
    completion: ((Swift.Result<[String: [String]], Error>) -> Void)?
  ) {
    channelGroup.whoIsPresent(
      limit: Int32(limit),
      offset: offset?.asKotlinInt
    ).async(caller: self) { (result: FutureResult<ChannelGroupImpl, [String: [String]]>) in
      switch result.result {
      case let .success(ids):
        completion?(.success(ids))
      case let .failure(error):
        completion?(.failure(error))
      }
    }
  }

  public func streamPresence(callback: @escaping ([String: [String]]) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      channelGroup.streamPresence { [weak self] in
        if let userIds = $0 as? [String: [String]], self != nil {
          callback(userIds)
        }
      },
      owner: self
    )
  }

  public func connect(callback: @escaping (MessageImpl) -> Void) -> AutoCloseable {
    AutoCloseableImpl(
      channelGroup.connect { [weak self] in
        if let self = self {
          callback(MessageImpl(message: $0, chat: self.chat))
        }
      },
      owner: self
    )
  }
}
