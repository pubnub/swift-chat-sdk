# ``PubNubSwiftChatSDK/MessageImpl``

## Topics

### Getting a Quoted Message for the given Message

- ``QuotedMessage``
- ``quotedMessage``

### Getting Message Actions for the given Message

- ``Action``
- ``actions``

### Receiving Updates

- ``streamUpdates()``
- ``streamUpdates(completion:)``
- ``streamUpdatesOn(messages:)``
- ``streamUpdatesOn(messages:callback:)``

### Reactions

- ``hasUserReaction(reaction:)``
- ``toggleReaction(reaction:)``
- ``toggleReaction(reaction:completion:)``

### Edit Text

- ``editText(newText:)``
- ``editText(newText:completion:)``

### Removing a Message

- ``delete(soft:preserveFiles:)``
- ``delete(soft:preserveFiles:completion:)``

### Forward a Message

- ``forward(channelId:)``
- ``forward(channelId:completion:)``

### Thread Channel

- ``getThread()``
- ``getThread(completion:)``
- ``createThread()``
- ``createThread(completion:)``
- ``createThread(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:customPushData:)``
- ``createThread(text:meta:shouldStore:usePost:ttl:quotedMessage:files:usersToMention:customPushData:completion:)``
- ``removeThread()``
- ``removeThread(completion:)``

### Pin a Message

- ``pin()``
- ``pin(completion:)``

### Restoring a Message

- ``restore()``
- ``restore(completion:)``

### Report a Message

- ``report(reason:)``
- ``report(reason:completion:)``

### Mesage draft

- ``createThreadMessageDraft(userSuggestionSource:isTypingIndicatorTriggered:userLimit:channelLimit:)``
- ``createThreadMessageDraft(userSuggestionSource:isTypingIndicatorTriggered:userLimit:channelLimit:completion:)``
