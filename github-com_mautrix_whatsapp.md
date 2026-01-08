Directory structure:
└── mautrix-whatsapp/
    ├── README.md
    ├── build.sh
    ├── CHANGELOG.md
    ├── docker-run.sh
    ├── Dockerfile
    ├── Dockerfile.ci
    ├── go.mod
    ├── go.sum
    ├── LICENSE
    ├── LICENSE.exceptions
    ├── ROADMAP.md
    ├── .editorconfig
    ├── .gitlab-ci.yml
    ├── .pre-commit-config.yaml
    ├── cmd/
    │   └── mautrix-whatsapp/
    │       ├── legacyprovision.go
    │       └── main.go
    └── .github/
        ├── ISSUE_TEMPLATE/
        │   ├── bug.md
        │   ├── config.yml
        │   └── enhancement.md
        └── workflows/
            ├── go.yml
            └── stale.yml


Files Content:

================================================
FILE: README.md
================================================
# mautrix-whatsapp
A Matrix-WhatsApp puppeting bridge based on [whatsmeow](https://github.com/tulir/whatsmeow).

## Documentation
All setup and usage instructions are located on [docs.mau.fi]. Some quick links:

[docs.mau.fi]: https://docs.mau.fi/bridges/go/whatsapp/index.html

* [Bridge setup](https://docs.mau.fi/bridges/go/setup.html?bridge=whatsapp)
  (or [with Docker](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=whatsapp))
* Basic usage: [Authentication](https://docs.mau.fi/bridges/go/whatsapp/authentication.html)

### Features & Roadmap
[ROADMAP.md](ROADMAP.md) contains a general overview of what is supported by the bridge.

## Discussion
Matrix room: [#whatsapp:maunium.net](https://matrix.to/#/#whatsapp:maunium.net)



================================================
FILE: build.sh
================================================
#!/bin/sh
BINARY_NAME=mautrix-whatsapp go tool maubuild "$@"



================================================
FILE: CHANGELOG.md
================================================
# v25.12

* Updated Docker image to Alpine 3.23.
* Fixed group member invites from Matrix not automatically disinviting the phone
  number ghost when the invite is redirected to a LID ghost.

# v25.11

* Added interface support for notifying about failed invites when creating a
  group and sending the invites via DM (only applicable to provisioning API).
* Added migration to automatically delete duplicate LID DM portals that were
  created earlier.
* Changed contact list API to only include actual phone contacts.
* Removed extra unrecognized message notice when receiving live photos
  (bridging the live photo video is not currently planned).
* Fixed pairing not working with latest WhatsApp Android version.
* Fixed replies, read receipts and typing notifications not being bridged
  correctly after DM LID migration.
* Fixed backfill creating duplicate portals if history sync contains both LID
  and phone number DM data.
* Fixed some cases of LID and phone number user infos getting out of sync.
* Fixed muting chat forever not being bridged correctly from WhatsApp.
* Fixed old mutes being re-applied on chat resync in some cases.
* Fixed backfilling failing if some reactions were missing sender info.
* Fixed space not being deleted when leaving community on WhatsApp.
* Fixed sticker size metadata on Matrix not matching how native WhatsApp Web
  renders them.
* Fixed ratelimit errors in login not being exposed to the user properly
  (thanks to [@dead8309] in [#852]).

[@dead8309]: https://github.com/dead8309
[#852]: https://github.com/mautrix/whatsapp/pull/852

# v25.10

* Switched to calendar versioning.
* Added support for bridging event edits.
* Fixed backfill creating incorrect disappearing timer change notices.
* Fixed previous messages not being marked as read when sending a new message.
* Fixed incoming call notices with LID addressing going into different DM room.

# v0.12.5 (2025-09-16)

* Removed legacy provisioning API and database legacy migration.
  Upgrading directly from versions prior to v0.11.0 is not supported.
  * If you've been using the bridge since before v0.11.0 and have prevented the
    bridge from writing to the config, you must either update the config
    manually or allow the bridge to update it for you **before** upgrading to
    this release (i.e. run v0.12.4 once with config writing allowed).
* Added support for changing group name/topic/avatar from Matrix
  (thanks to [@Petersmit27] in [#834]).
* Added `RedactedPhone` placeholder for displayname templates. This allows
  community announcement groups (where you can't see participants phone numbers)
  to have better names than random numbers.
* Added support for `com.beeper.disappearing_timer` state event, which stores
  the disappearing setting of chats and allows changing the setting from Matrix.
* Added lottieconverter to Docker images to enable converting animated stickers
  from WhatsApp.
* Added support for creating WhatsApp groups.
* Fixed sent PNGs not being rendered on WhatsApp iOS.

[@Petersmit27]: https://github.com/Petersmit27
[#834]: https://github.com/mautrix/whatsapp/pull/834

# v0.12.4 (2025-08-16)

* Deprecated legacy provisioning API. The `/_matrix/provision/v1` endpoints will
  be deleted in the next release.
* Bumped minimum Go version to 1.24.
* Added support for bridging HD dual uploads from WhatsApp into edits on Matrix.
* Added better placeholders for pin and keep messages from WhatsApp.
* Fixed bridging animated webp stickers to WhatsApp.
  * Note that non-square stickers may appear corrupted on native clients.
    The bridge will not automatically add padding to animated stickers like it
    does for static ones.
* Fixed avatar changes not reflecting on both the LID and phone number ghost of
  a given user in certain cases.
* Fixed first message after group LID migration still using the phone number
  ghost.
* Fixed bot messages in DMs being split into another portal room.
* Fixed new group members not having a phone number name in some cases.

# v0.12.3 (2025-07-16)

* Further improved support for `@lid` users.
* Added automatic conversion when sending quicktime/mov videos to WhatsApp.
* Fixed disappearing message timer not automatically fixing itself in some cases.
* Fixed call notices being sent to DM portal even if the call was in a group.

# v0.12.2 (2025-06-16)

* Improved support for `@lid` users.
  * **N.B.** As mentioned in the v0.12.0 release, old registration files may
    have `[0-9]+` in the `users` regex. You must change it to `.+`, as the new
    `lid` identifiers are bridged as `lid-<number>` instead of just `<phone number>`.
* Updated Docker image to Alpine 3.22.
* Fixed network errors on first connect not triggering automatic reconnect.
* Fixed animated sticker zips not being extracted when using direct media.

# v0.12.1 (2025-05-16)

* Added prefix to identify forwarded messages on WhatsApp.
* Updated mime type of unconverted animated stickers to `video/lottie+json`
  which is now registered with IANA.
* Changed relogin command to not require entering phone number twice when using
  phone code login.
* Fixed outgoing messages being rejected if they replied to a fake message
  generated by the bridge.
* Fixed backfilling messages in existing portals after relogining.

# v0.12.0 (2025-04-16)

* Migrated Signal session store to use new `@lid` identifiers to support future
  chats that don't expose phone numbers.
  * **N.B.** Old registration files may have `[0-9]+` in the `users` regex. You
    must change it to `.+`, as the new `lid` identifiers are bridged as
    `lid-<number>` instead of just `<phone number>`.
* Added fallbacks for various business message types.
* Added support for bridging invites, kicks and leaves in groups.
* Re-added `invite-link`, `join` and `sync` commands for groups.
* Fixed bridging chats with Meta AI.

# v0.11.4 (2025-03-16)

* Fixed edits being bridged multiple times if a single chat had multiple
  logged-in Matrix users.
* Fixed bridging some types of business messages that were supposed to be
  supported (there are still some unsupported types).

# v0.11.3 (2025-02-16)

* Bumped minimum Go version to 1.23.
* Added support for signaling supported features to clients using the
  `com.beeper.room_features` state event.
* Fixed converting voice message duration and waveform.
* Fixed padding in stickers sent to WhatsApp sometimes being the wrong color.

# v0.11.2 (2024-12-16)

* Added better notice when view-once messages are unavailable.
* Fixed some cases of `@lid` user IDs being bridged incorrectly.
* Fixed starting chats by inviting Matrix ghosts.
* Updated Docker image to Alpine 3.21.

# v0.11.1 (2024-11-16)

* Added experimental support for direct media. This is not recommended for most
  users, as WhatsApp media is generally low volume and isn't stored permanently
  on the server.
* Re-added support for disabling status broadcasts.
* Re-added config options for which tag to use for archive/pinned chat bridging.
* Fixed own reactions sent from other clients in DMs not being bridged correctly.
* Fixed some bugs with legacy database migration.
* Fixed group chats not being bridged during initial login if the bridge hits
  ratelimits.

# v0.11.0 (2024-10-16)

* Bumped minimum Go version to 1.22.
* Dropped support for unauthenticated media on Matrix.
* Changed import path to `go.mau.fi/mautrix-whatsapp`.
* Rewrote bridge using bridgev2 architecture.
  * It is recommended to check the config file after upgrading. If you have
    prevented the bridge from writing to the config, you should update it
    manually.
  * Group management features and commands are not yet available.
    If you rely on those, it may be better to wait for the next release.

# v0.10.9 (2024-07-16)

* Added support for receiving Meta AI messages.
* Fixed `m.relates_to` handling bug in previous release.

# v0.10.8 (2024-06-16)

* Added proxying options to config.
* Updated fallback message for live locations and polls to clarify the user
  should open the native WhatsApp app.

# v0.10.7 (2024-04-16)

* Changed media download retries to be handled asynchronously instead of
  blocking other messages.

# v0.10.6 (2024-03-16)

* Bumped minimum Go version to 1.21.
* Added 8-letter code pairing support to provisioning API.
* Added more bugs to fix later.
* Renamed default branch from `master` to `main`.

# v0.10.5 (2023-12-16)

* Added support for sending media to channels.
* Fixed voting in polls (seems to have broken due to a server-side change).
* Improved memory usage for bridges with lots of portals.

# v0.10.4 (2023-11-16)

* Added support for channels in `join` and `open` commands.
* Added initial bridging of channel admin to room admin status.
* Fixed panic when trying to send message in a portal which has a relaybot set
  if the relaybot user gets logged out of WhatsApp.

# v0.10.3 (2023-10-16)

* Added basic support for channels.
* Added default mime type for outgoing attachments when the origin Matrix
  client forgets to specify the mime type.
* Fixed legacy backfill creating portals for chats without messages.
* Updated libwebp version used for encoding.

# v0.10.2 (security update)

* Stopped using libwebp for decoding webps.

# v0.10.1 (2023-09-16)

* Added support for double puppeting with arbitrary `as_token`s.
  See [docs](https://docs.mau.fi/bridges/general/double-puppeting.html#appservice-method-new) for more info.
* Added retrying for media downloads when WhatsApp servers break and start
  returning 429s and 503s.
* Fixed logging in with 8-letter code.
* Fixed syncing community announcement groups.
* Changed "Incoming call" message to explicitly say you have to open WhatsApp
  on your phone to answer.

# v0.10.0 (2023-08-16)

* Bumped minimum Go version to 1.20.
* Added automatic re-requesting of undecryptable WhatsApp messages from primary
  device.
* Added support for round video messages.
* Added support for logging in by entering a 8-letter code on the phone instead
  of scanning a QR code.
  * Note: due to a server-side change, code login may only work when `os_name`
    and `browser_name` in the config are set in a specific way. This is fixed
    in v0.10.1.

# v0.9.0 (2023-07-16)

* Removed MSC2716 support.
* Added legacy backfill support.
* Updated Docker image to Alpine 3.18.
* Changed all ogg audio messages from WhatsApp to be bridged as voice messages
  to Matrix, as WhatsApp removes the voice message flag when forwarding for
  some reason.
* Added Prometheus metric for WhatsApp connection failures
  (thanks to [@Half-Shot] in [#620]).

[#620]: https://github.com/mautrix/whatsapp/pull/620

# v0.8.6 (2023-06-16)

* Implemented intentional mentions for outgoing messages.
* Added support for appservice websockets.
* Added additional index on message table to make bridging outgoing read
  receipts and messages faster in chats with lots of messages.
* Fixed handling WhatsApp poll messages that only allow one choice.
* Fixed bridging new groups immediately when they're created.

# v0.8.5 (2023-05-16)

* Added option to disable reply fallbacks entirely.
* Added provisioning API for joining groups with invite links.
* Added error reply to encrypted messages if the bridge isn't configured to do
  encryption.
* Changed audio messages with captions to be sent as documents to WhatsApp
  (otherwise the caption would be lost).

# v0.8.4 (2023-04-16)

* Enabled sending edits to WhatsApp by default.
* Added options to automatically ratchet/delete megolm sessions to minimize
  access to old messages.
* Added automatic media re-requesting when download fails with 403 error.
* Added option to not set room name/avatar even in encrypted rooms.

# v0.8.3 (2023-03-16)

* Bumped minimum Go version to 1.19.
* Switched to zerolog for logging.
  * The basic log config will be migrated automatically, but you may want to
    tweak it as the options are different.
* Implemented [MSC3952]: Intentional Mentions
  (currently only for incoming messages).
* Implemented [MSC2659]: Application service ping endpoint.

[MSC3952]: https://github.com/matrix-org/matrix-spec-proposals/pull/3952
[MSC2659]: https://github.com/matrix-org/matrix-spec-proposals/pull/2659

# v0.8.2 (2023-02-16)

* Updated portal room power levels to always allow poll votes.
* Fixed disappearing message timing being implemented incorrectly.
* Fixed server rejecting messages not being handled as an error.
* Fixed sent files not being downloadable on latest WhatsApp beta versions.
* Fixed `sync space` command not syncing DMs into the space properly.
* Added workaround for broken clients like Element iOS that can't render normal
  image messages correctly.

# v0.8.1 (2023-01-16)

* Added support for sending polls from Matrix to WhatsApp.
* Added config option for requesting more history from phone during login.
* Added support for WhatsApp chat with yourself.
* Fixed deleting portals not working correctly in some cases.

# v0.8.0 (2022-12-16)

* Added support for bridging polls from WhatsApp and votes in both directions.
  * Votes are only bridged if MSC3381 polls are enabled
    (`extev_polls` in the config).
* Added support for bridging WhatsApp communities as spaces.
* Updated backfill logic to mark rooms as read if the only message is a notice
  about the disappearing message timer.
* Updated Docker image to Alpine 3.17.
* Fixed backfills starting at the wrong time and sending smaller batches than
  intended in some cases.
* Switched SQLite config from `sqlite3` to `sqlite3-fk-wal` to enforce foreign
  keys and WAL mode. Additionally, adding `_txlock=immediate` to the DB path is
  recommended, but not required.

# v0.7.2 (2022-11-16)

* Added option to handle all transactions asynchronously.
  * This may be useful for large instances, but using it means messages are
    no longer guaranteed to be sent to WhatsApp in the same order as Matrix.
* Fixed database error when backfilling disappearing messages on SQLite.
* Fixed incoming events blocking handling of incoming encryption keys.

# v0.7.1 (2022-10-16)

* Added support for wa.me/qr links in `!wa resolve-link`.
* Added option to sync group members in parallel to speed up syncing large
  groups.
* Added initial support for WhatsApp message editing.
  * Sending edits will be disabled by default until official WhatsApp clients
    start rendering edits.
* Changed `private_chat_portal_meta` config option to be implicitly enabled in
  encrypted rooms, matching the behavior of other mautrix bridges.
* Updated media bridging to check homeserver media size limit before
  downloading media to avoid running out of memory.
  * The bridge may still run out of ram when bridging files if your homeserver
    has a large media size limit and a low bridge memory limit.

# v0.7.0 (2022-09-16)

* Bumped minimum Go version to 1.18.
* Added hidden option to use appservice login for double puppeting.
  * This can be used by adding everyone to a non-exclusive namespace in the
    registration, and setting the login shared secret to the string `appservice`.
* Enabled appservice ephemeral events by default for new installations.
  * Existing bridges can turn it on by enabling `ephemeral_events` and disabling
    `sync_with_custom_puppets` in the config, then regenerating the registration
    file.
* Updated sticker bridging to send actual sticker messages to WhatsApp rather
  than sending as image. This includes converting stickers to webp and adding
  transparent padding to make the aspect ratio 1:1.
* Added automatic webm -> mp4 conversion when sending videos to WhatsApp.
* Started rejecting unsupported mime types when sending media to WhatsApp.
* Added option to use [MSC2409] and [MSC3202] for end-to-bridge encryption.
  However, this may not work with the Synapse implementation as it hasn't
  been tested yet.
* Added error notice if the bridge is started twice.

[MSC3202]: https://github.com/matrix-org/matrix-spec-proposals/pull/3202

# v0.6.1 (2022-08-16)

* Added support for "Delete for me" and deleting private chats from WhatsApp.
* Added support for admin deletions in groups.
* Document with caption messages should work with the bridge as soon as
  WhatsApp enables them in their apps.

# v0.6.0 (2022-07-16)

* Started requiring homeservers to advertise Matrix v1.1 support.
  * This bumps up the minimum homeserver versions to Synapse 1.54 and
    Dendrite 0.8.7. Minimum Conduit version remains at 0.4.0.
  * The bridge will also refuse to start if backfilling is enabled in the
    config, but the homeserver isn't advertising support for MSC2716. Only
    Synapse supports backfilling at the moment.
* Added options to make encryption more secure.
  * The `encryption` -> `verification_levels` config options can be used to
    make the bridge require encrypted messages to come from cross-signed
    devices, with trust-on-first-use validation of the cross-signing master
    key.
  * The `encryption` -> `require` option can be used to make the bridge ignore
    any unencrypted messages.
  * Key rotation settings can be configured with the `encryption` -> `rotation`
    config.
* Added config validation to make the bridge refuse to start if critical fields
  like homeserver or database address haven't been changed from the defaults.
* Added option to include captions in the same message as the media to
  implement [MSC2530]. Sending captions the same way is also supported and
  enabled by default.
* Added basic support for fancy business messages (template and list messages).
* Added periodic background sync of user and group avatars.
* Added maximum message handling duration config options to prevent messages
  getting stuck and blocking everything.
* Changed message send error notices to be replies to the errored message.
* Changed dimensions of stickers bridged from WhatsApp to match WhatsApp web.
* Changed attachment bridging to find the Matrix `msgtype` based on the
  WhatsApp message type instead of the file mimetype.
* Updated Docker image to Alpine 3.16.
* Fixed backfill queue on SQLite.

[MSC2530]: https://github.com/matrix-org/matrix-spec-proposals/pull/2530

# v0.5.0 (2022-06-16)

* Moved a lot of code to mautrix-go.
* Improved handling edge cases in backfill system.
* Improved handling errors in Matrix->WhatsApp message bridging.
* Disallowed sending status broadcast messages by default, as it breaks with
  big contact lists. Sending can be re-enabled in the config.
* Fixed some cases where the first outgoing message was undecryptable for
  WhatsApp users.
* Fixed chats not being marked as read when sending a message from another
  WhatsApp client after receiving a call.
* Fixed other bridge users being added to status broadcasts rooms through
  double puppeting.
* Fixed edge cases in the deferred backfill queue.

# v0.4.0 (2022-05-16)

* Switched from `/r0` to `/v3` paths everywhere.
  * The new `v3` paths are implemented since Synapse 1.48, Dendrite 0.6.5,
    and Conduit 0.4.0. Servers older than these are no longer supported.
* Added new deferred backfill system to allow backfilling historical messages
  later instead of doing everything at login.
* Added option to automatically request old media from phone after backfilling.
* Added experimental provisioning API to check if a phone number is registered
  on WhatsApp.
* Added automatic retrying if the websocket dies while sending a message.
* Added experimental support for sending status broadcast messages.
* Added command to change disappearing message timer in chats.
* Improved error handling if Postgres dies while the bridge is running.
* Fixed bridging stickers sent from WhatsApp web.
* Fixed registration generation not regex-escaping user ID namespaces.

# v0.3.1 (2022-04-16)

* Added emoji normalization for reactions in both directions to add/remove
  variation selector 16 as appropriate.
* Added option to use [MSC2246] async media uploads.
* Fixed custom fields in messages being unencrypted in history syncs.

[MSC2246]: https://github.com/matrix-org/matrix-spec-proposals/pull/2246

# v0.3.0 (2022-03-16)

* Added reaction bridging in both directions.
* Added automatic sending of hidden messages to primary device to prevent
  false-positive disconnection warnings if there have been no messages sent or
  received in >12 days.
* Added proper error message when WhatsApp rejects the connection due to the
  bridge being out of date.
* Added experimental provisioning API to list contacts/groups, start DMs and
  open group portals. Note that these APIs are subject to change at any time.
* Added option to always send "active" delivery receipts (two gray ticks), even
  if presence bridging is disabled. By default, WhatsApp web only sends those
  receipts when it's in the foreground (i.e. showing online status).
* Added option to send online presence on typing notifications (thanks to
  [@abmantis] in [#452]). This can be used to enable incoming typing
  notifications without enabling Matrix presence (WhatsApp only sends typing
  notifications if you're online).
* Added checks to prevent sharing the database with unrelated software.
* Exposed maximum database connection idle time and lifetime options.
* Fixed syncing group topics. To get topics into existing portals on Matrix,
  you can use `!wa sync groups`.
* Fixed sticker events on Matrix including a redundant `msgtype` field.
* Disabled file logging in Docker image by default.
  * To enable it, mount a directory for the logs that's writable for the user
    inside the container (1337 by default), then point the bridge at it using
    the `logging` -> `directory` field, and finally set `file_name_format` to
    something non-empty (the default is `{{.Date}}-{{.Index}}.log`).

[#452]: https://github.com/mautrix/whatsapp/pull/452

# v0.2.4 (2022-02-16)

* Added tracking for incoming events from the primary device to warn the user
  if their phone is offline for too long.
* (Re-)Added support for setting group avatar from Matrix.
* Added initial support for re-fetching old media from phone.
* Added support for bridging audio message waveforms in both directions.
* Added support for sending URL previews to WhatsApp (both custom and autogenerated).
* Updated formatter to get Matrix user displayname when converting WhatsApp mentions.
* Fixed some issues with read receipt bridging.
* Fixed `!wa open` not working with new-style group IDs.
* Fixed panic in disappearing message handling code if a portal is deleted with
  messages still inside.
* Fixed disappearing message timer not being stored in post-login history sync.
* Fixed formatting not being parsed in most incoming WhatsApp messages.

# v0.2.3 (2022-01-16)

* Added support for bridging incoming broadcast list messages.
* Added overrides for mime type -> file extension mapping as some OSes have
  very obscure extensions in their mime type database.
* Added support for personal filtering spaces (started by [@HelderFSFerreira] and [@clmnin] in [#413]).
* Added support for multi-contact messages.
* Added support for disappearing messages.
* Fixed avatar remove events from WhatsApp being ignored.
* Fixed the bridge using the wrong Olm session if a client established a new
  one due to corruption.
* Fixed more issues with app state syncing not working (especially related to contacts).

[@HelderFSFerreira]: https://github.com/HelderFSFerreira
[@clmnin]: https://github.com/clmnin
[#413]: https://github.com/mautrix/whatsapp/pull/413

# v0.2.2 (2021-12-16)

**This release includes a fix for a moderate severity security issue that
affects all versions since v0.1.4.** If your bridge allows untrusted users to
run commands in bridged rooms (`user` permission level), you should update the
bridge or demote untrusted users to the `relay` level. If all whitelisted users
are trusted, then you're not affected.

* Added proper thumbnail generation when sending images to WhatsApp.
* Added support for the stable version of [MSC2778].
* Added support for receiving ephemeral events via [MSC2409]
  (previously only possible via double puppeting).
* Added option to mute status broadcast room and move it to low priority by default.
* Added command to search your contact list and joined groups
  (thanks to [@abmantis] in [#387]).
* Added support for automatically re-requesting Megolm keys if they don't
  arrive, and automatically recreating Olm sessions if an incoming message
  fails to decrypt.
* Added support for passing through media dimensions in image/video messages
  from WhatsApp.
* Switched double puppeted messages to use `"fi.mau.double_puppet_source": "mautrix-whatsapp"`
  instead of `"net.maunium.whatsapp.puppet": true` as the indicator.
* Renamed `!wa check-invite` to `!wa resolve-link` and added support for
  WhatsApp business DM links (`https://wa.me/message/...`).
* Improved read receipt handling to mark all unread messages as read on
  WhatsApp instead of only marking the last message as read.
* Updated Docker image to Alpine 3.15.
* Fixed some issues with app state syncing not working
  (especially related to contacts).
* Fixed responding to retry receipts not working correctly.

[MSC2409]: https://github.com/matrix-org/matrix-spec-proposals/pull/2409
[#387]: https://github.com/mautrix/whatsapp/pull/387

# v0.2.1 (2021-11-10)

* Added support for double puppeting from other servers
  (started by [@abmantis] in [#368]).
  * This does not apply to post-login backfilling, as it's not possible to use
    MSC2716's `/batch_send` with users from other servers.
* Added config updater similar to mautrix-python bridges.
* Added support for responding to retry receipts (to automatically resolve
  other devices not being able to decrypt messages from the bridge).
* Added `sync` command to resync contact and group info to Matrix (not to be
  confused with the pre-v0.2.0 `sync` command which also did backfill and other
  such things).
* Added warning when reacting to messages in portal rooms
  (thanks to [@abmantis] in [#373]).
  * Can be disabled with the `reaction_notices` config option.
* Fixed WhatsApp encryption failing if other user reinstalled the app.
  * New identities will now be auto-trusted, and if `identity_change_notices`
    is set to true, a notice about the change will be sent to the private chat
    portal.
* Fixed contact info sync at login racing with portal/puppet creation and
  therefore not being synced properly.
* Fixed read receipts from WhatsApp on iOS that mark multiple messages as read
  not being handled properly.
* Fixed backfilling not working when double puppeting was not enabled at all.
* Fixed portals not being saved on SQLite.
* Fixed relay mode using old name for users after displayname change.
* Fixed displayname not being HTML-escaped in relay mode message templates.

[@abmantis]: https://github.com/abmantis
[#368]: https://github.com/mautrix/whatsapp/pull/368
[#373]: https://github.com/mautrix/whatsapp/pull/373

# v0.2.0 (2021-11-05)

**N.B.** The minimum Go version is now 1.17. Also note that Docker image paths
have changed as mentioned in the [v0.1.8](#v018-2021-08-07) release notes.

* Switched to WhatsApp multidevice API. All users will have to log into the
  bridge again.
* Initial backfilling now uses [MSC2716]'s batch send endpoint.
  * MSC2716 support is behind a feature flag in Synapse, so initial backfilling
    is disabled by default. See the `history_sync` section in the example
    config for more details.
  * Missed message backfilling (e.g. after bridge downtime) still sends the
    messages normally and is always enabled.
* Replaced old relaybot system with a portal-specific relay user option like in mautrix-signal.
  * You will have to re-setup the relaybot with the new system
    (see [docs](https://docs.mau.fi/bridges/general/relay-mode.html)).
* Many config fields have been changed/renamed/removed, so it is recommended to
  look through the example config and update your config.

[MSC2716]: https://github.com/matrix-org/matrix-spec-proposals/pull/2716

# v0.1.10 (2021-11-02)

This release just disables SQLite foreign keys, since some people already have
invalid rows in the database, which caused issues when SQLite re-checked the
rows during database migrations (#360). The invalid rows shouldn't cause any
actual issues, since the bridge uses foreign keys primarily for cascade delete
purposes.

If you're using Postgres, this update is not necessary.

# v0.1.9 (2021-10-28)

This is the final release targeting the legacy WhatsApp web API that requires a
phone connection. v0.2.0 will switch to the new multidevice API.

* Added support for bridging ephemeral and view-once messages.
* Added custom flag to invite events that will be auto-accepted using double
  puppeting.
* Added proper error message when trying to log in with multidevice enabled.
* Added automatic conversion of webp images to png when sending to WhatsApp
  (thanks to [@apmechev] in [#346]).
* Added support for customizing bridge bot welcome message
  (thanks to [@justinbot] and [@Half-Shot] in [#355]).
* Fixed MetricsHandler causing panics on heavy traffic instances
  (thanks to [@tadzik] in [#359]).
* Removed message content from database.

[@apmechev]: https://github.com/apmechev
[@justinbot]: https://github.com/justinbot
[@Half-Shot]: https://github.com/Half-Shot
[@tadzik]: https://github.com/tadzik
[#346]: https://github.com/mautrix/whatsapp/pull/346
[#355]: https://github.com/mautrix/whatsapp/pull/355
[#359]: https://github.com/mautrix/whatsapp/pull/359

# v0.1.8 (2021-08-07)

**N.B.** Docker images have moved from `dock.mau.dev/tulir/mautrix-whatsapp`
to `dock.mau.dev/mautrix/whatsapp`. New versions are only available at the new
path.

* Added very basic support for bridging [MSC3245] voice messages into
  push-to-talk messages on WhatsApp.
* Added support for Matrix->WhatsApp location messages.
* Renamed `whatsapp_message_age` and `whatsapp_message` prometheus metrics to
  `remote_event_age` and `remote_event` respectively.
* Fixed handling sticker gifs from Matrix.
* Fixed bridging audio/video duration from/to WhatsApp.
* Fixed messages not going through until restart if initial room creation
  attempt fails.
* Fixed issues where some WhatsApp protocol message in new chats prevented the
  first actual message from being bridged.
* Fixed some media from WhatsApp not being bridged due to file length or
  checksum mismatches. WhatsApp clients don't seem to care, so the bridge also
  ignores those errors now.

[MSC3245]: https://github.com/matrix-org/matrix-spec-proposals/pull/3245

# v0.1.7 (2021-06-15)

* Added option to disable creating WhatsApp status broadcast rooms.
* Added option to bridge chat archive, pin and mute statuses from WhatsApp.
* Moved Matrix HTTP request retrying to mautrix-go (which now retries all
  requests instead of only send message requests).
* Made bridge status reporting more generic (now takes an arbitrary HTTP
  endpoint to push bridge status to instead of requiring mautrix-asmux).
* Updated error messages sent to Matrix to be more understandable if WhatsApp
  returns status code 400 or 599.
* Fixed encryption getting messed up after receiving inbound olm sessions if
  using SQLite.
* Fixed bridge sending old messages after new ones if initial backfill limit is
  low and bridge gets restarted.
* Fixed read receipt bridging sometimes marking too many messages as read on
  Matrix (and then echoing it back to WhatsApp).
* Fixed false-positive message send error that showed up on WhatsApp mobile for
  messages sent from Matrix.
* Fixed ghost user displaynames for newly added group members never getting set
  if `chat_meta_sync` is `false`.

# v0.1.6 (2021-04-01)

* Added support for broadcast lists.
* Added automatic re-login-matrix using login shared secret if `/sync` returns `M_UNKNOWN_TOKEN`.
* Added syncing of contact info when syncing room members to ensure that
  WhatsApp ghost users have displaynames before the Matrix user sees them for
  the first time.
* Added bridging of own WhatsApp read receipts after backfilling.
* Added option not to re-sync chat info and user avatars on startup to avoid
  WhatsApp rate limits (error 599).
  * When resync is disabled, chat info changes will still come through by
    backfilling messages. However, user avatars will currently not update after
    being synced once.
* Improved automatic reconnection to work more like WhatsApp Web.
  * The bridge no longer disconnects the websocket if the phone stops
    responding. Instead it sends periodic pings until the phone responds.
  * Outgoing messages will be queued and resent automatically when the phone
    responds again.
* Added option to disable bridging messages where the `msgtype` is `m.notice`
  (thanks to [@hramirezf] in [#259]).
* Fixed backfilling failing in some cases due to 404 errors.
* Merged the whatsapp-ext module into [go-whatsapp].
* Disabled personal filtering communities by default.
* Updated Docker image to Alpine 3.13.

[@hramirezf]: https://github.com/hramirezf
[#259]: https://github.com/mautrix/whatsapp/pull/259
[go-whatsapp]: https://github.com/tulir/go-whatsapp

# v0.1.5 (2020-12-28)

* Renamed device name fields in config from `device_name` and `short_name` to
  `os_name` and `browser_name` respectively.
* Replaced shared secret login with appservice login ([MSC2778]) when logging
  into bridge bot for e2be.
* Removed webp conversion for WhatsApp→Matrix stickers.
* Added short wait if encrypted message arrives before decryption keys.
* Added bridge error notices if messages fail to decrypt.
* Added command to discard the bridge's Megolm session in a room.
* Added retrying for Matrix message sending if server returns 502.
* Added browser-compatible authentication to login API websocket.
* Fixed creating new WhatsApp groups for unencrypted Matrix rooms.
* Changed provisioning API to automatically delete session if logout request fails.
* Changed CI to statically compile olm into the bridge executable.
* Fixed bridging changes to group read-only status to Matrix (thanks to [@rreuvekamp] in [#232]).
* Fixed bridging names of files that were sent from another bridge.
* Fixed handling empty commands.

[MSC2778]: https://github.com/matrix-org/matrix-spec-proposals/pull/2778
[@rreuvekamp]: https://github.com/rreuvekamp
[#232]: https://github.com/mautrix/whatsapp/pull/232

# v0.1.4 (2020-09-04)

* Added better error reporting for media bridging errors.
* Added bridging for own read receipts from WhatsApp mobile when using double
  puppeting.
* Added build tag to disable crypto without disabling SQLite.
* Added support for automatic key sharing.
* Added option to update `m.direct` when using double puppeting.
* Made read receipt bridging toggleable separately from presence bridging.
* Fixed the formatter bridging all numbers starting with `@` on WhatsApp into
  pills on Matrix (now it only bridges actual mentions into pills).
* Fixed handling new contacts and receiving names of non-contacts in groups
  when they send a message.

# v0.1.3 (2020-07-10)

* Added command to create WhatsApp groups.
* Added command to disable bridging presence and read receipts.
* Added full group member syncing (including kicking of users who left before).
* Allowed creating private chat portal by inviting WhatsApp puppet.
* Fixed bug where inaccessible private chat portals couldn't be recreated with
  `pm` command.

# v0.1.2 (2020-07-04)

* Added option to disable notifications during initial backfill.
* Added bridging of contact and location messages.
* Added support for leaving chats and kicking/inviting WhatsApp users from Matrix.
* Added bridging of leaves/kicks/invites from WhatsApp to Matrix.
* Added config option to re-send bridge info state event to all existing portals.
* Added basic prometheus metrics.
* Added low phone battery warning messages.
* Added command to join groups with invite link.
* Fixed media not being encrypted when sending to encrypted portal rooms.

# v0.1.1 (2020-06-04)

* Updated mautrix-go to fix new OTK generation for end-to-bridge encryption.
* Added missing `v` to version command output.
* Fixed creating docker tags for releases.

# v0.1.0 (2020-06-03)

Initial release.



================================================
FILE: docker-run.sh
================================================
#!/bin/sh

if [[ -z "$GID" ]]; then
	GID="$UID"
fi

# Define functions.
function fixperms {
	chown -R $UID:$GID /data

	# /opt/mautrix-whatsapp is read-only, so disable file logging if it's pointing there.
	if [[ "$(yq e '.logging.writers[1].filename' /data/config.yaml)" == "./logs/mautrix-whatsapp.log" ]]; then
		yq -I4 e -i 'del(.logging.writers[1])' /data/config.yaml
	fi
}

if [[ ! -f /data/config.yaml ]]; then
	/usr/bin/mautrix-whatsapp -c /data/config.yaml -e
	echo "Didn't find a config file."
	echo "Copied default config file to /data/config.yaml"
	echo "Modify that config file to your liking."
	echo "Start the container again after that to generate the registration file."
	exit
fi

if [[ ! -f /data/registration.yaml ]]; then
	/usr/bin/mautrix-whatsapp -g -c /data/config.yaml -r /data/registration.yaml || exit $?
	echo "Didn't find a registration file."
	echo "Generated one for you."
	echo "See https://docs.mau.fi/bridges/general/registering-appservices.html on how to use it."
	exit
fi

cd /data
fixperms
exec su-exec $UID:$GID /usr/bin/mautrix-whatsapp



================================================
FILE: Dockerfile
================================================
FROM golang:1-alpine3.23 AS builder

RUN apk add --no-cache git ca-certificates build-base su-exec olm-dev

COPY . /build
WORKDIR /build
RUN ./build.sh

FROM alpine:3.23

ENV UID=1337 \
    GID=1337

RUN apk add --no-cache ffmpeg su-exec ca-certificates olm bash jq curl yq-go lottieconverter

COPY --from=builder /build/mautrix-whatsapp /usr/bin/mautrix-whatsapp
COPY --from=builder /build/docker-run.sh /docker-run.sh
VOLUME /data

CMD ["/docker-run.sh"]



================================================
FILE: Dockerfile.ci
================================================
ARG DOCKER_HUB="docker.io"

FROM ${DOCKER_HUB}/alpine:3.23

ENV UID=1337 \
    GID=1337

RUN apk add --no-cache ffmpeg su-exec ca-certificates bash jq curl yq-go lottieconverter

ARG EXECUTABLE=./mautrix-whatsapp
COPY $EXECUTABLE /usr/bin/mautrix-whatsapp
COPY ./docker-run.sh /docker-run.sh
ENV BRIDGEV2=1
VOLUME /data
WORKDIR /data

CMD ["/docker-run.sh"]



================================================
FILE: go.mod
================================================
module go.mau.fi/mautrix-whatsapp

go 1.24.0

toolchain go1.25.5

tool go.mau.fi/util/cmd/maubuild

require (
	github.com/lib/pq v1.10.9
	github.com/rs/zerolog v1.34.0
	go.mau.fi/util v0.9.4
	go.mau.fi/webp v0.2.0
	go.mau.fi/whatsmeow v0.0.0-20251217143725-11cf47c62d32
	golang.org/x/image v0.34.0
	golang.org/x/net v0.48.0
	golang.org/x/sync v0.19.0
	google.golang.org/protobuf v1.36.11
	gopkg.in/yaml.v3 v3.0.1
	maunium.net/go/mautrix v0.26.1
)

require (
	filippo.io/edwards25519 v1.1.0 // indirect
	github.com/beeper/argo-go v1.1.2 // indirect
	github.com/coder/websocket v1.8.14 // indirect
	github.com/coreos/go-systemd/v22 v22.6.0 // indirect
	github.com/elliotchance/orderedmap/v3 v3.1.0 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/kr/pretty v0.3.1 // indirect
	github.com/mattn/go-colorable v0.1.14 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/mattn/go-sqlite3 v1.14.32 // indirect
	github.com/petermattis/goid v0.0.0-20251121121749-a11dd1a45f9a // indirect
	github.com/rogpeppe/go-internal v1.10.0 // indirect
	github.com/rs/xid v1.6.0 // indirect
	github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e // indirect
	github.com/tidwall/gjson v1.18.0 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.1 // indirect
	github.com/tidwall/sjson v1.2.5 // indirect
	github.com/vektah/gqlparser/v2 v2.5.27 // indirect
	github.com/yuin/goldmark v1.7.13 // indirect
	go.mau.fi/libsignal v0.2.1 // indirect
	go.mau.fi/zeroconfig v0.2.0 // indirect
	golang.org/x/crypto v0.46.0 // indirect
	golang.org/x/exp v0.0.0-20251209150349-8475f28825e9 // indirect
	golang.org/x/mod v0.31.0 // indirect
	golang.org/x/sys v0.39.0 // indirect
	golang.org/x/text v0.32.0 // indirect
	gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c // indirect
	gopkg.in/natefinch/lumberjack.v2 v2.2.1 // indirect
	maunium.net/go/mauflag v1.0.0 // indirect
)



================================================
FILE: go.sum
================================================
filippo.io/edwards25519 v1.1.0 h1:FNf4tywRC1HmFuKW5xopWpigGjJKiJSV0Cqo0cJWDaA=
filippo.io/edwards25519 v1.1.0/go.mod h1:BxyFTGdWcka3PhytdK4V28tE5sGfRvvvRV7EaN4VDT4=
github.com/DATA-DOG/go-sqlmock v1.5.2 h1:OcvFkGmslmlZibjAjaHm3L//6LiuBgolP7OputlJIzU=
github.com/DATA-DOG/go-sqlmock v1.5.2/go.mod h1:88MAG/4G7SMwSE3CeA0ZKzrT5CiOU3OJ+JlNzwDqpNU=
github.com/agnivade/levenshtein v1.2.1 h1:EHBY3UOn1gwdy/VbFwgo4cxecRznFk7fKWN1KOX7eoM=
github.com/agnivade/levenshtein v1.2.1/go.mod h1:QVVI16kDrtSuwcpd0p1+xMC6Z/VfhtCyDIjcwga4/DU=
github.com/andreyvit/diff v0.0.0-20170406064948-c7f18ee00883 h1:bvNMNQO63//z+xNgfBlViaCIJKLlCJ6/fmUseuG0wVQ=
github.com/andreyvit/diff v0.0.0-20170406064948-c7f18ee00883/go.mod h1:rCTlJbsFo29Kk6CurOXKm700vrz8f0KW0JNfpkRJY/8=
github.com/beeper/argo-go v1.1.2 h1:UQI2G8F+NLfGTOmTUI0254pGKx/HUU/etbUGTJv91Fs=
github.com/beeper/argo-go v1.1.2/go.mod h1:M+LJAnyowKVQ6Rdj6XYGEn+qcVFkb3R/MUpqkGR0hM4=
github.com/coder/websocket v1.8.14 h1:9L0p0iKiNOibykf283eHkKUHHrpG7f65OE3BhhO7v9g=
github.com/coder/websocket v1.8.14/go.mod h1:NX3SzP+inril6yawo5CQXx8+fk145lPDC6pumgx0mVg=
github.com/coreos/go-systemd/v22 v22.5.0/go.mod h1:Y58oyj3AT4RCenI/lSvhwexgC+NSVTIJ3seZv2GcEnc=
github.com/coreos/go-systemd/v22 v22.6.0 h1:aGVa/v8B7hpb0TKl0MWoAavPDmHvobFe5R5zn0bCJWo=
github.com/coreos/go-systemd/v22 v22.6.0/go.mod h1:iG+pp635Fo7ZmV/j14KUcmEyWF+0X7Lua8rrTWzYgWU=
github.com/creack/pty v1.1.9/go.mod h1:oKZEueFk5CKHvIhNR5MUki03XCEU+Q6VDXinZuGJ33E=
github.com/davecgh/go-spew v1.1.1 h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=
github.com/davecgh/go-spew v1.1.1/go.mod h1:J7Y8YcW2NihsgmVo/mv3lAwl/skON4iLHjSsI+c5H38=
github.com/elliotchance/orderedmap/v3 v3.1.0 h1:j4DJ5ObEmMBt/lcwIecKcoRxIQUEnw0L804lXYDt/pg=
github.com/elliotchance/orderedmap/v3 v3.1.0/go.mod h1:G+Hc2RwaZvJMcS4JpGCOyViCnGeKf0bTYCGTO4uhjSo=
github.com/godbus/dbus/v5 v5.0.4/go.mod h1:xhWf0FNVPg57R7Z0UbKHbJfkEywrmjJnf7w5xrFpKfA=
github.com/google/go-cmp v0.7.0 h1:wk8382ETsv4JYUZwIsn6YpYiWiBsYLSJiTsyBybVuN8=
github.com/google/go-cmp v0.7.0/go.mod h1:pXiqmnSA92OHEEa9HXL2W4E7lf9JzCmGVUdgjX3N/iU=
github.com/google/uuid v1.6.0 h1:NIvaJDMOsjHA8n1jAhLSgzrAzy1Hgr+hNrb57e+94F0=
github.com/google/uuid v1.6.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqOeaOT+nhxU+yHo=
github.com/kr/pretty v0.2.1/go.mod h1:ipq/a2n7PKx3OHsz4KJII5eveXtPO4qwEXGdVfWzfnI=
github.com/kr/pretty v0.3.1 h1:flRD4NNwYAUpkphVc1HcthR4KEIFJ65n8Mw5qdRn3LE=
github.com/kr/pretty v0.3.1/go.mod h1:hoEshYVHaxMs3cyo3Yncou5ZscifuDolrwPKZanG3xk=
github.com/kr/pty v1.1.1/go.mod h1:pFQYn66WHrOpPYNljwOMqo10TkYh1fy3cYio2l3bCsQ=
github.com/kr/text v0.1.0/go.mod h1:4Jbv+DJW3UT/LiOwJeYQe1efqtUx/iVham/4vfdArNI=
github.com/kr/text v0.2.0 h1:5Nx0Ya0ZqY2ygV366QzturHI13Jq95ApcVaJBhpS+AY=
github.com/kr/text v0.2.0/go.mod h1:eLer722TekiGuMkidMxC/pM04lWEeraHUUmBw8l2grE=
github.com/lib/pq v1.10.9 h1:YXG7RB+JIjhP29X+OtkiDnYaXQwpS4JEWq7dtCCRUEw=
github.com/lib/pq v1.10.9/go.mod h1:AlVN5x4E4T544tWzH6hKfbfQvm3HdbOxrmggDNAPY9o=
github.com/mattn/go-colorable v0.1.13/go.mod h1:7S9/ev0klgBDR4GtXTXX8a3vIGJpMovkB8vQcUbaXHg=
github.com/mattn/go-colorable v0.1.14 h1:9A9LHSqF/7dyVVX6g0U9cwm9pG3kP9gSzcuIPHPsaIE=
github.com/mattn/go-colorable v0.1.14/go.mod h1:6LmQG8QLFO4G5z1gPvYEzlUgJ2wF+stgPZH1UqBm1s8=
github.com/mattn/go-isatty v0.0.16/go.mod h1:kYGgaQfpe5nmfYZH+SKPsOc2e4SrIfOl2e/yFXSvRLM=
github.com/mattn/go-isatty v0.0.19/go.mod h1:W+V8PltTTMOvKvAeJH7IuucS94S2C6jfK/D7dTCTo3Y=
github.com/mattn/go-isatty v0.0.20 h1:xfD0iDuEKnDkl03q4limB+vH+GxLEtL/jb4xVJSWWEY=
github.com/mattn/go-isatty v0.0.20/go.mod h1:W+V8PltTTMOvKvAeJH7IuucS94S2C6jfK/D7dTCTo3Y=
github.com/mattn/go-sqlite3 v1.14.32 h1:JD12Ag3oLy1zQA+BNn74xRgaBbdhbNIDYvQUEuuErjs=
github.com/mattn/go-sqlite3 v1.14.32/go.mod h1:Uh1q+B4BYcTPb+yiD3kU8Ct7aC0hY9fxUwlHK0RXw+Y=
github.com/petermattis/goid v0.0.0-20251121121749-a11dd1a45f9a h1:VweslR2akb/ARhXfqSfRbj1vpWwYXf3eeAUyw/ndms0=
github.com/petermattis/goid v0.0.0-20251121121749-a11dd1a45f9a/go.mod h1:pxMtw7cyUw6B2bRH0ZBANSPg+AoSud1I1iyJHI69jH4=
github.com/pkg/diff v0.0.0-20210226163009-20ebb0f2a09e/go.mod h1:pJLUxLENpZxwdsKMEsNbx1VGcRFpLqf3715MtcvvzbA=
github.com/pkg/errors v0.9.1/go.mod h1:bwawxfHBFNV+L2hUp1rHADufV3IMtnDRdf1r5NINEl0=
github.com/pmezard/go-difflib v1.0.0 h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=
github.com/pmezard/go-difflib v1.0.0/go.mod h1:iKH77koFhYxTK1pcRnkKkqfTogsbg7gZNVY4sRDYZ/4=
github.com/rogpeppe/go-internal v1.9.0/go.mod h1:WtVeX8xhTBvf0smdhujwtBcq4Qrzq/fJaraNFVN+nFs=
github.com/rogpeppe/go-internal v1.10.0 h1:TMyTOH3F/DB16zRVcYyreMH6GnZZrwQVAoYjRBZyWFQ=
github.com/rogpeppe/go-internal v1.10.0/go.mod h1:UQnix2H7Ngw/k4C5ijL5+65zddjncjaFoBhdsK/akog=
github.com/rs/xid v1.6.0 h1:fV591PaemRlL6JfRxGDEPl69wICngIQ3shQtzfy2gxU=
github.com/rs/xid v1.6.0/go.mod h1:7XoLgs4eV+QndskICGsho+ADou8ySMSjJKDIan90Nz0=
github.com/rs/zerolog v1.34.0 h1:k43nTLIwcTVQAncfCw4KZ2VY6ukYoZaBPNOE8txlOeY=
github.com/rs/zerolog v1.34.0/go.mod h1:bJsvje4Z08ROH4Nhs5iH600c3IkWhwp44iRc54W6wYQ=
github.com/sergi/go-diff v1.3.1 h1:xkr+Oxo4BOQKmkn/B9eMK0g5Kg/983T9DqqPHwYqD+8=
github.com/sergi/go-diff v1.3.1/go.mod h1:aMJSSKb2lpPvRNec0+w3fl7LP9IOFzdc9Pa4NFbPK1I=
github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e h1:MRM5ITcdelLK2j1vwZ3Je0FKVCfqOLp5zO6trqMLYs0=
github.com/skip2/go-qrcode v0.0.0-20200617195104-da1b6568686e/go.mod h1:XV66xRDqSt+GTGFMVlhk3ULuV0y9ZmzeVGR4mloJI3M=
github.com/stretchr/testify v1.11.1 h1:7s2iGBzp5EwR7/aIZr8ao5+dra3wiQyKjjFuvgVKu7U=
github.com/stretchr/testify v1.11.1/go.mod h1:wZwfW3scLgRK+23gO65QZefKpKQRnfz6sD981Nm4B6U=
github.com/tidwall/gjson v1.14.2/go.mod h1:/wbyibRr2FHMks5tjHJ5F8dMZh3AcwJEMf5vlfC0lxk=
github.com/tidwall/gjson v1.18.0 h1:FIDeeyB800efLX89e5a8Y0BNH+LOngJyGrIWxG2FKQY=
github.com/tidwall/gjson v1.18.0/go.mod h1:/wbyibRr2FHMks5tjHJ5F8dMZh3AcwJEMf5vlfC0lxk=
github.com/tidwall/match v1.1.1 h1:+Ho715JplO36QYgwN9PGYNhgZvoUSc9X2c80KVTi+GA=
github.com/tidwall/match v1.1.1/go.mod h1:eRSPERbgtNPcGhD8UCthc6PmLEQXEWd3PRB5JTxsfmM=
github.com/tidwall/pretty v1.2.0/go.mod h1:ITEVvHYasfjBbM0u2Pg8T2nJnzm8xPwvNhhsoaGGjNU=
github.com/tidwall/pretty v1.2.1 h1:qjsOFOWWQl+N3RsoF5/ssm1pHmJJwhjlSbZ51I6wMl4=
github.com/tidwall/pretty v1.2.1/go.mod h1:ITEVvHYasfjBbM0u2Pg8T2nJnzm8xPwvNhhsoaGGjNU=
github.com/tidwall/sjson v1.2.5 h1:kLy8mja+1c9jlljvWTlSazM7cKDRfJuR/bOJhcY5NcY=
github.com/tidwall/sjson v1.2.5/go.mod h1:Fvgq9kS/6ociJEDnK0Fk1cpYF4FIW6ZF7LAe+6jwd28=
github.com/vektah/gqlparser/v2 v2.5.27 h1:RHPD3JOplpk5mP5JGX8RKZkt2/Vwj/PZv0HxTdwFp0s=
github.com/vektah/gqlparser/v2 v2.5.27/go.mod h1:D1/VCZtV3LPnQrcPBeR/q5jkSQIPti0uYCP/RI0gIeo=
github.com/yuin/goldmark v1.7.13 h1:GPddIs617DnBLFFVJFgpo1aBfe/4xcvMc3SB5t/D0pA=
github.com/yuin/goldmark v1.7.13/go.mod h1:ip/1k0VRfGynBgxOz0yCqHrbZXhcjxyuS66Brc7iBKg=
go.mau.fi/libsignal v0.2.1 h1:vRZG4EzTn70XY6Oh/pVKrQGuMHBkAWlGRC22/85m9L0=
go.mau.fi/libsignal v0.2.1/go.mod h1:iVvjrHyfQqWajOUaMEsIfo3IqgVMrhWcPiiEzk7NgoU=
go.mau.fi/util v0.9.4 h1:gWdUff+K2rCynRPysXalqqQyr2ahkSWaestH6YhSpso=
go.mau.fi/util v0.9.4/go.mod h1:647nVfwUvuhlZFOnro3aRNPmRd2y3iDha9USb8aKSmM=
go.mau.fi/webp v0.2.0 h1:QVMenHw7JDb4vall5sV75JNBQj9Hw4u8AKbi1QetHvg=
go.mau.fi/webp v0.2.0/go.mod h1:VSg9MyODn12Mb5pyG0NIyNFhujrmoFSsZBs8syOZD1Q=
go.mau.fi/whatsmeow v0.0.0-20251217143725-11cf47c62d32 h1:NeE9eEYY4kEJVCfCXaAU27LgAPugPHRHJdC9IpXFPzI=
go.mau.fi/whatsmeow v0.0.0-20251217143725-11cf47c62d32/go.mod h1:S4OWR9+hTx+54+jRzl+NfRBXnGpPm5IRPyhXB7haSd0=
go.mau.fi/zeroconfig v0.2.0 h1:e/OGEERqVRRKlgaro7E6bh8xXiKFSXB3eNNIud7FUjU=
go.mau.fi/zeroconfig v0.2.0/go.mod h1:J0Vn0prHNOm493oZoQ84kq83ZaNCYZnq+noI1b1eN8w=
golang.org/x/crypto v0.46.0 h1:cKRW/pmt1pKAfetfu+RCEvjvZkA9RimPbh7bhFjGVBU=
golang.org/x/crypto v0.46.0/go.mod h1:Evb/oLKmMraqjZ2iQTwDwvCtJkczlDuTmdJXoZVzqU0=
golang.org/x/exp v0.0.0-20251209150349-8475f28825e9 h1:MDfG8Cvcqlt9XXrmEiD4epKn7VJHZO84hejP9Jmp0MM=
golang.org/x/exp v0.0.0-20251209150349-8475f28825e9/go.mod h1:EPRbTFwzwjXj9NpYyyrvenVh9Y+GFeEvMNh7Xuz7xgU=
golang.org/x/image v0.34.0 h1:33gCkyw9hmwbZJeZkct8XyR11yH889EQt/QH4VmXMn8=
golang.org/x/image v0.34.0/go.mod h1:2RNFBZRB+vnwwFil8GkMdRvrJOFd1AzdZI6vOY+eJVU=
golang.org/x/mod v0.31.0 h1:HaW9xtz0+kOcWKwli0ZXy79Ix+UW/vOfmWI5QVd2tgI=
golang.org/x/mod v0.31.0/go.mod h1:43JraMp9cGx1Rx3AqioxrbrhNsLl2l/iNAvuBkrezpg=
golang.org/x/net v0.48.0 h1:zyQRTTrjc33Lhh0fBgT/H3oZq9WuvRR5gPC70xpDiQU=
golang.org/x/net v0.48.0/go.mod h1:+ndRgGjkh8FGtu1w1FGbEC31if4VrNVMuKTgcAAnQRY=
golang.org/x/sync v0.19.0 h1:vV+1eWNmZ5geRlYjzm2adRgW2/mcpevXNg50YZtPCE4=
golang.org/x/sync v0.19.0/go.mod h1:9KTHXmSnoGruLpwFjVSX0lNNA75CykiMECbovNTZqGI=
golang.org/x/sys v0.0.0-20220811171246-fbc7d0a398ab/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.6.0/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.12.0/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.39.0 h1:CvCKL8MeisomCi6qNZ+wbb0DN9E5AATixKsvNtMoMFk=
golang.org/x/sys v0.39.0/go.mod h1:OgkHotnGiDImocRcuBABYBEXf8A9a87e/uXjp9XT3ks=
golang.org/x/text v0.32.0 h1:ZD01bjUt1FQ9WJ0ClOL5vxgxOI/sVCNgX1YtKwcY0mU=
golang.org/x/text v0.32.0/go.mod h1:o/rUWzghvpD5TXrTIBuJU77MTaN0ljMWE47kxGJQ7jY=
google.golang.org/protobuf v1.36.11 h1:fV6ZwhNocDyBLK0dj+fg8ektcVegBBuEolpbTQyBNVE=
google.golang.org/protobuf v1.36.11/go.mod h1:HTf+CrKn2C3g5S8VImy6tdcUvCska2kB7j23XfzDpco=
gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod h1:Co6ibVJAznAaIkqp8huTwlJQCZ016jof/cbN4VW5Yz0=
gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c h1:Hei/4ADfdWqJk1ZMxUNpqntNwaWcugrBjAiHlqqRiVk=
gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c/go.mod h1:JHkPIbrfpd72SG/EVd6muEfDQjcINNoR0C8j2r3qZ4Q=
gopkg.in/natefinch/lumberjack.v2 v2.2.1 h1:bBRl1b0OH9s/DuPhuXpNl+VtCaJXFZ5/uEFST95x9zc=
gopkg.in/natefinch/lumberjack.v2 v2.2.1/go.mod h1:YD8tP3GAjkrDg1eZH7EGmyESg/lsYskCTPBJVb9jqSc=
gopkg.in/yaml.v3 v3.0.1 h1:fxVm/GzAzEWqLHuvctI91KS9hhNmmWOoWu0XTYJS7CA=
gopkg.in/yaml.v3 v3.0.1/go.mod h1:K4uyk7z7BCEPqu6E+C64Yfv1cQ7kz7rIZviUmN+EgEM=
maunium.net/go/mauflag v1.0.0 h1:YiaRc0tEI3toYtJMRIfjP+jklH45uDHtT80nUamyD4M=
maunium.net/go/mauflag v1.0.0/go.mod h1:nLivPOpTpHnpzEh8jEdSL9UqO9+/KBJFmNRlwKfkPeA=
maunium.net/go/mautrix v0.26.1 h1:FWCC1xY5vwJ5ou3duEBjB6w9IIlwfc9el3q3Mju3Dlg=
maunium.net/go/mautrix v0.26.1/go.mod h1:UySSpb8OqXG1sMJ6dDqyzmfcqr2ayZK+KzwqOTAkAOM=



================================================
FILE: LICENSE
================================================
                    GNU AFFERO GENERAL PUBLIC LICENSE
                       Version 3, 19 November 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU Affero General Public License is a free, copyleft license for
software and other kinds of works, specifically designed to ensure
cooperation with the community in the case of network server software.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
our General Public Licenses are intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  Developers that use our General Public Licenses protect your rights
with two steps: (1) assert copyright on the software, and (2) offer
you this License which gives you legal permission to copy, distribute
and/or modify the software.

  A secondary benefit of defending all users' freedom is that
improvements made in alternate versions of the program, if they
receive widespread use, become available for other developers to
incorporate.  Many developers of free software are heartened and
encouraged by the resulting cooperation.  However, in the case of
software used on network servers, this result may fail to come about.
The GNU General Public License permits making a modified version and
letting the public access it on a server without ever releasing its
source code to the public.

  The GNU Affero General Public License is designed specifically to
ensure that, in such cases, the modified source code becomes available
to the community.  It requires the operator of a network server to
provide the source code of the modified version running there to the
users of that server.  Therefore, public use of a modified version, on
a publicly accessible server, gives the public access to the source
code of the modified version.

  An older license, called the Affero General Public License and
published by Affero, was designed to accomplish similar goals.  This is
a different license, not a version of the Affero GPL, but Affero has
released a new version of the Affero GPL which permits relicensing under
this license.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU Affero General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Remote Network Interaction; Use with the GNU General Public License.

  Notwithstanding any other provision of this License, if you modify the
Program, your modified version must prominently offer all users
interacting with it remotely through a computer network (if your version
supports such interaction) an opportunity to receive the Corresponding
Source of your version by providing access to the Corresponding Source
from a network server at no charge, through some standard or customary
means of facilitating copying of software.  This Corresponding Source
shall include the Corresponding Source for any work covered by version 3
of the GNU General Public License that is incorporated pursuant to the
following paragraph.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the work with which it is combined will remain governed by version
3 of the GNU General Public License.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU Affero General Public License from time to time.  Such new versions
will be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU Affero General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU Affero General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU Affero General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If your software can interact with users remotely through a computer
network, you should also make sure that it provides a way for users to
get its source.  For example, if your program is a web application, its
interface could display a "Source" link that leads users to an archive
of the code.  There are many ways you could offer source, and different
solutions will be better for different programs; see section 13 for the
specific requirements.

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU AGPL, see
<https://www.gnu.org/licenses/>.



================================================
FILE: LICENSE.exceptions
================================================
The mautrix-whatsapp developers grant the following special exceptions:

* to Beeper the right to embed the program in the Beeper clients and servers,
  and use and distribute the collective work without applying the license to
  the whole.
* to Element the right to distribute compiled binaries of the program as a part
  of the Element Server Suite and other server bundles without applying the
  license.

All exceptions are only valid under the condition that any modifications to
the source code of mautrix-whatsapp remain publicly available under the terms
of the GNU AGPL version 3 or later.



================================================
FILE: ROADMAP.md
================================================
# Features & roadmap
* Matrix → WhatsApp
  * [x] Message content
    * [x] Plain text
    * [x] Formatted messages
    * [x] Location messages
    * [x] Media/files
    * [x] Replies
    * [x] Polls
    * [x] Poll votes
  * [x] Message redactions
  * [x] Reactions
  * [x] Presence
  * [x] Typing notifications
  * [x] Read receipts
  * [ ] Power level
  * [x] Membership actions
    * [x] Invite
    * [x] Leave
    * [x] Kick
  * [ ] Room metadata changes
    * [ ] Name
    * [ ] Avatar
    * [ ] Topic
  * [ ] Initial room metadata
* WhatsApp → Matrix
  * [x] Message content
    * [x] Plain text
    * [x] Formatted messages
    * [x] Media/files
    * [x] Location messages
    * [x] Contact messages
    * [x] Replies
    * [x] Polls
    * [x] Poll votes
  * [ ] Chat types
    * [x] Private chat
    * [x] Group chat
    * [x] Communities
    * [x] Status broadcast
    * [ ] Broadcast list (not currently supported on WhatsApp web)
  * [x] Message deletions
  * [x] Reactions
  * [x] Avatars
  * [ ] Presence
  * [x] Typing notifications
  * [x] Read receipts
  * [x] Admin/superadmin status
  * [x] Membership actions
    * [x] Invite
    * [x] Join
    * [x] Leave
    * [x] Kick
  * [x] Group metadata changes
    * [x] Title
    * [x] Avatar
    * [x] Description
  * [x] Initial group metadata
  * [x] User metadata changes
    * [x] Display name
    * [x] Avatar
  * [x] Initial user metadata
    * [x] Display name
    * [x] Avatar
* Misc
  * [x] Automatic portal creation
    * [x] After login
    * [x] When added to group
    * [x] When receiving message
  * [x] Private chat creation by inviting Matrix puppet of WhatsApp user to new room
  * [x] Option to use own Matrix account for messages sent from WhatsApp mobile/other web clients
  * [x] Shared group chat portals



================================================
FILE: .editorconfig
================================================
root = true

[*]
indent_style = tab
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{yaml,yml,sql}]
indent_style = space

[.gitlab-ci.yml]
indent_size = 2



================================================
FILE: .gitlab-ci.yml
================================================
include:
- project: 'mautrix/ci'
  file: '/gov2-as-default.yml'



================================================
FILE: .pre-commit-config.yaml
================================================
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
        exclude_types: [markdown]
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/tekwizely/pre-commit-golang
    rev: v1.0.0-rc.4
    hooks:
      - id: go-imports-repo
        args:
          - "-local"
          - "go.mau.fi/mautrix-whatsapp"
          - "-w"
      - id: go-vet-repo-mod
      - id: go-staticcheck-repo-mod
      - id: go-mod-tidy

  - repo: https://github.com/beeper/pre-commit-go
    rev: v0.4.2
    hooks:
      - id: zerolog-ban-msgf
      - id: zerolog-use-stringer
      - id: prevent-literal-http-methods
      - id: zerolog-ban-global-log



================================================
FILE: cmd/mautrix-whatsapp/legacyprovision.go
================================================
package main

import (
	"net/http"
	"strings"

	"github.com/rs/zerolog/hlog"
	"go.mau.fi/util/exhttp"
	"go.mau.fi/whatsmeow/types"
	"maunium.net/go/mautrix/bridgev2"
	"maunium.net/go/mautrix/bridgev2/matrix"
	"maunium.net/go/mautrix/id"

	"go.mau.fi/mautrix-whatsapp/pkg/connector"
	"go.mau.fi/mautrix-whatsapp/pkg/waid"
)

type OtherUserInfo struct {
	MXID   id.UserID           `json:"mxid"`
	JID    types.JID           `json:"jid"`
	Name   string              `json:"displayname"`
	Avatar id.ContentURIString `json:"avatar_url"`
}

type PortalInfo struct {
	RoomID      id.RoomID        `json:"room_id"`
	OtherUser   *OtherUserInfo   `json:"other_user,omitempty"`
	GroupInfo   *types.GroupInfo `json:"group_info,omitempty"`
	JustCreated bool             `json:"just_created"`
}

type Error struct {
	Success bool   `json:"success"`
	Error   string `json:"error"`
	ErrCode string `json:"errcode"`
}

func legacyProvContacts(w http.ResponseWriter, r *http.Request) {
	userLogin := m.Matrix.Provisioning.GetLoginForRequest(w, r)
	if userLogin == nil {
		return
	}
	if contacts, err := userLogin.Client.(*connector.WhatsAppClient).GetStore().Contacts.GetAllContacts(r.Context()); err != nil {
		hlog.FromRequest(r).Err(err).Msg("Failed to fetch all contacts")
		exhttp.WriteJSONResponse(w, http.StatusInternalServerError, Error{
			Error:   "Internal server error while fetching contact list",
			ErrCode: "failed to get contacts",
		})
	} else {
		augmentedContacts := map[types.JID]any{}
		for jid, contact := range contacts {
			var avatarURL id.ContentURIString
			if puppet, _ := m.Bridge.GetExistingGhostByID(r.Context(), waid.MakeUserID(jid)); puppet != nil {
				avatarURL = puppet.AvatarMXC
			}
			augmentedContacts[jid] = map[string]interface{}{
				"Found":        contact.Found,
				"FirstName":    contact.FirstName,
				"FullName":     contact.FullName,
				"PushName":     contact.PushName,
				"BusinessName": contact.BusinessName,
				"AvatarURL":    avatarURL,
			}
		}
		exhttp.WriteJSONResponse(w, http.StatusOK, augmentedContacts)
	}
}

func legacyProvResolveIdentifier(w http.ResponseWriter, r *http.Request) {
	number := r.PathValue("number")
	userLogin := m.Matrix.Provisioning.GetLoginForRequest(w, r)
	if userLogin == nil {
		return
	}
	startChat := strings.Contains(r.URL.Path, "/v1/pm/")
	resp, err := userLogin.Client.(*connector.WhatsAppClient).ResolveIdentifier(r.Context(), number, startChat)
	if err != nil {
		hlog.FromRequest(r).Warn().Err(err).Str("identifier", number).Msg("Failed to resolve identifier")
		matrix.RespondWithError(w, err, "Internal error resolving identifier")
		return
	}
	var portal *bridgev2.Portal
	if startChat {
		portal, err = m.Bridge.GetPortalByKey(r.Context(), resp.Chat.PortalKey)
		if err != nil {
			hlog.FromRequest(r).Warn().Err(err).Stringer("portal_key", resp.Chat.PortalKey).Msg("Failed to get portal by key")
			matrix.RespondWithError(w, err, "Internal error getting portal by key")
			return
		}
		err = portal.CreateMatrixRoom(r.Context(), userLogin, nil)
		if err != nil {
			hlog.FromRequest(r).Warn().Err(err).Stringer("portal_key", resp.Chat.PortalKey).Msg("Failed to create matrix room for portal")
			matrix.RespondWithError(w, err, "Internal error creating matrix room for portal")
			return
		}
	} else {
		portal, _ = m.Bridge.GetExistingPortalByKey(r.Context(), resp.Chat.PortalKey)
	}
	var roomID id.RoomID
	if portal != nil {
		roomID = portal.MXID
	}
	exhttp.WriteJSONResponse(w, http.StatusOK, PortalInfo{
		RoomID: roomID,
		OtherUser: &OtherUserInfo{
			JID:    waid.ParseUserID(resp.UserID),
			MXID:   resp.Ghost.Intent.GetMXID(),
			Name:   resp.Ghost.Name,
			Avatar: resp.Ghost.AvatarMXC,
		},
	})
}



================================================
FILE: cmd/mautrix-whatsapp/main.go
================================================
package main

import (
	"maunium.net/go/mautrix/bridgev2/matrix/mxmain"

	"go.mau.fi/mautrix-whatsapp/pkg/connector"
)

// Information to find out exactly which commit the bridge was built from.
// These are filled at build time with the -X linker flag.
var (
	Tag       = "unknown"
	Commit    = "unknown"
	BuildTime = "unknown"
)

var m = mxmain.BridgeMain{
	Name:        "mautrix-whatsapp",
	URL:         "https://github.com/mautrix/whatsapp",
	Description: "A Matrix-WhatsApp puppeting bridge.",
	Version:     "25.12",
	SemCalVer:   true,
	Connector:   &connector.WhatsAppConnector{},
}

func main() {
	m.PostStart = func() {
		if m.Matrix.Provisioning != nil {
			m.Matrix.Provisioning.Router.HandleFunc("GET /v1/contacts", legacyProvContacts)
			m.Matrix.Provisioning.Router.HandleFunc("GET /v1/resolve_identifier/{number}", legacyProvResolveIdentifier)
			m.Matrix.Provisioning.Router.HandleFunc("POST /v1/pm/{number}", legacyProvResolveIdentifier)
		}
	}
	m.InitVersion(Tag, Commit, BuildTime)
	m.Run()
}



================================================
FILE: .github/ISSUE_TEMPLATE/bug.md
================================================
---
name: Bug report
about: If something is definitely wrong in the bridge (rather than just a setup issue),
  file a bug report. Remember to include relevant logs. Asking in the Matrix room first
  is strongly recommended.
type: Bug

---

<!--
Remember to include relevant logs, the bridge version and any other details.

It's always best to ask in the Matrix room first, especially if you aren't sure
what details are needed. Issues with insufficient detail will likely just be
ignored or closed immediately.
-->



================================================
FILE: .github/ISSUE_TEMPLATE/config.yml
================================================
contact_links:
  - name: Troubleshooting docs & FAQ
    url: https://docs.mau.fi/bridges/general/troubleshooting.html
    about: Check this first if you're having problems setting up the bridge.
  - name: Support room
    url: https://matrix.to/#/#whatsapp:maunium.net
    about: For setup issues not answered by the troubleshooting docs, ask in the Matrix room.



================================================
FILE: .github/ISSUE_TEMPLATE/enhancement.md
================================================
---
name: Enhancement request
about: Submit a feature request or other suggestion
type: Feature

---



================================================
FILE: .github/workflows/go.yml
================================================
name: Go

on: [push, pull_request]

env:
  GOTOOLCHAIN: local

jobs:
  lint:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        go-version: ["1.24", "1.25"]
    name: Lint ${{ matrix.go-version == '1.25' && '(latest)' || '(old)' }}

    steps:
      - uses: actions/checkout@v6

      - name: Set up Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ matrix.go-version }}
          cache: true

      - name: Install libolm
        run: sudo apt-get install libolm-dev libolm3

      - name: Install dependencies
        run: |
          go install golang.org/x/tools/cmd/goimports@latest
          go install honnef.co/go/tools/cmd/staticcheck@latest
          export PATH="$HOME/go/bin:$PATH"

      - name: Run pre-commit
        uses: pre-commit/action@v3.0.1



================================================
FILE: .github/workflows/stale.yml
================================================
name: 'Lock old issues'

on:
  schedule:
    - cron: '0 16 * * *'
  workflow_dispatch:

permissions:
  issues: write
#  pull-requests: write
#  discussions: write

concurrency:
  group: lock-threads

jobs:
  lock-stale:
    runs-on: ubuntu-latest
    steps:
      - uses: dessant/lock-threads@v6
        id: lock
        with:
          issue-inactive-days: 90
          process-only: issues
      - name: Log processed threads
        run: |
          if [ '${{ steps.lock.outputs.issues }}' ]; then
            echo "Issues:" && echo '${{ steps.lock.outputs.issues }}' | jq -r '.[] | "https://github.com/\(.owner)/\(.repo)/issues/\(.issue_number)"'
          fi