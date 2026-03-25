# ``PubNubSwiftChatSDK/User``

## Topics

### Receiving Updates

- ``streamUpdates()``
- ``streamUpdates(callback:)``
- ``streamUpdatesOn(users:)``
- ``streamUpdatesOn(users:callback:)``

### Update and Delete a User

- ``update(name:externalId:profileUrl:email:custom:status:type:)``
- ``update(name:externalId:profileUrl:email:custom:status:type:completion:)``
- ``update(updateAction:)``
- ``update(updateAction:completion:)``
- ``delete()``
- ``delete(completion:)``

### Presence Management

- ``wherePresent()``
- ``wherePresent(completion:)``
- ``isPresentOn(channelId:)``
- ``isPresentOn(channelId:completion:)``

### Memberships Management

- ``getMemberships(limit:page:filter:sort:)``
- ``getMemberships(limit:page:filter:sort:completion:)``
- ``isMemberOf(channelId:)``
- ``isMemberOf(channelId:completion:)``
- ``getMembership(channelId:)``
- ``getMembership(channelId:completion:)``
