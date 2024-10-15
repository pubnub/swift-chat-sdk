# ``PubNubSwiftChatSDK/MessageImpl``

## Topics

### Getting a Quoted Message for the given Message

- ``QuotedMessage``
- ``quotedMessage``

### Getting Message Actions for the given Message

- ``Action``
- ``actions``

### Receiving Updates

- ``streamUpdates(completion:)``
- ``streamUpdatesOn(messages:callback:)``

### Reactions

- ``hasUserReaction(reaction:)``
- ``toggleReaction(reaction:completion:)``

### Edit Text

- ``editText(newText:completion:)``

### Removing a Message

- ``delete(soft:preserveFiles:completion:)``

### Forward a Message

- ``forward(channelId:completion:)``

### Thread Channel

- ``getThread(completion:)``
- ``createThread(completion:)``
- ``removeThread(completion:)``

### Pin a Message

- ``pin(completion:)``

### Restoring a Message

- ``restore(completion:)``

### Report a Message

- ``report(reason:completion:)``
