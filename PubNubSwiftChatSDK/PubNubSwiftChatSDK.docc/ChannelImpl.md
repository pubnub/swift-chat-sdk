# ``PubNubSwiftChatSDK/ChannelImpl``

## Topics

### Receiving Updates

- ``streamUpdates(callback:)``
- ``streamUpdatesOn(channels:callback:)``
- ``streamReadReceipts(callback:)``
- ``streamMessageReports(callback:)``
- ``streamPresence(callback:)``

### Update and Delete a Channel

- ``update(name:custom:description:status:type:completion:)``
- ``delete(soft:completion:)``

### Typing Indicator

- ``startTyping(completion:)``
- ``stopTyping(completion:)``
- ``getTyping(callback:)``

### Presence Management

- ``whoIsPresent(completion:)``
- ``isPresent(userId:completion:)``
- ``join(custom:callback:completion:)``
- ``leave(completion:)``
- ``streamPresence(callback:)``

### Memberships Management

- ``invite(user:completion:)``
- ``inviteMultiple(users:completion:)``
- ``getMembers(limit:page:filter:sort:completion:)``

### Sending a text

- ``InputFile``
- ``sendText(text:meta:shouldStore:usePost:ttl:mentionedUsers:referencedChannels:textLinks:quotedMessage:files:completion:)``
- ``sendText(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:completion:)``

### Creating Message Draft

- ``MessageDraft``
- ``MessageDraftStateListener``
- ``SuggestedMention``
- ``MentionTarget``
- ``MessageElement``
- ``UserSuggestionSource``
- ``createMessageDraft(userSuggestionSource:isTypingIndicatorTriggered:userLimit:channelLimit:)``

### Messages Management

- ``connect(callback:)``
- ``forward(message:completion:)``
- ``getHistory(startTimetoken:endTimetoken:count:completion:)``
- ``getMessage(timetoken:completion:)``

### Pinning and Unpinning a Message

- ``pinMessage(message:completion:)``
- ``unpinMessage(completion:)``
- ``getPinnedMessage(completion:)``

### Push Management

- ``registerForPush(completion:)``
- ``unregisterFromPush(completion:)``

### Delete a File

- ``deleteFile(id:name:completion:)``

### Getting Files

- ``GetFileItem``
- ``getFiles(limit:next:completion:)``

### User Suggestions 

- ``getUserSuggestions(text:limit:completion:)``

### Message Reports

- ``getMessageReportsHistory(startTimetoken:endTimetoken:count:completion:)``
- ``streamMessageReports(callback:)``
