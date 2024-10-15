# ``PubNubSwiftChatSDK/ChatImpl``

## Topics

### Working with Conversations

- ``CreateDirectConversationResult``
- ``CreateGroupConversationResult``
- ``createDirectConversation(invitedUser:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:completion:)``
- ``createGroupConversation(invitedUsers:channelId:channelName:channelDescription:channelCustom:channelStatus:membershipCustom:completion:)``
- ``createPublicConversation(channelId:channelName:channelDescription:channelCustom:channelStatus:completion:)``

### Working with Channels

- ``getChannel(channelId:completion:)``
- ``getChannels(filter:sort:limit:page:completion:)``
- ``updateChannel(id:name:custom:description:status:type:completion:)``
- ``deleteChannel(id:soft:completion:)``
- ``whoIsPresent(channelId:completion:)``
- ``getPushChannels(completion:)``
- ``registerPushChannels(channels:completion:)``
- ``unregisterPushChannels(channels:completion:)``
- ``unregisterAllPushChannels(completion:)``

### Working with Users

- ``getUser(userId:completion:)``
- ``createUser(user:completion:)``
- ``getUsers(filter:sort:limit:page:completion:)``
- ``updateUser(id:name:externalId:profileUrl:email:custom:status:type:completion:)``
- ``deleteUser(id:soft:completion:)``
- ``wherePresent(userId:completion:)``
- ``isPresent(userId:channelId:completion:)``

### Working with Events

- ``Event``
- ``EventContent``
- ``EventWrapper``
- ``EmitEventMethod``
- ``emitEvent(channelId:payload:mergePayloadWith:completion:)``
- ``listenForEvents(type:channelId:customMethod:callback:)``
- ``getEventsHistory(channelId:startTimetoken:endTimetoken:count:completion:)``

### Working with Messages

- ``GetUnreadMessagesCount``
- ``getUnreadMessagesCount(limit:page:filter:sort:completion:)``
- ``markAllMessagesAsRead(limit:page:filter:sort:completion:)``

### Working with Channels and Users Suggestions

- ``getUserSuggestions(text:limit:completion:)``
- ``getChannelSuggestions(text:limit:completion:)``

### Retrieving Current User Mentions

- ``UserMentionData``
- ``UserMentionDataWrapper``
- ``ChannelMentionData``
- ``ThreadMentionData``
- ``GetCurrentUserMentionsResult``
- ``getCurrentUserMentions(startTimetoken:endTimetoken:count:completion:)``

### Destroy

- ``destroy()``
