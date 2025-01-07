# ``PubNubSwiftChatSDK``

This SDK offers a set of handy methods to create your own feature-rich chat or add a chat to your existing application.

## Overview

Our Chat SDK provides a number of out-of-the-box chat features like read receipts, @mentions, and unread message counts,
that can be easily integrated with your own UI, cutting down on the amount of time needed to develop a high-quality, custom chat experience.

## Topics

### Configuring your Chat

- ``ChatConfiguration``
- ``PushNotificationsConfig``

### Working with Chat instance

- ``Chat``
- ``ChatImpl``

### Working with Channels

- ``Channel``
- ``ChannelImpl``
- ``ThreadChannel``
- ``ThreadChannelImpl``

### Working with Users

- ``User``
- ``UserImpl``

### Working with Memberships

- ``Membership``
- ``MembershipImpl``

### Working with Messages

- ``Message``
- ``MessageImpl``
- ``ThreadMessage``
- ``ThreadMessageImpl``

### Working with Custom Payloads

- ``MessageActionType``
- ``CustomPayloads``
- ``GetMessagePublishBody``
- ``GetMessageResponseBody``
- ``DefaultGetMessagePublishBody``
- ``DefaultGetMessageResponseBody``

### Message Draft

- ``MessageDraft``
- ``MessageDraftImpl``
- ``MessageDraftChangeListener``
- ``ClosureMessageDraftChangeListener``
- ``SuggestedMention``
- ``FutureObject``
- ``MentionTarget``
- ``MessageElement``
- ``UserSuggestionSource``
