# ``PubNubSwiftChatSDK/Chat``

## Topics

### Initializing a Chat instance

- ``initialize()``
- ``initialize(completion:)``

### Working with Conversations

- ``CreateDirectConversationResult``
- ``CreateGroupConversationResult``
- ``createDirectConversation(invitedUser:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:)``
- ``createDirectConversation(invitedUser:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:completion:)``
- ``createGroupConversation(invitedUsers:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:)``
- ``createGroupConversation(invitedUsers:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:completion:)``
- ``createPublicConversation(channelId:channelName:channelDescription:channelCustom:channelStatus:)``
- ``createPublicConversation(channelId:channelName:channelDescription:channelCustom:channelStatus:completion:)``

### Working with Channels

- ``getChannel(channelId:)``
- ``getChannel(channelId:completion:)``
- ``getChannels(filter:sort:limit:page:)``
- ``getChannels(filter:sort:limit:page:completion:)``
- ``updateChannel(id:name:custom:description:status:type:)``
- ``updateChannel(id:name:custom:description:status:type:completion:)``
- ``deleteChannel(id:soft:)``
- ``deleteChannel(id:soft:completion:)``
- ``whoIsPresent(channelId:)``
- ``whoIsPresent(channelId:completion:)``
- ``getPushChannels()``
- ``getPushChannels(completion:)``
- ``registerPushChannels(channels:)``
- ``registerPushChannels(channels:completion:)``
- ``unregisterPushChannels(channels:)``
- ``unregisterPushChannels(channels:completion:)``
- ``unregisterAllPushChannels()``
- ``unregisterAllPushChannels(completion:)``

### Working with Users

- ``getUser(userId:)``
- ``getUser(userId:completion:)``
- ``createUser(id:name:externalId:profileUrl:email:custom:status:type:)``
- ``createUser(id:name:externalId:profileUrl:email:custom:status:type:completion:)``
- ``getUsers(filter:sort:limit:page:)``
- ``getUsers(filter:sort:limit:page:completion:)``
- ``updateUser(id:name:externalId:profileUrl:email:custom:status:type:)``
- ``updateUser(id:name:externalId:profileUrl:email:custom:status:type:completion:)``
- ``deleteUser(id:soft:)``
- ``deleteUser(id:soft:completion:)``
- ``wherePresent(userId:)``
- ``wherePresent(userId:completion:)``
- ``isPresent(userId:channelId:)``
- ``isPresent(userId:channelId:completion:)``

### Working with Events

- ``Event``
- ``EventContent``
- ``EventWrapper``
- ``EmitEventMethod``
- ``emitEvent(channelId:payload:mergePayloadWith:)``
- ``emitEvent(channelId:payload:mergePayloadWith:completion:)``
- ``listenForEvents(type:channelId:customMethod:)``
- ``listenForEvents(type:channelId:customMethod:callback:)``
- ``getEventsHistory(channelId:startTimetoken:endTimetoken:count:)``
- ``getEventsHistory(channelId:startTimetoken:endTimetoken:count:completion:)``

### Working with Messages

- ``GetUnreadMessagesCount``
- ``getUnreadMessagesCount(limit:page:filter:sort:)``
- ``getUnreadMessagesCount(limit:page:filter:sort:completion:)``
- ``markAllMessagesAsRead(limit:page:filter:sort:)``
- ``markAllMessagesAsRead(limit:page:filter:sort:completion:)``

### Retrieving Current User Mentions

- ``UserMentionData``
- ``UserMentionDataWrapper``
- ``ChannelMentionData``
- ``ThreadMentionData``
- ``GetCurrentUserMentionsResult``
- ``getCurrentUserMentions(startTimetoken:endTimetoken:count:)``
- ``getCurrentUserMentions(startTimetoken:endTimetoken:count:completion:)``

### Destroy

- ``destroy()``
