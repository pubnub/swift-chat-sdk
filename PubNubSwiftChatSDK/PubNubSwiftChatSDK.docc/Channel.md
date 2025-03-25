# ``PubNubSwiftChatSDK/Channel``

## Topics

### Receiving Updates

- ``streamUpdates()``
- ``streamUpdates(callback:)``
- ``streamUpdatesOn(channels:)``
- ``streamUpdatesOn(channels:callback:)``
- ``streamReadReceipts()``
- ``streamReadReceipts(callback:)``
- ``streamMessageReports()``
- ``streamMessageReports(callback:)``
- ``streamPresence()``
- ``streamPresence(callback:)``

### Update and Delete a Channel

- ``update(name:custom:description:status:type:)``
- ``update(name:custom:description:status:type:completion:)``
- ``delete(soft:)``
- ``delete(soft:completion:)``

### Typing Indicator

- ``startTyping()``
- ``startTyping(completion:)``
- ``stopTyping()``
- ``stopTyping(completion:)``
- ``getTyping()``
- ``getTyping(callback:)``

### Presence Management

- ``whoIsPresent()``
- ``whoIsPresent(completion:)``
- ``isPresent(userId:)``
- ``isPresent(userId:completion:)``
- ``join(custom:)``
- ``join(custom:callback:completion:)``
- ``leave()``
- ``leave(completion:)``
- ``streamPresence()``
- ``streamPresence(callback:)``

### Memberships Management

- ``invite(user:)``
- ``invite(user:completion:)``
- ``inviteMultiple(users:)``
- ``inviteMultiple(users:completion:)``
- ``getMembers(limit:page:filter:sort:)``
- ``getMembers(limit:page:filter:sort:completion:)``

### Sending a text

- ``InputFile``
- ``sendText(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:customPushData:)``
- ``sendText(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:customPushData:completion:)``
- ``sendText(text:meta:shouldStore:usePost:ttl:mentionedUsers:referencedChannels:textLinks:quotedMessage:files:customPushData:completion:)``

### Creating Message Draft

- ``createMessageDraft(userSuggestionSource:isTypingIndicatorTriggered:userLimit:channelLimit:)``

### Messages Management

- ``connect()``
- ``connect(callback:)``
- ``forward(message:)``
- ``forward(message:completion:)``
- ``getHistory(startTimetoken:endTimetoken:count:)``
- ``getHistory(startTimetoken:endTimetoken:count:completion:)``
- ``getMessage(timetoken:)``
- ``getMessage(timetoken:completion:)``

### Pinning and Unpinning a Message

- ``pinMessage(message:)``
- ``pinMessage(message:completion:)``
- ``unpinMessage()``
- ``unpinMessage(completion:)``
- ``getPinnedMessage()``
- ``getPinnedMessage(completion:)``

### Push Management

- ``registerForPush()``
- ``registerForPush(completion:)``
- ``unregisterFromPush()``
- ``unregisterFromPush(completion:)``

### Delete a File

- ``deleteFile(id:name:)``
- ``deleteFile(id:name:completion:)``

### Getting Files

- ``GetFileItem``
- ``getFiles(limit:next:)``
- ``getFiles(limit:next:completion:)``

### User Suggestions 

- ``getUserSuggestions(text:limit:)``
- ``getUserSuggestions(text:limit:completion:)``

### Message Reports

- ``getMessageReportsHistory(startTimetoken:endTimetoken:count:)``
- ``getMessageReportsHistory(startTimetoken:endTimetoken:count:completion:)``
- ``streamMessageReports()``
- ``streamMessageReports(callback:)``
