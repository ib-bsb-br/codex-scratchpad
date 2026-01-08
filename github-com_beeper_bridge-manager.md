Directory structure:
└── beeper-bridge-manager/
    ├── README.md
    ├── build.sh
    ├── CHANGELOG.md
    ├── ci-build-all.sh
    ├── go.mod
    ├── go.sum
    ├── LICENSE
    ├── run.sh
    ├── .dockerignore
    ├── .editorconfig
    ├── .pre-commit-config.yaml
    ├── api/
    │   ├── beeperapi/
    │   │   ├── login.go
    │   │   └── whoami.go
    │   ├── gitlab/
    │   │   ├── build.go
    │   │   └── graphql.go
    │   └── hungryapi/
    │       └── appservice.go
    ├── bridgeconfig/
    │   ├── bluesky.tpl.yaml
    │   ├── bridgeconfig.go
    │   ├── bridgev2.tpl.yaml
    │   ├── discord.tpl.yaml
    │   ├── gmessages.tpl.yaml
    │   ├── googlechat.tpl.yaml
    │   ├── gvoice.tpl.yaml
    │   ├── heisenbridge.tpl.yaml
    │   ├── imessage.tpl.yaml
    │   ├── imessagego.tpl.yaml
    │   ├── linkedin.tpl.yaml
    │   ├── meta.tpl.yaml
    │   ├── signal.tpl.yaml
    │   ├── slack.tpl.yaml
    │   ├── telegram.tpl.yaml
    │   ├── twitter.tpl.yaml
    │   └── whatsapp.tpl.yaml
    ├── cli/
    │   ├── hyper/
    │   │   └── link.go
    │   └── interactive/
    │       └── flag.go
    ├── cmd/
    │   └── bbctl/
    │       ├── authconfig.go
    │       ├── bridgeutil.go
    │       ├── config.go
    │       ├── context.go
    │       ├── delete.go
    │       ├── login-email.go
    │       ├── login-password.go
    │       ├── logout.go
    │       ├── main.go
    │       ├── proxy.go
    │       ├── register.go
    │       ├── run.go
    │       └── whoami.go
    ├── docker/
    │   ├── README.md
    │   ├── Dockerfile
    │   └── run-bridge.sh
    ├── log/
    │   └── log.go
    └── .github/
        ├── ISSUE_TEMPLATE/
        │   ├── config.yml
        │   └── issue.md
        └── workflows/
            └── go.yaml


Files Content:

================================================
FILE: README.md
================================================
# Beeper Bridge Manager
A tool for running self-hosted bridges with the Beeper Matrix server.

The primary use case is running custom/3rd-party bridges with Beeper. You can
connect any<sup>†</sup> spec-compliant Matrix application service to your Beeper
account without having to self-host a whole Matrix homeserver. Note that if you
run 3rd party bridges that don't support end-to-bridge encryption, message
contents will be visible to Beeper servers.

<sub>†caveat: hungryserv does not implement the entire Matrix client-server API, so
it's possible some bridges won't work - you can report such cases in the
self-hosting support room linked below or in GitHub issues here</sub>

You can also self-host the official bridges for maximum security using this
tool (so that message re-encryption happens on a machine you control rather
than on Beeper servers).

This tool can not be used with any other Matrix homeserver, like self-hosted
Synapse instances. It is only for connecting self-hosted bridges to the
beeper.com server. For self-hosting the entire stack, refer to the official
documentation of the various projects
([Synapse](https://element-hq.github.io/synapse/latest/),
[mautrix bridges](https://docs.mau.fi/bridges/)).

> [!NOTE]
> Self-hosted bridges are not entitled to the usual level of customer support
> on Beeper. If you need help with self-hosting bridges using this tool, please
> join [#self-hosting:beeper.com] instead of asking in your support room.

[#self-hosting:beeper.com]: https://matrix.to/#/#self-hosting:beeper.com

## Usage
1. Download the latest binary from [GitHub releases](https://github.com/beeper/bridge-manager/releases)
   or [actions](https://nightly.link/beeper/bridge-manager/workflows/go.yaml/main).
   * Alternatively, you can build it yourself by cloning the repo and running
     `./build.sh`. Building requires Go 1.23 or higher.
   * bbctl supports amd64 and arm64 on Linux and macOS.
     Windows is not supported natively, please use WSL.
2. Log into your Beeper account with `bbctl login`.

Then continue with one of the sections below, depending on whether you want to
run an official Beeper bridge or a 3rd party bridge.

### Official bridges
For Python bridges, you must install Python 3 with the `venv` module with your
OS package manager. For example, `sudo apt install python3 python3-venv` on
Debian-based distros. The Python version built into macOS may be new enough, or
you can get the latest version via brew. The minimum Python version varies by
bridge, but if you use the latest Debian or Ubuntu LTS, it should be new enough.

Some bridges require ffmpeg for converting media (e.g. when sending gifs), so
you should also install that with your OS package manager (`sudo apt install ffmpeg`
on Debian or `brew install ffmpeg` on macOS).

After installing relevant dependencies:

3. Run `bbctl run <name>` to run the bridge.
   * `<name>`  should start with `sh-` and consist of a-z, 0-9 and -.
   * If `<name>` contains the bridge type, it will be automatically detected.
     Otherwise pass the type with `--type <type>`.
   * See the table below for supported official bridges.
   * The bridge will be installed to `~/.local/share/bbctl`. You can change the
     directory in the config file at `~/.config/bbctl.json`.
4. For now, you'll have to configure the bridge by sending a DM to the bridge
   bot (`@<name>bot:beeper.local`). Configuring self-hosted bridges through the
   chat networks dialog will be available in the future. Spaces and starting
   chats are also not yet available, although you can start chats using the
   `pm` command with the bridge bot.

There is currently a bug in Beeper Desktop that causes it to create encrypted
DMs even if the recipient doesn't support it. This means that for non-e2ee-
capable bridges like Heisenbridge, you'll have to create the DM with the bridge
bot in another Matrix client, or using the create group chat button in Beeper
Desktop.

Currently the bridge will run in foreground, so you'll have to keep `bbctl run`
active somewhere (tmux is a good option). In the future, a service mode will be
added where the bridge is registered as a systemd or launchd service to be
started automatically by the OS.

#### Official bridge list
When using `bbctl run` or `bbctl config` and the provided `<name>` contains one
of the identifiers (second column) listed below, bbctl will automatically guess
that type. A substring match is sufficient, e.g. `sh-mywhatsappbridge` will
match `whatsapp`. The first listed identifier is the "primary" one that can be
used with the `--type` flag.

| Bridge               | Identifier                           |
|----------------------|--------------------------------------|
| [mautrix-telegram]   | telegram                             |
| [mautrix-whatsapp]   | whatsapp                             |
| [mautrix-signal]     | signal                               |
| [mautrix-discord]    | discord                              |
| [mautrix-slack]      | slack                                |
| [mautrix-gmessages]  | gmessages,  googlemessages, rcs, sms |
| [mautrix-gvoice]     | gvoice, googlevoice                  |
| [mautrix-meta]       | meta, instagram, facebook            |
| [mautrix-googlechat] | googlechat, gchat                    |
| [mautrix-twitter]    | twitter                              |
| [mautrix-bluesky]    | bluesky, bsky                        |
| [mautrix-imessage]   | imessage                             |
| [beeper-imessage]    | imessagego                           |
| [mautrix-linkedin]   | linkedin                             |
| [heisenbridge]       | heisenbridge, irc                    |

[mautrix-telegram]: https://github.com/mautrix/telegram
[mautrix-whatsapp]: https://github.com/mautrix/whatsapp
[mautrix-signal]: https://github.com/mautrix/signal
[mautrix-discord]: https://github.com/mautrix/discord
[mautrix-slack]: https://github.com/mautrix/slack
[mautrix-gmessages]: https://github.com/mautrix/gmessages
[mautrix-gvoice]: https://github.com/mautrix/gvoice
[mautrix-meta]: https://github.com/mautrix/meta
[mautrix-googlechat]: https://github.com/mautrix/googlechat
[mautrix-twitter]: https://github.com/mautrix/twitter
[mautrix-bluesky]: https://github.com/mautrix/bluesky
[mautrix-imessage]: https://github.com/mautrix/imessage
[beeper-imessage]: https://github.com/beeper/imessage
[mautrix-linkedin]: https://github.com/mautrix/linkedin
[heisenbridge]: https://github.com/hifi/heisenbridge

### 3rd party bridgev2-based bridges
If you have a 3rd party bridge that's built on top of mautrix-go's bridgev2
framework, you can have bbctl generate a mostly-complete config file:

3. Run `bbctl config --type bridgev2 <name>` to generate a bridgev2 config with
   everything except the `network` section.
   * `<name>` is a short name for the bridge (a-z, 0-9, -). The name should
     start with `sh-`. The bridge user ID namespace will be `@<name>_.+:beeper.local`
     and the bridge bot will be `@<name>bot:beeper.local`.
4. Add the `network` section containing the bridge-specific configuration if
   necessary, then run the bridge normally.

All bridgev2 bridges support appservice websockets, so using `bbctl proxy` is
not necessary.

### 3rd party custom bridges
For any 3rd party bridges that don't use bridgev2, you'll only get a registration
file from bbctl and will have to configure the bridge yourself. Also, since such
3rd party bridges are unlikely to support Beeper's appservice websocket protocol,
you probably have to use `bbctl proxy` to connect to the websocket and turn
incoming data into HTTP requests for the bridge.

3. Run `bbctl register <name>` to generate an appservice registration file.
   * `<name>` is the same as in the above section.
4. Now you can configure and run the bridge by following the bridge's own
   documentation.
5. Modify the registration file to point at where the bridge will listen locally
   (e.g. `url: http://localhost:8080`), then run `bbctl proxy -r registration.yaml`
   to start the proxy.
   * The proxy will connect to the Beeper server using a websocket and push
     received events to the bridge via HTTP. Since the HTTP requests are all on
     localhost, you don't need port forwarding or TLS certificates.

Note that the homeserver URL is not guaranteed to be stable forever, it has
changed in the past, and it may change again in the future.

You can use `--json` with `register` to get the whole response as JSON instead
of registration YAML and pretty-printed extra details. This may be useful if
you want to automate fetching the homeserver URL.

### Deleting bridges
If you don't want a self-hosted bridge anymore, you can delete it using
`bbctl delete <name>`. Deleting a bridge will permanently erase all traces of
it from the Beeper servers (e.g. any rooms and ghost users it created).
For official bridges, it will also delete the local data directory with the
bridge config, database and python virtualenv (if applicable).

Note that deleting a bridge through the Beeper client settings will
*not* delete the bridge database that is stored locally; you must
delete that yourself, or use `bbctl delete` instead. The bridge
databases are stored in `~/.local/share/bbctl/prod` by default.
However, note that if you use any option that causes the bridge
database to be stored in a separate location, such as `-l` which
stores it in the current working directory, then `bbctl delete` will
*not* delete the bridge database, and you will again have to delete it
manually.

If you later re-add a self-hosted bridge after deleting it but not
deleting the local database, you should expect errors, as the bridge
will have been removed from Matrix rooms that it thinks it is a member
of.



================================================
FILE: build.sh
================================================
#!/bin/sh
go build -ldflags "-X main.Tag=$(git describe --exact-match --tags 2>/dev/null) -X main.Commit=$(git rev-parse HEAD) -X 'main.BuildTime=`date -Iseconds`'" "$@" github.com/beeper/bridge-manager/cmd/bbctl



================================================
FILE: CHANGELOG.md
================================================
# v0.13.0 (2024-12-15)

* Added support for Bluesky DM bridge.
* Updated WhatsApp and Twitter bridge configs to v2.
* Switched Python bridges to be installed from PyPI instead of GitHub.

# v0.12.2 (2024-08-26)

* Added support for Google Voice bridge.
* Fixed running Meta bridge without specifying platform.

# v0.12.1 (2024-08-17)

* Bumped minimum Go version to 1.22.
* Removed separate v2 versions of Signal and Slack. The normal bridges default to v2 now.
* Switched Google Messages and Meta to v2.

# v0.12.0 (2024-07-12)

* Added support for generating generic bridgev2/megabridge configs.
* Added support for signalv2 and slackv2.
* Updated hungryserv URL template to work with megahungry.

# v0.11.0 (2024-04-17)

* Fixed mautrix-imessage media viewer config.
* Updated main branch name for mautrix-whatsapp.
* Updated Meta config to allow choosing messenger and facebook-tor modes.
* Dropped support for legacy Facebook and Instagram bridges.
* Removed "Work in progress" warning from iMessage BlueBubbles connector.

# v0.10.1 (2024-02-28)

* Bumped minimum Go version to 1.21.
* Updated Meta and Signal bridge configs.

# v0.10.0 (2024-02-17)

* Added option to configure the device name that bridges expose to the remote
  network using `--param device_name="..."`
* Added support for new Meta bridge (Instagram/Facebook).
* Added support for the new BlueBubbles connector on the old iMessage bridge.
* Enabled Matrix spaces by default in all bridges that support them.
* Changed all bridge configs to set room name/avatar explicitly in DM rooms.
* Fixed quoting issue in Signal bridge config template.

# v0.9.1 (2023-12-21)

* Added support for new iMessage bridge.
* Fixed `bbctl run`ning bridges with websocket proxy on macOS.
* Updated bridge downloader to pull from main mautrix/signal repo instead of
  the signalgo fork.

# v0.9.0 (2023-12-15)

* Added support for the LinkedIn bridge.
* Added `--compile` flag to `bbctl run` for automatically cloning the bridge
  repo and compiling it locally.
  * This is meant for architectures which the CI does not build binaries for,
    `--local-dev` is better for actually modifying the bridge code.
* Marked `darwin/amd64` as unsupported for downloading bridge CI binaries.
* Fixed downloading Signal bridge binaries from CI.
* Fixed CI binary downloading not checking HTTP status code and trying to
  execute HTML error pages instead.

# v0.8.0 (2023-11-03)

* Added `--local-dev` flag to `bbctl run` for running a local git cloned bridge,
  instead of downloading a CI binary or using pip install.
* Added config template for the new Signal bridge written in Go.
* Switched bridges to use `as_token` double puppeting (the new method mentioned
  in [the docs](https://docs.mau.fi/bridges/general/double-puppeting.html#appservice-method-new)).
* Fixed bugs in Slack and Google Messages config templates.

# v0.7.1 (2023-08-26)

* Updated to use new hungryserv URL field in whoami response.
* Stopped using `setpgid` when running bridges on macOS as it causes weird issues.
* Changed docker image to create `DATA_DIR` if it doesn't exist instead of failing.

# v0.7.0 (2023-08-20)

* Added support for running official Python bridges (`telegram`, `facebook`,
  `instagram`, `googlechat`, `twitter`) and the remaining Go bridge (`slack`).
  * The legacy Signal bridge will not be supported as it requires signald as an
    external component. Once the Go rewrite is ready, a config template will be
    added for it.
* Added `bbctl proxy` command for connecting to the appservice transaction
  websocket and proxying all transactions to a local HTTP server. This enables
  using any 3rd party bridge in websocket mode (removing the need for
  port-forwarding).
* Added [experimental Docker image] for wrapping `bbctl run`.
* Updated minimum Go version to 1.20 when compiling bbctl from source.

[experimental Docker image]: https://github.com/beeper/bridge-manager/tree/main/docker

# v0.6.1 (2023-08-06)

* Added config option to store bridge databases in custom directory.
* Fixed running official Go bridges on macOS when libolm isn't installed
  system-wide.
* Fixed 30 second timeout when downloading bridge binaries.
* Fixed creating config directory if it doesn't exist.
* Changed default config path from `~/.config/bbctl.json`
  to `~/.config/bbctl/config.json`.
  * Existing configs should be moved automatically on startup.

# v0.6.0 (2023-08-01)

* Added support for fully managed installation of supported official bridges
  using `bbctl run`.
* Moved `register` and `delete` commands to top level `bbctl` instead of being
  nested inside `bbctl bridge`.
* Merged `bbctl get` into `bbctl register --get`

# v0.5.0 (2023-07-24)

* Added bridge config template for Google Messages.
* Added bridge type in bridge state info when setting up bridges with config
  templates.
  * This is preparation for integrating self-hosted official bridges into the
    Beeper apps, like login via the Chat Networks dialog and Start New Chat
    functionality.
* Fixed typo in WhatsApp config template.
* Updated config templates to enable websocket pinging so the websockets would
  stay alive.
* Moved `isSelfHosted` flag to top-level bridge state info.

# v0.4.0 (2023-07-04)

* Added email login support.
* Added link to bridge installation instructions after generating config file.
* Fixed WhatsApp and Discord bridge config templates.

# v0.3.1 (2023-06-27)

* Fixed logging in, which broke in v0.3.0

# v0.3.0 (2023-06-22)

* Fixed hungryserv address being incorrect for users on new bridge cluster.
* Added support for generating configs for the Discord bridge.
* Added option to pass config generation parameters as CLI flags
  (like `imessage_platform` and `barcelona_path`).

# v0.2.0 (2023-05-28)

* Added experimental support for generating configs for official Beeper bridges.
  WhatsApp, iMessage and Heisenbridge are currently supported, more to come in
  the future.
* Changed register commands to recommend starting bridge names with `sh-` prefix.

# v0.1.1 (2023-02-07)

* Fixed registering bridges in websocket mode.
* Fixed validating bridge names client-side to have a prettier error message.

# v0.1.0 (2023-02-06)

Initial release



================================================
FILE: ci-build-all.sh
================================================
#!/bin/sh
GOOS=linux GOARCH=amd64 ./build.sh -o bbctl-linux-amd64
GOOS=linux GOARCH=arm64 ./build.sh -o bbctl-linux-arm64
GOOS=darwin GOARCH=amd64 ./build.sh -o bbctl-macos-amd64
GOOS=darwin GOARCH=arm64 ./build.sh -o bbctl-macos-arm64



================================================
FILE: go.mod
================================================
module github.com/beeper/bridge-manager

go 1.24.0

toolchain go1.25.0

require (
	github.com/AlecAivazis/survey/v2 v2.3.7
	github.com/fatih/color v1.18.0
	github.com/mitchellh/colorstring v0.0.0-20190213212951-d06e56a500db
	github.com/rs/zerolog v1.34.0
	github.com/schollz/progressbar/v3 v3.18.0
	github.com/tidwall/gjson v1.18.0
	github.com/urfave/cli/v2 v2.27.7
	go.mau.fi/util v0.9.0
	golang.org/x/exp v0.0.0-20250819193227-8b4c13bb791b
	maunium.net/go/mautrix v0.25.0
)

require (
	filippo.io/edwards25519 v1.1.0 // indirect
	github.com/coder/websocket v1.8.13 // indirect
	github.com/cpuguy83/go-md2man/v2 v2.0.7 // indirect
	github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51 // indirect
	github.com/mattn/go-colorable v0.1.14 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b // indirect
	github.com/rivo/uniseg v0.4.7 // indirect
	github.com/russross/blackfriday/v2 v2.1.0 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.1 // indirect
	github.com/tidwall/sjson v1.2.5 // indirect
	github.com/xrash/smetrics v0.0.0-20240521201337-686a1a2994c1 // indirect
	golang.org/x/crypto v0.41.0 // indirect
	golang.org/x/net v0.43.0 // indirect
	golang.org/x/sys v0.35.0 // indirect
	golang.org/x/term v0.34.0 // indirect
	golang.org/x/text v0.28.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)



================================================
FILE: go.sum
================================================
filippo.io/edwards25519 v1.1.0 h1:FNf4tywRC1HmFuKW5xopWpigGjJKiJSV0Cqo0cJWDaA=
filippo.io/edwards25519 v1.1.0/go.mod h1:BxyFTGdWcka3PhytdK4V28tE5sGfRvvvRV7EaN4VDT4=
github.com/AlecAivazis/survey/v2 v2.3.7 h1:6I/u8FvytdGsgonrYsVn2t8t4QiRnh6QSTqkkhIiSjQ=
github.com/AlecAivazis/survey/v2 v2.3.7/go.mod h1:xUTIdE4KCOIjsBAE1JYsUPoCqYdZ1reCfTwbto0Fduo=
github.com/Netflix/go-expect v0.0.0-20220104043353-73e0943537d2 h1:+vx7roKuyA63nhn5WAunQHLTznkw5W8b1Xc0dNjp83s=
github.com/Netflix/go-expect v0.0.0-20220104043353-73e0943537d2/go.mod h1:HBCaDeC1lPdgDeDbhX8XFpy1jqjK0IBG8W5K+xYqA0w=
github.com/chengxilo/virtualterm v1.0.4 h1:Z6IpERbRVlfB8WkOmtbHiDbBANU7cimRIof7mk9/PwM=
github.com/chengxilo/virtualterm v1.0.4/go.mod h1:DyxxBZz/x1iqJjFxTFcr6/x+jSpqN0iwWCOK1q10rlY=
github.com/coder/websocket v1.8.13 h1:f3QZdXy7uGVz+4uCJy2nTZyM0yTBj8yANEHhqlXZ9FE=
github.com/coder/websocket v1.8.13/go.mod h1:LNVeNrXQZfe5qhS9ALED3uA+l5pPqvwXg3CKoDBB2gs=
github.com/coreos/go-systemd/v22 v22.5.0/go.mod h1:Y58oyj3AT4RCenI/lSvhwexgC+NSVTIJ3seZv2GcEnc=
github.com/cpuguy83/go-md2man/v2 v2.0.7 h1:zbFlGlXEAKlwXpmvle3d8Oe3YnkKIK4xSRTd3sHPnBo=
github.com/cpuguy83/go-md2man/v2 v2.0.7/go.mod h1:oOW0eioCTA6cOiMLiUPZOpcVxMig6NIQQ7OS05n1F4g=
github.com/creack/pty v1.1.17 h1:QeVUsEDNrLBW4tMgZHvxy18sKtr6VI492kBhUfhDJNI=
github.com/creack/pty v1.1.17/go.mod h1:MOBLtS5ELjhRRrroQr9kyvTxUAFNvYEK993ew/Vr4O4=
github.com/davecgh/go-spew v1.1.0/go.mod h1:J7Y8YcW2NihsgmVo/mv3lAwl/skON4iLHjSsI+c5H38=
github.com/davecgh/go-spew v1.1.1 h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=
github.com/davecgh/go-spew v1.1.1/go.mod h1:J7Y8YcW2NihsgmVo/mv3lAwl/skON4iLHjSsI+c5H38=
github.com/fatih/color v1.18.0 h1:S8gINlzdQ840/4pfAwic/ZE0djQEH3wM94VfqLTZcOM=
github.com/fatih/color v1.18.0/go.mod h1:4FelSpRwEGDpQ12mAdzqdOukCy4u8WUtOY6lkT/6HfU=
github.com/godbus/dbus/v5 v5.0.4/go.mod h1:xhWf0FNVPg57R7Z0UbKHbJfkEywrmjJnf7w5xrFpKfA=
github.com/hinshun/vt10x v0.0.0-20220119200601-820417d04eec h1:qv2VnGeEQHchGaZ/u7lxST/RaJw+cv273q79D81Xbog=
github.com/hinshun/vt10x v0.0.0-20220119200601-820417d04eec/go.mod h1:Q48J4R4DvxnHolD5P8pOtXigYlRuPLGl6moFx3ulM68=
github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51 h1:Z9n2FFNUXsshfwJMBgNA0RU6/i7WVaAegv3PtuIHPMs=
github.com/kballard/go-shellquote v0.0.0-20180428030007-95032a82bc51/go.mod h1:CzGEWj7cYgsdH8dAjBGEr58BoE7ScuLd+fwFZ44+/x8=
github.com/mattn/go-colorable v0.1.2/go.mod h1:U0ppj6V5qS13XJ6of8GYAs25YV2eR4EVcfRqFIhoBtE=
github.com/mattn/go-colorable v0.1.13/go.mod h1:7S9/ev0klgBDR4GtXTXX8a3vIGJpMovkB8vQcUbaXHg=
github.com/mattn/go-colorable v0.1.14 h1:9A9LHSqF/7dyVVX6g0U9cwm9pG3kP9gSzcuIPHPsaIE=
github.com/mattn/go-colorable v0.1.14/go.mod h1:6LmQG8QLFO4G5z1gPvYEzlUgJ2wF+stgPZH1UqBm1s8=
github.com/mattn/go-isatty v0.0.8/go.mod h1:Iq45c/XA43vh69/j3iqttzPXn0bhXyGjM0Hdxcsrc5s=
github.com/mattn/go-isatty v0.0.16/go.mod h1:kYGgaQfpe5nmfYZH+SKPsOc2e4SrIfOl2e/yFXSvRLM=
github.com/mattn/go-isatty v0.0.19/go.mod h1:W+V8PltTTMOvKvAeJH7IuucS94S2C6jfK/D7dTCTo3Y=
github.com/mattn/go-isatty v0.0.20 h1:xfD0iDuEKnDkl03q4limB+vH+GxLEtL/jb4xVJSWWEY=
github.com/mattn/go-isatty v0.0.20/go.mod h1:W+V8PltTTMOvKvAeJH7IuucS94S2C6jfK/D7dTCTo3Y=
github.com/mattn/go-runewidth v0.0.16 h1:E5ScNMtiwvlvB5paMFdw9p4kSQzbXFikJ5SQO6TULQc=
github.com/mattn/go-runewidth v0.0.16/go.mod h1:Jdepj2loyihRzMpdS35Xk/zdY8IAYHsh153qUoGf23w=
github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b h1:j7+1HpAFS1zy5+Q4qx1fWh90gTKwiN4QCGoY9TWyyO4=
github.com/mgutz/ansi v0.0.0-20170206155736-9520e82c474b/go.mod h1:01TrycV0kFyexm33Z7vhZRXopbI8J3TDReVlkTgMUxE=
github.com/mitchellh/colorstring v0.0.0-20190213212951-d06e56a500db h1:62I3jR2EmQ4l5rM/4FEfDWcRD+abF5XlKShorW5LRoQ=
github.com/mitchellh/colorstring v0.0.0-20190213212951-d06e56a500db/go.mod h1:l0dey0ia/Uv7NcFFVbCLtqEBQbrT4OCwCSKTEv6enCw=
github.com/pkg/errors v0.9.1/go.mod h1:bwawxfHBFNV+L2hUp1rHADufV3IMtnDRdf1r5NINEl0=
github.com/pmezard/go-difflib v1.0.0 h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=
github.com/pmezard/go-difflib v1.0.0/go.mod h1:iKH77koFhYxTK1pcRnkKkqfTogsbg7gZNVY4sRDYZ/4=
github.com/rivo/uniseg v0.4.7 h1:WUdvkW8uEhrYfLC4ZzdpI2ztxP1I582+49Oc5Mq64VQ=
github.com/rivo/uniseg v0.4.7/go.mod h1:FN3SvrM+Zdj16jyLfmOkMNblXMcoc8DfTHruCPUcx88=
github.com/rs/xid v1.6.0/go.mod h1:7XoLgs4eV+QndskICGsho+ADou8ySMSjJKDIan90Nz0=
github.com/rs/zerolog v1.34.0 h1:k43nTLIwcTVQAncfCw4KZ2VY6ukYoZaBPNOE8txlOeY=
github.com/rs/zerolog v1.34.0/go.mod h1:bJsvje4Z08ROH4Nhs5iH600c3IkWhwp44iRc54W6wYQ=
github.com/russross/blackfriday/v2 v2.1.0 h1:JIOH55/0cWyOuilr9/qlrm0BSXldqnqwMsf35Ld67mk=
github.com/russross/blackfriday/v2 v2.1.0/go.mod h1:+Rmxgy9KzJVeS9/2gXHxylqXiyQDYRxCVz55jmeOWTM=
github.com/schollz/progressbar/v3 v3.18.0 h1:uXdoHABRFmNIjUfte/Ex7WtuyVslrw2wVPQmCN62HpA=
github.com/schollz/progressbar/v3 v3.18.0/go.mod h1:IsO3lpbaGuzh8zIMzgY3+J8l4C8GjO0Y9S69eFvNsec=
github.com/stretchr/objx v0.1.0/go.mod h1:HFkY916IF+rwdDfMAkV7OtwuqBVzrE8GR6GFx+wExME=
github.com/stretchr/testify v1.6.1/go.mod h1:6Fq8oRcR53rry900zMqJjRRixrwX3KX962/h/Wwjteg=
github.com/stretchr/testify v1.10.0 h1:Xv5erBjTwe/5IxqUQTdXv5kgmIvbHo3QQyRwhJsOfJA=
github.com/stretchr/testify v1.10.0/go.mod h1:r2ic/lqez/lEtzL7wO/rwa5dbSLXVDPFyf8C91i36aY=
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
github.com/urfave/cli/v2 v2.27.7 h1:bH59vdhbjLv3LAvIu6gd0usJHgoTTPhCFib8qqOwXYU=
github.com/urfave/cli/v2 v2.27.7/go.mod h1:CyNAG/xg+iAOg0N4MPGZqVmv2rCoP267496AOXUZjA4=
github.com/xrash/smetrics v0.0.0-20240521201337-686a1a2994c1 h1:gEOO8jv9F4OT7lGCjxCBTO/36wtF6j2nSip77qHd4x4=
github.com/xrash/smetrics v0.0.0-20240521201337-686a1a2994c1/go.mod h1:Ohn+xnUBiLI6FVj/9LpzZWtj1/D6lUovWYBkxHVV3aM=
github.com/yuin/goldmark v1.4.13/go.mod h1:6yULJ656Px+3vBD8DxQVa3kxgyrAnzto9xy5taEt/CY=
go.mau.fi/util v0.9.0 h1:ya3s3pX+Y8R2fgp0DbE7a0o3FwncoelDX5iyaeVE8ls=
go.mau.fi/util v0.9.0/go.mod h1:pdL3lg2aaeeHIreGXNnPwhJPXkXdc3ZxsI6le8hOWEA=
golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod h1:djNgcEr1/C05ACkg1iLfiJU5Ep61QUkGW8qpdssI0+w=
golang.org/x/crypto v0.0.0-20210921155107-089bfa567519/go.mod h1:GvvjBRRGRdwPK5ydBHafDWAxML/pGHZbMvKqRZ5+Abc=
golang.org/x/crypto v0.41.0 h1:WKYxWedPGCTVVl5+WHSSrOBT0O8lx32+zxmHxijgXp4=
golang.org/x/crypto v0.41.0/go.mod h1:pO5AFd7FA68rFak7rOAGVuygIISepHftHnr8dr6+sUc=
golang.org/x/exp v0.0.0-20250819193227-8b4c13bb791b h1:DXr+pvt3nC887026GRP39Ej11UATqWDmWuS99x26cD0=
golang.org/x/exp v0.0.0-20250819193227-8b4c13bb791b/go.mod h1:4QTo5u+SEIbbKW1RacMZq1YEfOBqeXa19JeshGi+zc4=
golang.org/x/mod v0.6.0-dev.0.20220419223038-86c51ed26bb4/go.mod h1:jJ57K6gSWd91VN4djpZkiMVwK6gcyfeH4XE8wZrZaV4=
golang.org/x/net v0.0.0-20190620200207-3b0461eec859/go.mod h1:z5CRVTTTmAJ677TzLLGU+0bjPO0LkuOLi4/5GtJWs/s=
golang.org/x/net v0.0.0-20210226172049-e18ecbb05110/go.mod h1:m0MpNAwzfU5UDzcl9v0D8zg8gWTRqZa9RBIspLL5mdg=
golang.org/x/net v0.0.0-20220722155237-a158d28d115b/go.mod h1:XRhObCWvk6IyKnWLug+ECip1KBveYUHfp+8e9klMJ9c=
golang.org/x/net v0.43.0 h1:lat02VYK2j4aLzMzecihNvTlJNQUq316m2Mr9rnM6YE=
golang.org/x/net v0.43.0/go.mod h1:vhO1fvI4dGsIjh73sWfUVjj3N7CA9WkKJNQm2svM6Jg=
golang.org/x/sync v0.0.0-20190423024810-112230192c58/go.mod h1:RxMgew5VJxzue5/jJTE5uejpjVlOe/izrB70Jof72aM=
golang.org/x/sync v0.0.0-20220722155255-886fb9371eb4/go.mod h1:RxMgew5VJxzue5/jJTE5uejpjVlOe/izrB70Jof72aM=
golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod h1:STP8DvDyc/dI5b8T5hshtkjS+E42TnysNCUPdjciGhY=
golang.org/x/sys v0.0.0-20190222072716-a9d3bda3a223/go.mod h1:STP8DvDyc/dI5b8T5hshtkjS+E42TnysNCUPdjciGhY=
golang.org/x/sys v0.0.0-20201119102817-f84b799fce68/go.mod h1:h1NjWce9XRLGQEsW7wpKNCjG9DtNlClVuFLEZdDNbEs=
golang.org/x/sys v0.0.0-20210615035016-665e8c7367d1/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.0.0-20220520151302-bc2c85ada10a/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.0.0-20220722155257-8c9f86f7a55f/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.0.0-20220811171246-fbc7d0a398ab/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.6.0/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.12.0/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
golang.org/x/sys v0.35.0 h1:vz1N37gP5bs89s7He8XuIYXpyY0+QlsKmzipCbUtyxI=
golang.org/x/sys v0.35.0/go.mod h1:BJP2sWEmIv4KK5OTEluFJCKSidICx8ciO85XgH3Ak8k=
golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod h1:bj7SfCRtBDWHUb9snDiAeCFNEtKQo2Wmx5Cou7ajbmo=
golang.org/x/term v0.0.0-20210927222741-03fcf44c2211/go.mod h1:jbD1KX2456YbFQfuXm/mYQcufACuNUgVhRMnK/tPxf8=
golang.org/x/term v0.34.0 h1:O/2T7POpk0ZZ7MAzMeWFSg6S5IpWd/RXDlM9hgM3DR4=
golang.org/x/term v0.34.0/go.mod h1:5jC53AEywhIVebHgPVeg0mj8OD3VO9OzclacVrqpaAw=
golang.org/x/text v0.3.0/go.mod h1:NqM8EUOU14njkJ3fqMW+pc6Ldnwhi/IjpwHt7yyuwOQ=
golang.org/x/text v0.3.3/go.mod h1:5Zoc/QRtKVWzQhOtBMvqHzDpF6irO9z98xDceosuGiQ=
golang.org/x/text v0.3.7/go.mod h1:u+2+/6zg+i71rQMx5EYifcz6MCKuco9NR6JIITiCfzQ=
golang.org/x/text v0.4.0/go.mod h1:mrYo+phRRbMaCq/xk9113O4dZlRixOauAjOtrjsXDZ8=
golang.org/x/text v0.28.0 h1:rhazDwis8INMIwQ4tpjLDzUhx6RlXqZNPEM0huQojng=
golang.org/x/text v0.28.0/go.mod h1:U8nCwOR8jO/marOQ0QbDiOngZVEBB7MAiitBuMjXiNU=
golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod h1:n7NCudcB/nEzxVGmLbDWY5pfWTLqBcC2KZ6jyYvM4mQ=
golang.org/x/tools v0.0.0-20191119224855-298f0cb1881e/go.mod h1:b+2E5dAYhXwXZwtnZ6UAqBI28+e2cm9otk0dWdXHAEo=
golang.org/x/tools v0.1.12/go.mod h1:hNGJHUnrk76NpqgfD5Aqm5Crs+Hm0VOH/i9J2+nxYbc=
golang.org/x/xerrors v0.0.0-20190717185122-a985d3407aa7/go.mod h1:I/5z698sn9Ka8TeJc9MKroUUfqBBauWjQqLJ2OPfmY0=
gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405 h1:yhCVgyC4o1eVCa2tZl7eS0r+SDo693bJlVdllGtEeKM=
gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405/go.mod h1:Co6ibVJAznAaIkqp8huTwlJQCZ016jof/cbN4VW5Yz0=
gopkg.in/yaml.v3 v3.0.0-20200313102051-9f266ea9e77c/go.mod h1:K4uyk7z7BCEPqu6E+C64Yfv1cQ7kz7rIZviUmN+EgEM=
gopkg.in/yaml.v3 v3.0.1 h1:fxVm/GzAzEWqLHuvctI91KS9hhNmmWOoWu0XTYJS7CA=
gopkg.in/yaml.v3 v3.0.1/go.mod h1:K4uyk7z7BCEPqu6E+C64Yfv1cQ7kz7rIZviUmN+EgEM=
maunium.net/go/mautrix v0.25.0 h1:dhYoXIXSxI9A+kEPwBceuRP0wcpho15dVLucUF8k2eE=
maunium.net/go/mautrix v0.25.0/go.mod h1:pDd6Ppg+1PbWrw/rg4ZQQfVYZICRGzH+DcliZ/BODvU=



================================================
FILE: LICENSE
================================================

                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS



================================================
FILE: run.sh
================================================
#!/bin/sh
go run -ldflags "-X main.Tag=$(git describe --exact-match --tags 2>/dev/null) -X main.Commit=$(git rev-parse HEAD) -X 'main.BuildTime=`date -Iseconds`'" github.com/beeper/bridge-manager/cmd/bbctl "$@"



================================================
FILE: .dockerignore
================================================
docker/Dockerfile
docker/README.md
ci-build-all.sh
run.sh
LICENSE
README.md
.editorconfig
.pre-commit-config.yaml



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

[*.yaml]
indent_style = space

[{.pre-commit-config.yaml,.github/workflows/*.yaml}]
indent_size = 2



================================================
FILE: .pre-commit-config.yaml
================================================
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
        exclude_types: [markdown]
      - id: end-of-file-fixer
      - id: check-yaml
        exclude: ^.+\.tpl\.yaml$
      - id: check-added-large-files

  - repo: https://github.com/tekwizely/pre-commit-golang
    rev: v1.0.0-rc.1
    hooks:
      - id: go-imports-repo
        args:
          - "-local"
          - "github.com/beeper/bridge-manager"
          - "-w"
      - id: go-vet-repo-mod
      - id: go-staticcheck-repo-mod



================================================
FILE: api/beeperapi/login.go
================================================
package beeperapi

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"time"
)

type RespStartLogin struct {
	RequestID string    `json:"request"`
	Type      []string  `json:"type"`
	Expires   time.Time `json:"expires"`
}

type ReqSendLoginEmail struct {
	RequestID string `json:"request"`
	Email     string `json:"email"`
}

type ReqSendLoginCode struct {
	RequestID string `json:"request"`
	Code      string `json:"response"`
}

type RespSendLoginCode struct {
	LoginToken string      `json:"token"`
	Whoami     *RespWhoami `json:"whoami"`
}

var ErrInvalidLoginCode = fmt.Errorf("invalid login code")

const loginAuth = "BEEPER-PRIVATE-API-PLEASE-DONT-USE"

func StartLogin(baseDomain string) (resp *RespStartLogin, err error) {
	req := newRequest(baseDomain, loginAuth, http.MethodPost, "/user/login")
	req.Body = io.NopCloser(bytes.NewReader([]byte("{}")))
	err = doRequest(req, nil, &resp)
	return
}

func SendLoginEmail(baseDomain, request, email string) error {
	req := newRequest(baseDomain, loginAuth, http.MethodPost, "/user/login/email")
	reqData := &ReqSendLoginEmail{
		RequestID: request,
		Email:     email,
	}
	return doRequest(req, reqData, nil)
}

func SendLoginCode(baseDomain, request, code string) (resp *RespSendLoginCode, err error) {
	req := newRequest(baseDomain, loginAuth, http.MethodPost, "/user/login/response")
	reqData := &ReqSendLoginCode{
		RequestID: request,
		Code:      code,
	}
	err = doRequest(req, reqData, &resp)
	return
}



================================================
FILE: api/beeperapi/whoami.go
================================================
package beeperapi

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"maunium.net/go/mautrix"
	"maunium.net/go/mautrix/bridgev2/status"
	"maunium.net/go/mautrix/id"
)

type BridgeState struct {
	Username     string                  `json:"username"`
	Bridge       string                  `json:"bridge"`
	StateEvent   status.BridgeStateEvent `json:"stateEvent"`
	Source       string                  `json:"source"`
	CreatedAt    time.Time               `json:"createdAt"`
	Reason       string                  `json:"reason"`
	Info         map[string]any          `json:"info"`
	IsSelfHosted bool                    `json:"isSelfHosted"`
	BridgeType   string                  `json:"bridgeType"`
}

type WhoamiBridge struct {
	Version       string `json:"version"`
	ConfigHash    string `json:"configHash"`
	OtherVersions []struct {
		Name    string `json:"name"`
		Version string `json:"version"`
	} `json:"otherVersions"`
	BridgeState BridgeState                   `json:"bridgeState"`
	RemoteState map[string]status.BridgeState `json:"remoteState"`
}

type WhoamiAsmuxData struct {
	LoginToken string `json:"login_token"`
}

type WhoamiUser struct {
	Bridges    map[string]WhoamiBridge `json:"bridges"`
	Hungryserv WhoamiBridge            `json:"hungryserv"`
	AsmuxData  WhoamiAsmuxData         `json:"asmuxData"`
}

type WhoamiUserInfo struct {
	CreatedAt           time.Time `json:"createdAt"`
	Username            string    `json:"username"`
	Email               string    `json:"email"`
	FullName            string    `json:"fullName"`
	Channel             string    `json:"channel"`
	Admin               bool      `json:"isAdmin"`
	BridgeChangesLocked bool      `json:"isUserBridgeChangesLocked"`
	Free                bool      `json:"isFree"`
	DeletedAt           time.Time `json:"deletedAt"`
	SupportRoomID       id.RoomID `json:"supportRoomId"`
	UseHungryserv       bool      `json:"useHungryserv"`
	BridgeClusterID     string    `json:"bridgeClusterId"`
	AnalyticsID         string    `json:"analyticsId"`
	FakeHungryURL       string    `json:"hungryUrl"`
	HungryURL           string    `json:"hungryUrlDirect"`
}

type RespWhoami struct {
	User     WhoamiUser     `json:"user"`
	UserInfo WhoamiUserInfo `json:"userInfo"`
}

var cli = &http.Client{Timeout: 30 * time.Second}

func newRequest(baseDomain, token, method, path string) *http.Request {
	req := &http.Request{
		URL: &url.URL{
			Scheme: "https",
			Host:   fmt.Sprintf("api.%s", baseDomain),
			Path:   path,
		},
		Method: method,
		Header: http.Header{
			"Authorization": {fmt.Sprintf("Bearer %s", token)},
			"User-Agent":    {mautrix.DefaultUserAgent},
		},
	}
	if method == http.MethodPut || method == http.MethodPost {
		req.Header.Set("Content-Type", "application/json")
	}
	return req
}

func encodeContent(into *http.Request, body any) error {
	var buf bytes.Buffer
	err := json.NewEncoder(&buf).Encode(body)
	if err != nil {
		return fmt.Errorf("failed to encode request: %w", err)
	}
	into.Body = io.NopCloser(&buf)
	return nil
}

func doRequest(req *http.Request, reqData, resp any) (err error) {
	if reqData != nil {
		err = encodeContent(req, reqData)
		if err != nil {
			return
		}
	}
	r, err := cli.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer r.Body.Close()
	if r.StatusCode < 200 || r.StatusCode >= 300 {
		var body map[string]any
		_ = json.NewDecoder(r.Body).Decode(&body)
		if body != nil {
			retryCount, ok := body["retries"].(float64)
			if ok && retryCount > 0 && r.StatusCode == 403 && req.URL.Path == "/user/login/response" {
				return fmt.Errorf("%w (%d retries left)", ErrInvalidLoginCode, int(retryCount))
			}
			errorMsg, ok := body["error"].(string)
			if ok {
				return fmt.Errorf("server returned error (HTTP %d): %s", r.StatusCode, errorMsg)
			}
		}
		return fmt.Errorf("unexpected status code %d", r.StatusCode)
	}
	if resp != nil {
		err = json.NewDecoder(r.Body).Decode(resp)
		if err != nil {
			return fmt.Errorf("error decoding response: %w", err)
		}
	}
	return nil
}

type ReqPostBridgeState struct {
	StateEvent   status.BridgeStateEvent `json:"stateEvent"`
	Reason       string                  `json:"reason"`
	Info         map[string]any          `json:"info"`
	IsSelfHosted bool                    `json:"isSelfHosted"`
	BridgeType   string                  `json:"bridgeType,omitempty"`
}

func DeleteBridge(domain, bridgeName, token string) error {
	req := newRequest(domain, token, http.MethodDelete, fmt.Sprintf("/bridge/%s", bridgeName))
	return doRequest(req, nil, nil)
}

func PostBridgeState(domain, username, bridgeName, asToken string, data ReqPostBridgeState) error {
	req := newRequest(domain, asToken, http.MethodPost, fmt.Sprintf("/bridgebox/%s/bridge/%s/bridge_state", username, bridgeName))
	return doRequest(req, &data, nil)
}

func Whoami(baseDomain, token string) (resp *RespWhoami, err error) {
	req := newRequest(baseDomain, token, http.MethodGet, "/whoami")
	err = doRequest(req, nil, &resp)
	return
}



================================================
FILE: api/gitlab/build.go
================================================
package gitlab

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"runtime"

	"github.com/fatih/color"
	"github.com/schollz/progressbar/v3"
	"github.com/tidwall/gjson"

	"github.com/beeper/bridge-manager/cli/hyper"
	"github.com/beeper/bridge-manager/log"
)

// language=graphql
const getLastSuccessfulJobQuery = `
query($repo: ID!, $ref: String!, $job: String!) {
  project(fullPath: $repo) {
    pipelines(status: SUCCESS, ref: $ref, first: 1) {
      nodes {
        sha
        job(name: $job) {
          webPath
        }
      }
    }
  }
}
`

type lastSuccessfulJobQueryVariables struct {
	Repo string `json:"repo"`
	Ref  string `json:"ref"`
	Job  string `json:"job"`
}

type LastBuild struct {
	Commit string
	JobURL string
}

func GetLastBuild(domain, repo, mainBranch, job string) (*LastBuild, error) {
	resp, err := graphqlQuery(domain, getLastSuccessfulJobQuery, lastSuccessfulJobQueryVariables{
		Repo: repo,
		Ref:  mainBranch,
		Job:  job,
	})
	if err != nil {
		return nil, err
	}
	res := gjson.GetBytes(resp, "project.pipelines.nodes.0")
	if !res.Exists() {
		return nil, fmt.Errorf("didn't get pipeline info in response")
	}
	return &LastBuild{
		Commit: gjson.Get(res.Raw, "sha").Str,
		JobURL: gjson.Get(res.Raw, "job.webPath").Str,
	}, nil
}

func getRefFromBridge(bridge string) (string, error) {
	switch bridge {
	case "imessage":
		return "master", nil
	case "whatsapp", "discord", "slack", "gmessages", "gvoice", "signal",
		"imessagego", "meta", "twitter", "bluesky", "linkedin", "telegramgo":
		return "main", nil
	default:
		return "", fmt.Errorf("unknown bridge %s", bridge)
	}
}

var ErrNotBuiltInCI = errors.New("not built in the CI")

func getJobFromBridge(bridge string) (string, error) {
	osAndArch := fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH)
	switch osAndArch {
	case "linux/amd64":
		return "build amd64", nil
	case "linux/arm64":
		return "build arm64", nil
	case "linux/arm":
		if bridge == "signal" {
			return "", fmt.Errorf("mautrix-signal binaries for 32-bit arm are %w", ErrNotBuiltInCI)
		}
		return "build arm", nil
	case "darwin/arm64":
		if bridge == "imessage" {
			return "build universal", nil
		}
		return "build macos arm64", nil
	default:
		if bridge == "imessage" {
			return "build universal", nil
		}
		return "", fmt.Errorf("binaries for %s are %w", osAndArch, ErrNotBuiltInCI)
	}
}

func linkifyCommit(repo, commit string) string {
	return hyper.Link(commit[:8], fmt.Sprintf("https://github.com/%s/commit/%s", repo, commit), false)
}

func linkifyDiff(repo, fromCommit, toCommit string) string {
	formattedDiff := fmt.Sprintf("%s...%s", fromCommit[:8], toCommit[:8])
	return hyper.Link(formattedDiff, fmt.Sprintf("https://github.com/%s/compare/%s...%s", repo, fromCommit, toCommit), false)
}

func makeArtifactURL(domain, jobURL, fileName string) string {
	return (&url.URL{
		Scheme: "https",
		Host:   domain,
		Path:   filepath.Join(jobURL, "artifacts", "raw", fileName),
	}).String()
}

func downloadFile(ctx context.Context, artifactURL, path string) error {
	fileName := filepath.Base(path)
	file, err := os.CreateTemp(filepath.Dir(path), "tmp-"+fileName+"-*")
	if err != nil {
		return fmt.Errorf("failed to open temp file: %w", err)
	}
	defer func() {
		_ = file.Close()
		_ = os.Remove(file.Name())
	}()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, artifactURL, nil)
	if err != nil {
		return fmt.Errorf("failed to prepare download request: %w", err)
	}
	resp, err := noTimeoutCli.Do(req)
	if err != nil {
		return fmt.Errorf("failed to download artifact: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to download artifact: unexpected response status %d", resp.StatusCode)
	}
	bar := progressbar.DefaultBytes(
		resp.ContentLength,
		fmt.Sprintf("Downloading %s", color.CyanString(fileName)),
	)
	_, err = io.Copy(io.MultiWriter(file, bar), resp.Body)
	if err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}
	_ = file.Close()
	err = os.Rename(file.Name(), path)
	if err != nil {
		return fmt.Errorf("failed to move temp file: %w", err)
	}
	err = os.Chmod(path, 0755)
	if err != nil {
		return fmt.Errorf("failed to chmod binary: %w", err)
	}
	return nil
}

func needsLibolmDylib(bridge string) bool {
	switch bridge {
	case "imessage", "whatsapp", "discord", "slack", "gmessages", "gvoice", "signal",
		"imessagego", "meta", "twitter", "bluesky", "linkedin", "telegram":
		return runtime.GOOS == "darwin"
	default:
		return false
	}
}

func DownloadMautrixBridgeBinary(ctx context.Context, bridge, path string, v2, noUpdate bool, branchOverride, currentCommit string) error {
	domain := "mau.dev"
	repo := fmt.Sprintf("mautrix/%s", bridge)
	fileName := filepath.Base(path)
	ref, err := getRefFromBridge(bridge)
	if err != nil {
		return err
	}
	if branchOverride != "" {
		ref = branchOverride
	}
	job, err := getJobFromBridge(bridge)
	if err != nil {
		return err
	}
	if v2 {
		job += " v2"
	}

	if currentCommit == "" {
		log.Printf("Finding latest version of [cyan]%s[reset] from [cyan]%s[reset]", fileName, domain)
	} else {
		log.Printf("Checking for updates to [cyan]%s[reset] from [cyan]%s[reset]", fileName, domain)
	}
	build, err := GetLastBuild(domain, repo, ref, job)
	if err != nil {
		return fmt.Errorf("failed to get last build info: %w", err)
	}
	if build.Commit == currentCommit {
		log.Printf("[cyan]%s[reset] is up to date (commit: %s)", fileName, linkifyCommit(repo, currentCommit))
		return nil
	} else if currentCommit != "" && noUpdate {
		log.Printf("[cyan]%s[reset] [yellow]is out of date, latest commit is %s (diff: %s)[reset]", fileName, linkifyCommit(repo, build.Commit), linkifyDiff(repo, currentCommit, build.Commit))
		return nil
	} else if build.JobURL == "" {
		return fmt.Errorf("failed to find URL for job %q on branch %s of %s", job, ref, repo)
	}
	if currentCommit == "" {
		log.Printf("Installing [cyan]%s[reset] (commit: %s)", fileName, linkifyCommit(repo, build.Commit))
	} else {
		log.Printf("Updating [cyan]%s[reset] (diff: %s)", fileName, linkifyDiff(repo, currentCommit, build.Commit))
	}
	artifactURL := makeArtifactURL(domain, build.JobURL, fileName)
	err = downloadFile(ctx, artifactURL, path)
	if err != nil {
		return err
	}
	if needsLibolmDylib(bridge) {
		libolmPath := filepath.Join(filepath.Dir(path), "libolm.3.dylib")
		// TODO redownload libolm if it's outdated?
		if _, err = os.Stat(libolmPath); err != nil {
			err = downloadFile(ctx, makeArtifactURL(domain, build.JobURL, "libolm.3.dylib"), libolmPath)
			if err != nil {
				return fmt.Errorf("failed to download libolm: %w", err)
			}
		}
	}

	log.Printf("Successfully installed [cyan]%s[reset] commit %s", fileName, linkifyCommit(repo, build.Commit))
	return nil
}



================================================
FILE: api/gitlab/graphql.go
================================================
package gitlab

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"maunium.net/go/mautrix"
)

var noTimeoutCli = &http.Client{}
var cli = &http.Client{Timeout: 30 * time.Second}

type queryRequestBody struct {
	Query     string `json:"query"`
	Variables any    `json:"variables"`
}

type QueryErrorLocation struct {
	Line   int `json:"line"`
	Column int `json:"column"`
}

type QueryErrorItem struct {
	Message   string               `json:"message"`
	Locations []QueryErrorLocation `json:"locations"`
}

type QueryError []QueryErrorItem

func (qe QueryError) Error() string {
	if len(qe) == 1 {
		return qe[0].Message
	}
	plural := "s"
	if len(qe) == 2 {
		plural = ""
	}
	return fmt.Sprintf("%s (and %d other error%s)", qe[0].Message, len(qe)-1, plural)
}

type queryResponse struct {
	Data   json.RawMessage `json:"data"`
	Errors QueryError      `json:"errors"`
}

func graphqlQuery(domain, query string, args any) (json.RawMessage, error) {
	req := &http.Request{
		URL: &url.URL{
			Scheme: "https",
			Host:   domain,
			Path:   "/api/graphql",
		},
		Method: http.MethodPost,
		Header: http.Header{
			"User-Agent":   {mautrix.DefaultUserAgent},
			"Content-Type": {"application/json"},
			"Accept":       {"application/json"},
		},
	}
	var buf bytes.Buffer
	err := json.NewEncoder(&buf).Encode(queryRequestBody{
		Query:     query,
		Variables: args,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to encode request body: %w", err)
	}
	req.Body = io.NopCloser(&buf)
	resp, err := cli.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()
	var respData queryResponse
	err = json.NewDecoder(resp.Body).Decode(&respData)
	if err != nil {
		return nil, fmt.Errorf("failed to decode response body: %w", err)
	}
	if len(respData.Errors) > 0 {
		return nil, respData.Errors
	}
	return respData.Data, nil
}



================================================
FILE: api/hungryapi/appservice.go
================================================
package hungryapi

import (
	"context"
	"net/http"
	"net/url"
	"time"

	"go.mau.fi/util/jsontime"
	"maunium.net/go/mautrix"
	"maunium.net/go/mautrix/appservice"
	"maunium.net/go/mautrix/id"
)

type Client struct {
	*mautrix.Client
	Username string
}

func NewClient(baseDomain, username, accessToken string) *Client {
	hungryURL := url.URL{
		Scheme: "https",
		Host:   "matrix." + baseDomain,
		Path:   "/_hungryserv/" + username,
	}
	client, err := mautrix.NewClient(hungryURL.String(), id.NewUserID(username, baseDomain), accessToken)
	if err != nil {
		panic(err)
	}
	return &Client{Client: client, Username: username}
}

type ReqRegisterAppService struct {
	Address    string `json:"address,omitempty"`
	Push       bool   `json:"push"`
	SelfHosted bool   `json:"self_hosted"`
}

func (cli *Client) RegisterAppService(
	ctx context.Context,
	bridge string,
	req ReqRegisterAppService,
) (resp appservice.Registration, err error) {
	url := cli.BuildURL(mautrix.BaseURLPath{"_matrix", "asmux", "mxauth", "appservice", cli.Username, bridge})
	_, err = cli.MakeRequest(ctx, http.MethodPut, url, &req, &resp)
	return
}

func (cli *Client) GetAppService(ctx context.Context, bridge string) (resp appservice.Registration, err error) {
	url := cli.BuildURL(mautrix.BaseURLPath{"_matrix", "asmux", "mxauth", "appservice", cli.Username, bridge})
	_, err = cli.MakeRequest(ctx, http.MethodGet, url, nil, &resp)
	return
}

func (cli *Client) DeleteAppService(ctx context.Context, bridge string) (err error) {
	url := cli.BuildURL(mautrix.BaseURLPath{"_matrix", "asmux", "mxauth", "appservice", cli.Username, bridge})
	_, err = cli.MakeRequest(ctx, http.MethodDelete, url, nil, nil)
	return
}

type respGetSystemTime struct {
	Time jsontime.UnixMilli `json:"time_ms"`
}

func (cli *Client) GetServerTime(ctx context.Context) (resp time.Time, precision time.Duration, err error) {
	var respData respGetSystemTime
	start := time.Now()
	_, err = cli.MakeFullRequest(ctx, mautrix.FullRequest{
		Method:       http.MethodGet,
		URL:          cli.BuildURL(mautrix.BaseURLPath{"_matrix", "client", "unstable", "com.beeper.timesync"}),
		ResponseJSON: &respData,
		MaxAttempts:  1,
	})
	precision = time.Since(start)
	resp = respData.Time.Time
	return
}



================================================
FILE: bridgeconfig/bluesky.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for Bluesky users. Available variables:
    #   .DisplayName - displayname set by the user. Not required, may be empty.
    #   .Handle - username (domain) of the user. Always present.
    #   .DID - internal user ID starting with `did:`. Always present.
    displayname_template: {{ `"{{or .DisplayName .Handle}}"` }}

{{ setfield . "CommandPrefix" "!bsky" -}}
{{ setfield . "DatabaseFileName" "mautrix-bluesky" -}}
{{ setfield . "BridgeTypeName" "Bluesky" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/ezAjjDxhiJWGEohmhkpfeHYf" -}}
{{ setfield . "DefaultPickleKey" "go.mau.fi/mautrix-bluesky" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/bridgeconfig.go
================================================
package bridgeconfig

import (
	"embed"
	"fmt"
	"reflect"
	"strings"
	"text/template"

	"maunium.net/go/mautrix/id"
)

type BridgeV2Name struct {
	DatabaseFileName string
	CommandPrefix    string
	BridgeTypeName   string
	BridgeTypeIcon   string
	DefaultPickleKey string

	MaxInitialMessages  int
	MaxBackwardMessages int
}

type Params struct {
	HungryAddress string
	BeeperDomain  string

	Websocket  bool
	ListenAddr string
	ListenPort uint16

	AppserviceID string
	ASToken      string
	HSToken      string
	BridgeName   string
	Username     string
	UserID       id.UserID

	ProvisioningSecret string

	DatabasePrefix string

	BridgeV2Name

	Params map[string]string
}

//go:embed *.tpl.yaml
var configs embed.FS
var tpl *template.Template
var SupportedBridges []string

var tplFuncs = template.FuncMap{
	"replace": strings.ReplaceAll,
	"setfield": func(obj any, field string, value any) any {
		val := reflect.ValueOf(obj)
		for val.Kind() == reflect.Pointer {
			val = val.Elem()
		}
		val.FieldByName(field).Set(reflect.ValueOf(value))
		return ""
	},
}

func init() {
	var err error
	tpl, err = template.New("configs").Funcs(tplFuncs).ParseFS(configs, "*")
	if err != nil {
		panic(fmt.Errorf("failed to parse bridge config templates: %w", err))
	}
	for _, sub := range tpl.Templates() {
		SupportedBridges = append(SupportedBridges, strings.TrimSuffix(sub.Name(), ".tpl.yaml"))
	}
}

func templateName(bridgeName string) string {
	return fmt.Sprintf("%s.tpl.yaml", bridgeName)
}

func IsSupported(bridgeName string) bool {
	return tpl.Lookup(templateName(bridgeName)) != nil
}

func Generate(bridgeName string, params Params) (string, error) {
	var out strings.Builder
	err := tpl.ExecuteTemplate(&out, templateName(bridgeName), &params)
	return out.String(), err
}



================================================
FILE: bridgeconfig/bridgev2.tpl.yaml
================================================
# Config options that affect the central bridge module.
bridge:
    {{ if .CommandPrefix -}}
    # The prefix for commands. Only required in non-management rooms.
    command_prefix: '{{ .CommandPrefix }}'
    {{ end -}}
    # Should the bridge create a space for each login containing the rooms that account is in?
    personal_filtering_spaces: true
    # Whether the bridge should set names and avatars explicitly for DM portals.
    # This is only necessary when using clients that don't support MSC4171.
    private_chat_portal_meta: false
    # Should events be handled asynchronously within portal rooms?
    # If true, events may end up being out of order, but slow events won't block other ones.
    # This is not yet safe to use.
    async_events: false
    # Should every user have their own portals rather than sharing them?
    # By default, users who are in the same group on the remote network will be
    # in the same Matrix room bridged to that group. If this is set to true,
    # every user will get their own Matrix room instead.
    split_portals: true
    # Should the bridge resend `m.bridge` events to all portals on startup?
    resend_bridge_info: false
    # Should `m.bridge` events be sent without a state key?
    # By default, the bridge uses a unique key that won't conflict with other bridges.
    no_bridge_info_state_key: false
    # Should bridge connection status be sent to the management room as `m.notice` events?
    # These contain the same data that can be posted to an external HTTP server using homeserver -> status_endpoint.
    # Allowed values: none, errors, all
    bridge_status_notices: none
    # How long after an unknown error should the bridge attempt a full reconnect?
    # Must be at least 1 minute. The bridge will add an extra ±20% jitter to this value.
    unknown_error_auto_reconnect: null

    # Should leaving Matrix rooms be bridged as leaving groups on the remote network?
    bridge_matrix_leave: false
    # Should `m.notice` messages be bridged?
    bridge_notices: false
    # Should room tags only be synced when creating the portal? Tags mean things like favorite/pin and archive/low priority.
    # Tags currently can't be synced back to the remote network, so a continuous sync means tagging from Matrix will be undone.
    tag_only_on_create: true
    # List of tags to allow bridging. If empty, no tags will be bridged.
    only_bridge_tags: [m.favourite, m.lowpriority]
    # Should room mute status only be synced when creating the portal?
    # Like tags, mutes can't currently be synced back to the remote network.
    mute_only_on_create: true
    # Should the bridge check the db to ensure that incoming events haven't been handled before
    deduplicate_matrix_messages: false
    # Should cross-room reply metadata be bridged?
    # Most Matrix clients don't support this and servers may reject such messages too.
    cross_room_replies: true

    # What should be done to portal rooms when a user logs out or is logged out?
    # Permitted values:
    #   nothing - Do nothing, let the user stay in the portals
    #   kick - Remove the user from the portal rooms, but don't delete them
    #   unbridge - Remove all ghosts in the room and disassociate it from the remote chat
    #   delete - Remove all ghosts and users from the room (i.e. delete it)
    cleanup_on_logout:
        # Should cleanup on logout be enabled at all?
        enabled: true
        # Settings for manual logouts (explicitly initiated by the Matrix user)
        manual:
            # Action for private portals which will never be shared with other Matrix users.
            private: delete
            # Action for portals with a relay user configured.
            relayed: delete
            # Action for portals which may be shared, but don't currently have any other Matrix users.
            shared_no_users: delete
            # Action for portals which have other logged-in Matrix users.
            shared_has_users: delete
        # Settings for credentials being invalidated (initiated by the remote network, possibly through user action).
        # Keys have the same meanings as in the manual section.
        bad_credentials:
            private: nothing
            relayed: nothing
            shared_no_users: nothing
            shared_has_users: nothing

    # Settings for relay mode
    relay:
        # Whether relay mode should be allowed. If allowed, the set-relay command can be used to turn any
        # authenticated user into a relaybot for that chat.
        enabled: false
        # Should only admins be allowed to set themselves as relay users?
        admin_only: true
        # List of user login IDs which anyone can set as a relay, as long as the relay user is in the room.
        default_relays: []

    # Permissions for using the bridge.
    # Permitted values:
    #    relay - Talk through the relaybot (if enabled), no access otherwise
    # commands - Access to use commands in the bridge, but not login.
    #     user - Access to use the bridge with puppeting.
    #    admin - Full access, user level with some additional administration tools.
    # Permitted keys:
    #        * - All Matrix users
    #   domain - All users on that homeserver
    #     mxid - Specific user
    permissions:
        "{{ .UserID }}": admin

# Config for the bridge's database.
database:
    # The database type. "sqlite3-fk-wal" and "postgres" are supported.
    type: sqlite3-fk-wal
    # The database URI.
    #   SQLite: A raw file path is supported, but `file:<path>?_txlock=immediate` is recommended.
    #           https://github.com/mattn/go-sqlite3#connection-string
    #   Postgres: Connection string. For example, postgres://user:password@host/database?sslmode=disable
    #             To connect via Unix socket, use something like postgres:///dbname?host=/var/run/postgresql
    uri: file:{{.DatabasePrefix}}{{or .DatabaseFileName .BridgeName}}.db?_txlock=immediate
    # Maximum number of connections.
    max_open_conns: 5
    max_idle_conns: 2
    # Maximum connection idle time and lifetime before they're closed. Disabled if null.
    # Parsed with https://pkg.go.dev/time#ParseDuration
    max_conn_idle_time: null
    max_conn_lifetime: null

# Homeserver details.
homeserver:
    # The address that this appservice can use to connect to the homeserver.
    # Local addresses without HTTPS are generally recommended when the bridge is running on the same machine,
    # but https also works if they run on different machines.
    address: {{ .HungryAddress }}
    # The domain of the homeserver (also known as server_name, used for MXIDs, etc).
    domain: beeper.local

    # What software is the homeserver running?
    # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
    software: hungry
    # The URL to push real-time bridge status to.
    # If set, the bridge will make POST requests to this URL whenever a user's remote network connection state changes.
    # The bridge will use the appservice as_token to authorize requests.
    status_endpoint: null
    # Endpoint for reporting per-message status.
    # If set, the bridge will make POST requests to this URL when processing a message from Matrix.
    # It will make one request when receiving the message (step BRIDGE), one after decrypting if applicable
    # (step DECRYPTED) and one after sending to the remote network (step REMOTE). Errors will also be reported.
    # The bridge will use the appservice as_token to authorize requests.
    message_send_checkpoint_endpoint: null
    # Does the homeserver support https://github.com/matrix-org/matrix-spec-proposals/pull/2246?
    async_media: true

    # Should the bridge use a websocket for connecting to the homeserver?
    # The server side is currently not documented anywhere and is only implemented by mautrix-wsproxy,
    # mautrix-asmux (deprecated), and hungryserv (proprietary).
    websocket: {{ .Websocket }}
    # How often should the websocket be pinged? Pinging will be disabled if this is zero.
    ping_interval_seconds: 180

# Application service host/registration related details.
# Changing these values requires regeneration of the registration.
appservice:
    # The address that the homeserver can use to connect to this appservice.
    address: irrelevant
    # A public address that external services can use to reach this appservice.
    # This value doesn't affect the registration file.
    public_address:

    # The hostname and port where this appservice should listen.
    # For Docker, you generally have to change the hostname to 0.0.0.0.
    hostname: 0.0.0.0
    port: 4000

    # The unique ID of this appservice.
    id: {{ .AppserviceID }}
    # Appservice bot details.
    bot:
        # Username of the appservice bot.
        username: {{ .BridgeName }}bot
        # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
        # to leave display name/avatar as-is.
        {{ if .BridgeTypeName -}}
        displayname: {{ .BridgeTypeName }} bridge bot
        {{- end }}
        {{ if .BridgeTypeIcon -}}
        avatar: {{ .BridgeTypeIcon }}
        {{- end }}

    # Whether to receive ephemeral events via appservice transactions.
    ephemeral_events: true
    # Should incoming events be handled asynchronously?
    # This may be necessary for large public instances with lots of messages going through.
    # However, messages will not be guaranteed to be bridged in the same order they were sent in.
    async_transactions: false

    # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
    as_token: {{ .ASToken }}
    hs_token: {{ .HSToken }}

    # Localpart template of MXIDs for remote users.
    username_template: {{ .BridgeName }}_{{ "{{.}}" }}

# Config options that affect the Matrix connector of the bridge.
matrix:
    # Whether the bridge should send the message status as a custom com.beeper.message_send_status event.
    message_status_events: true
    # Whether the bridge should send a read receipt after successfully bridging a message.
    delivery_receipts: false
    # Whether the bridge should send error notices via m.notice events when a message fails to bridge.
    message_error_notices: false
    # Whether the bridge should update the m.direct account data event when double puppeting is enabled.
    sync_direct_chat_list: false
    # Whether created rooms should have federation enabled. If false, created portal rooms
    # will never be federated. Changing this option requires recreating rooms.
    federate_rooms: false
    # The threshold as bytes after which the bridge should roundtrip uploads via the disk
    # rather than keeping the whole file in memory.
    upload_file_threshold: 5242880

# Settings for provisioning API
provisioning:
    # Prefix for the provisioning API paths.
    prefix: /_matrix/provision
    # Shared secret for authentication. If set to "generate" or null, a random secret will be generated,
    # or if set to "disable", the provisioning API will be disabled.
    shared_secret: {{ .ProvisioningSecret }}
    # Whether to allow provisioning API requests to be authed using Matrix access tokens.
    # This follows the same rules as double puppeting to determine which server to contact to check the token,
    # which means that by default, it only works for users on the same server as the bridge.
    allow_matrix_auth: true
    # Enable debug API at /debug with provisioning authentication.
    debug_endpoints: true

# Some networks require publicly accessible media download links (e.g. for user avatars when using Discord webhooks).
# These settings control whether the bridge will provide such public media access.
public_media:
    # Should public media be enabled at all?
    # The public_address field under the appservice section MUST be set when enabling public media.
    enabled: false
    # A key for signing public media URLs.
    # If set to "generate", a random key will be generated.
    signing_key: {{ .ProvisioningSecret }}
    # Number of seconds that public media URLs are valid for.
    # If set to 0, URLs will never expire.
    expiry: 0
    # Length of hash to use for public media URLs. Must be between 0 and 32.
    hash_length: 32

# Settings for converting remote media to custom mxc:// URIs instead of reuploading.
# More details can be found at https://docs.mau.fi/bridges/go/discord/direct-media.html
direct_media:
    # Should custom mxc:// URIs be used instead of reuploading media?
    enabled: false
    # The server name to use for the custom mxc:// URIs.
    # This server name will effectively be a real Matrix server, it just won't implement anything other than media.
    # You must either set up .well-known delegation from this domain to the bridge, or proxy the domain directly to the bridge.
    server_name: discord-media.example.com
    # Optionally a custom .well-known response. This defaults to `server_name:443`
    well_known_response:
    # Optionally specify a custom prefix for the media ID part of the MXC URI.
    media_id_prefix:
    # If the remote network supports media downloads over HTTP, then the bridge will use MSC3860/MSC3916
    # media download redirects if the requester supports it. Optionally, you can force redirects
    # and not allow proxying at all by setting this to false.
    # This option does nothing if the remote network does not support media downloads over HTTP.
    allow_proxy: true
    # Matrix server signing key to make the federation tester pass, same format as synapse's .signing.key file.
    # This key is also used to sign the mxc:// URIs to ensure only the bridge can generate them.
    server_key: ed25519 AAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

# Settings for backfilling messages.
# Note that the exact way settings are applied depends on the network connector.
# See https://docs.mau.fi/bridges/general/backfill.html for more details.
backfill:
    # Whether to do backfilling at all.
    enabled: true
    # Maximum number of messages to backfill in empty rooms.
    max_initial_messages: {{ or .MaxInitialMessages 50 }}
    # Maximum number of missed messages to backfill after bridge restarts.
    max_catchup_messages: 500
    # If a backfilled chat is older than this number of hours,
    # mark it as read even if it's unread on the remote network.
    unread_hours_threshold: 720
    # Settings for backfilling threads within other backfills.
    threads:
        # Maximum number of messages to backfill in a new thread.
        max_initial_messages: 50
    # Settings for the backwards backfill queue. This only applies when connecting to
    # Beeper as standard Matrix servers don't support inserting messages into history.
    queue:
        # Should the backfill queue be enabled?
        enabled: true
        # Number of messages to backfill in one batch.
        batch_size: {{ or .MaxBackwardMessages 50 }}
        # Delay between batches in seconds.
        batch_delay: 20
        # Maximum number of batches to backfill per portal.
        # If set to -1, all available messages will be backfilled.
        max_batches: 0
        # Optional network-specific overrides for max batches.
        # Interpretation of this field depends on the network connector.
        max_batches_override:
            channel: 10
            supergroup: 10
            dm: -1
            group_dm: -1

# Settings for enabling double puppeting
double_puppet:
    # Servers to always allow double puppeting from.
    # This is only for other servers and should NOT contain the server the bridge is on.
    servers:
        {{ .BeeperDomain }}: {{ .HungryAddress }}
    # Whether to allow client API URL discovery for other servers. When using this option,
    # users on other servers can use double puppeting even if their server URLs aren't
    # explicitly added to the servers map above.
    allow_discovery: false
    # Shared secrets for automatic double puppeting.
    # See https://docs.mau.fi/bridges/general/double-puppeting.html for instructions.
    secrets:
        {{ .BeeperDomain }}: "as_token:{{ .ASToken }}"

# End-to-bridge encryption support options.
#
# See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html for more info.
encryption:
    # Whether to enable encryption at all. If false, the bridge will not function in encrypted rooms.
    allow: true
    # Whether to force-enable encryption in all bridged rooms.
    default: true
    # Whether to require all messages to be encrypted and drop any unencrypted messages.
    require: true
    # Whether to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
    # This option is not yet compatible with standard Matrix servers like Synapse and should not be used.
    appservice: true
    # Whether to use MSC4190 instead of appservice login to create the bridge bot device.
    # Requires the homeserver to support MSC4190 and the device masquerading parts of MSC3202.
    # Only relevant when using end-to-bridge encryption, required when using encryption with next-gen auth (MSC3861).
    # Changing this option requires updating the appservice registration file.
    msc4190: false
    # Should the bridge bot generate a recovery key and cross-signing keys and verify itself?
    # Note that without the latest version of MSC4190, this will fail if you reset the bridge database.
    # The generated recovery key will be saved in the kv_store table under `recovery_key`.
    self_sign: false
    # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
    # You must use a client that supports requesting keys from other users to use this feature.
    allow_key_sharing: true
    # Pickle key for encrypting encryption keys in the bridge database.
    # If set to generate, a random key will be generated.
    pickle_key: {{ or .Params.pickle_key .DefaultPickleKey "bbctl" }}
    # Options for deleting megolm sessions from the bridge.
    delete_keys:
        # Beeper-specific: delete outbound sessions when hungryserv confirms
        # that the user has uploaded the key to key backup.
        delete_outbound_on_ack: true
        # Don't store outbound sessions in the inbound table.
        dont_store_outbound: false
        # Ratchet megolm sessions forward after decrypting messages.
        ratchet_on_decrypt: true
        # Delete fully used keys (index >= max_messages) after decrypting messages.
        delete_fully_used_on_decrypt: true
        # Delete previous megolm sessions from same device when receiving a new one.
        delete_prev_on_new_session: true
        # Delete megolm sessions received from a device when the device is deleted.
        delete_on_device_delete: true
        # Periodically delete megolm sessions when 2x max_age has passed since receiving the session.
        periodically_delete_expired: true
        # Delete inbound megolm sessions that don't have the received_at field used for
        # automatic ratcheting and expired session deletion. This is meant as a migration
        # to delete old keys prior to the bridge update.
        delete_outdated_inbound: false
    # What level of device verification should be required from users?
    #
    # Valid levels:
    #   unverified - Send keys to all device in the room.
    #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
    #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
    #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
    #                           Note that creating user signatures from the bridge bot is not currently possible.
    #   verified - Require manual per-device verification
    #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
    verification_levels:
        # Minimum level for which the bridge should send keys to when bridging messages from the remote network to Matrix.
        receive: cross-signed-tofu
        # Minimum level that the bridge should accept for incoming Matrix messages.
        send: cross-signed-tofu
        # Minimum level that the bridge should require for accepting key requests.
        share: cross-signed-tofu
    # Options for Megolm room key rotation. These options allow you to configure the m.room.encryption event content.
    # See https://spec.matrix.org/v1.10/client-server-api/#mroomencryption for more information about that event.
    rotation:
        # Enable custom Megolm room key rotation settings. Note that these
        # settings will only apply to rooms created after this option is set.
        enable_custom: true
        # The maximum number of milliseconds a session should be used
        # before changing it. The Matrix spec recommends 604800000 (a week)
        # as the default.
        milliseconds: 2592000000
        # The maximum number of messages that should be sent with a given a
        # session before changing it. The Matrix spec recommends 100 as the
        # default.
        messages: 10000
        # Disable rotating keys when a user's devices change?
        # You should not enable this option unless you understand all the implications.
        disable_device_change_key_rotation: true

# Logging config. See https://github.com/tulir/zeroconfig for details.
logging:
    min_level: debug
    writers:
        - type: stdout
          format: pretty-colored
        - type: file
          format: json
          filename: ./logs/bridge.log
          max_size: 100
          max_backups: 10
          compress: false



================================================
FILE: bridgeconfig/discord.tpl.yaml
================================================
# Homeserver details.
homeserver:
    # The address that this appservice can use to connect to the homeserver.
    address: {{ .HungryAddress }}
    # Publicly accessible base URL for media, used for avatars in relay mode.
    # If not set, the connection address above will be used.
    public_address: https://matrix.{{ .BeeperDomain }}
    # The domain of the homeserver (also known as server_name, used for MXIDs, etc).
    domain: beeper.local

    # What software is the homeserver running?
    # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
    software: hungry
    # The URL to push real-time bridge status to.
    # If set, the bridge will make POST requests to this URL whenever a user's discord connection state changes.
    # The bridge will use the appservice as_token to authorize requests.
    status_endpoint: null
    # Endpoint for reporting per-message status.
    message_send_checkpoint_endpoint: null
    # Does the homeserver support https://github.com/matrix-org/matrix-spec-proposals/pull/2246?
    async_media: true

    # Should the bridge use a websocket for connecting to the homeserver?
    # The server side is currently not documented anywhere and is only implemented by mautrix-wsproxy,
    # mautrix-asmux (deprecated), and hungryserv (proprietary).
    websocket: {{ .Websocket }}
    # How often should the websocket be pinged? Pinging will be disabled if this is zero.
    ping_interval_seconds: 180

# Application service host/registration related details.
# Changing these values requires regeneration of the registration.
appservice:
    # The address that the homeserver can use to connect to this appservice.
    address: null

    # The hostname and port where this appservice should listen.
    hostname: {{ if .Websocket }}null{{ else }}{{ .ListenAddr }}{{ end }}
    port: {{ if .Websocket }}null{{ else }}{{ .ListenPort }}{{ end }}

    # Database config.
    database:
        # The database type. "sqlite3-fk-wal" and "postgres" are supported.
        type: sqlite3-fk-wal
        # The database URI.
        #   SQLite: A raw file path is supported, but `file:<path>?_txlock=immediate` is recommended.
        #           https://github.com/mattn/go-sqlite3#connection-string
        #   Postgres: Connection string. For example, postgres://user:password@host/database?sslmode=disable
        #             To connect via Unix socket, use something like postgres:///dbname?host=/var/run/postgresql
        uri: file:{{.DatabasePrefix}}mautrix-discord.db?_txlock=immediate
        # Maximum number of connections. Mostly relevant for Postgres.
        max_open_conns: 5
        max_idle_conns: 2
        # Maximum connection idle time and lifetime before they're closed. Disabled if null.
        # Parsed with https://pkg.go.dev/time#ParseDuration
        max_conn_idle_time: null
        max_conn_lifetime: null

    # The unique ID of this appservice.
    id: {{ .AppserviceID }}
    # Appservice bot details.
    bot:
        # Username of the appservice bot.
        username: {{ .BridgeName }}bot
        # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
        # to leave display name/avatar as-is.
        displayname: Discord bridge bot
        avatar: mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC

    # Whether or not to receive ephemeral events via appservice transactions.
    # Requires MSC2409 support (i.e. Synapse 1.22+).
    ephemeral_events: true

    # Should incoming events be handled asynchronously?
    # This may be necessary for large public instances with lots of messages going through.
    # However, messages will not be guaranteed to be bridged in the same order they were sent in.
    async_transactions: false

    # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
    as_token: {{ .ASToken }}
    hs_token: {{ .HSToken }}

# Bridge config
bridge:
    # Localpart template of MXIDs for Discord users.
    # {{.}} is replaced with the internal ID of the Discord user.
    username_template: {{ .BridgeName }}_{{ "{{.}}" }}
    # Displayname template for Discord users. This is also used as the room name in DMs if private_chat_portal_meta is enabled.
    # Available variables:
    #   .ID - Internal user ID
    #   .Username - Legacy display/username on Discord
    #   .GlobalName - New displayname on Discord
    #   .Discriminator - The 4 numbers after the name on Discord
    #   .Bot - Whether the user is a bot
    #   .System - Whether the user is an official system user
    #   .Webhook - Whether the user is a webhook and is not an application
    #   .Application - Whether the user is an application
    displayname_template: {{ `"{{if .Webhook}}Webhook{{else}}{{or .GlobalName .Username}}{{end}}"` }}
    # Displayname template for Discord channels (bridged as rooms, or spaces when type=4).
    # Available variables:
    #   .Name - Channel name, or user displayname (pre-formatted with displayname_template) in DMs.
    #   .ParentName - Parent channel name (used for categories).
    #   .GuildName - Guild name.
    #   .NSFW - Whether the channel is marked as NSFW.
    #   .Type - Channel type (see values at https://github.com/bwmarrin/discordgo/blob/v0.25.0/structs.go#L251-L267)
    channel_name_template: {{ `"{{if or (eq .Type 3) (eq .Type 4)}}{{.Name}}{{else}}#{{.Name}}{{end}}"` }}
    # Displayname template for Discord guilds (bridged as spaces).
    # Available variables:
    #   .Name - Guild name
    guild_name_template: {{ `"{{.Name}}"` }}
    # Whether to explicitly set the avatar and room name for private chat portal rooms.
    # If set to `default`, this will be enabled in encrypted rooms and disabled in unencrypted rooms.
    # If set to `always`, all DM rooms will have explicit names and avatars set.
    # If set to `never`, DM rooms will never have names and avatars set.
    private_chat_portal_meta: never

    portal_message_buffer: 128

    # Number of private channel portals to create on bridge startup.
    # Other portals will be created when receiving messages.
    startup_private_channel_create_limit: 5
    # Should the bridge send a read receipt from the bridge bot when a message has been sent to Discord?
    delivery_receipts: false
    # Whether the bridge should send the message status as a custom com.beeper.message_send_status event.
    message_status_events: true
    # Whether the bridge should send error notices via m.notice events when a message fails to bridge.
    message_error_notices: false
    # Should the bridge use space-restricted join rules instead of invite-only for guild rooms?
    # This can avoid unnecessary invite events in guild rooms when members are synced in.
    restricted_rooms: false
    # Should the bridge automatically join the user to threads on Discord when the thread is opened on Matrix?
    # This only works with clients that support thread read receipts (MSC3771 added in Matrix v1.4).
    autojoin_thread_on_open: true
    # Should inline fields in Discord embeds be bridged as HTML tables to Matrix?
    # Tables aren't supported in all clients, but are the only way to emulate the Discord inline field UI.
    embed_fields_as_tables: true
    # Should guild channels be muted when the portal is created? This only meant for single-user instances,
    # it won't mute it for all users if there are multiple Matrix users in the same Discord guild.
    mute_channels_on_create: true
    # Should the bridge update the m.direct account data event when double puppeting is enabled.
    # Note that updating the m.direct event is not atomic (except with mautrix-asmux)
    # and is therefore prone to race conditions.
    sync_direct_chat_list: false
    # Set this to true to tell the bridge to re-send m.bridge events to all rooms on the next run.
    # This field will automatically be changed back to false after it, except if the config file is not writable.
    resend_bridge_info: false
    # Should incoming custom emoji reactions be bridged as mxc:// URIs?
    # If set to false, custom emoji reactions will be bridged as the shortcode instead, and the image won't be available.
    custom_emoji_reactions: true
    # Should the bridge attempt to completely delete portal rooms when a channel is deleted on Discord?
    # If true, the bridge will try to kick Matrix users from the room. Otherwise, the bridge only makes ghosts leave.
    delete_portal_on_channel_delete: true
    # Should the bridge delete all portal rooms when you leave a guild on Discord?
    # This only applies if the guild has no other Matrix users on this bridge instance.
    delete_guild_on_leave: true
    # Whether or not created rooms should have federation enabled.
    # If false, created portal rooms will never be federated.
    federate_rooms: false
    # Prefix messages from webhooks with the profile info? This can be used along with a custom displayname_template
    # to better handle webhooks that change their name all the time (like ones used by bridges).
    prefix_webhook_messages: true
    # Bridge webhook avatars?
    enable_webhook_avatars: false
    # Should the bridge upload media to the Discord CDN directly before sending the message when using a user token,
    # like the official client does? The other option is sending the media in the message send request as a form part
    # (which is always used by bots and webhooks).
    use_discord_cdn_upload: true
    # Should mxc uris copied from Discord be cached?
    # This can be `never` to never cache, `unencrypted` to only cache unencrypted mxc uris, or `always` to cache everything.
    # If you have a media repo that generates non-unique mxc uris, you should set this to never.
    cache_media: unencrypted
    # Patterns for converting Discord media to custom mxc:// URIs instead of reuploading.
    # Each of the patterns can be set to null to disable custom URIs for that type of media.
    # More details can be found at https://docs.mau.fi/bridges/go/discord/direct-media.html
    media_patterns:
        # Should custom mxc:// URIs be used instead of reuploading media?
        enabled: false
        # Pattern for normal message attachments.
        attachments: {{ `mxc://discord-media.mau.dev/attachments|{{.ChannelID}}|{{.AttachmentID}}|{{.FileName}}` }}
        # Pattern for custom emojis.
        emojis: {{ `mxc://discord-media.mau.dev/emojis|{{.ID}}.{{.Ext}}` }}
        # Pattern for stickers. Note that animated lottie stickers will not be converted if this is enabled.
        stickers: {{ `mxc://discord-media.mau.dev/stickers|{{.ID}}.{{.Ext}}` }}
        # Pattern for static user avatars.
        avatars: {{ `mxc://discord-media.mau.dev/avatars|{{.UserID}}|{{.AvatarID}}.{{.Ext}}` }}
    # Settings for converting animated stickers.
    animated_sticker:
        # Format to which animated stickers should be converted.
        # disable - No conversion, send as-is (lottie JSON)
        # png - converts to non-animated png (fastest)
        # gif - converts to animated gif
        # webm - converts to webm video, requires ffmpeg executable with vp9 codec and webm container support
        # webp - converts to animated webp, requires ffmpeg executable with webp codec/container support
        target: webp
        # Arguments for converter. All converters take width and height.
        args:
            width: 320
            height: 320
            fps: 25 # only for webm, webp and gif (2, 5, 10, 20 or 25 recommended)
    # Servers to always allow double puppeting from
    double_puppet_server_map:
        {{ .BeeperDomain }}: {{ .HungryAddress }}
    # Allow using double puppeting from any server with a valid client .well-known file.
    double_puppet_allow_discovery: false
    # Shared secrets for https://github.com/devture/matrix-synapse-shared-secret-auth
    #
    # If set, double puppeting will be enabled automatically for local users
    # instead of users having to find an access token and run `login-matrix`
    # manually.
    login_shared_secret_map:
        {{ .BeeperDomain }}: "as_token:{{ .ASToken }}"

    # The prefix for commands. Only required in non-management rooms.
    command_prefix: '!discord'
    # Messages sent upon joining a management room.
    # Markdown is supported. The defaults are listed below.
    management_room_text:
        # Sent when joining a room.
        welcome: "Hello, I'm a Discord bridge bot."
        # Sent when joining a management room and the user is already logged in.
        welcome_connected: "Use `help` for help."
        # Sent when joining a management room and the user is not logged in.
        welcome_unconnected: "Use `help` for help or `login` to log in."
        # Optional extra text sent when joining a management room.
        additional_help: ""

    # Settings for backfilling messages.
    backfill:
        # Limits for forward backfilling.
        forward_limits:
            # Initial backfill (when creating portal). 0 means backfill is disabled.
            # A special unlimited value is not supported, you must set a limit. Initial backfill will
            # fetch all messages first before backfilling anything, so high limits can take a lot of time.
            initial:
                dm: 50
                channel: 0
                thread: 0
            # Missed message backfill (on startup).
            # 0 means backfill is disabled, -1 means fetch all messages since last bridged message.
            # When using unlimited backfill (-1), messages are backfilled as they are fetched.
            # With limits, all messages up to the limit are fetched first and backfilled afterwards.
            missed:
                dm: -1
                channel: 50
                thread: 0
        # Maximum members in a guild to enable backfilling. Set to -1 to disable limit.
        # This can be used as a rough heuristic to disable backfilling in channels that are too active.
        # Currently only applies to missed message backfill.
        max_guild_members: 500

    # End-to-bridge encryption support options.
    #
    # See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html for more info.
    encryption:
        # Allow encryption, work in group chat rooms with e2ee enabled
        allow: true
        # Default to encryption, force-enable encryption in all portals the bridge creates
        # This will cause the bridge bot to be in private chats for the encryption to work properly.
        default: true
        # Whether to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
        appservice: true
        # Require encryption, drop any unencrypted messages.
        require: true
        # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
        # You must use a client that supports requesting keys from other users to use this feature.
        allow_key_sharing: true
        # Should users mentions be in the event wire content to enable the server to send push notifications?
        plaintext_mentions: true
        # Options for deleting megolm sessions from the bridge.
        delete_keys:
            # Beeper-specific: delete outbound sessions when hungryserv confirms
            # that the user has uploaded the key to key backup.
            delete_outbound_on_ack: true
            # Don't store outbound sessions in the inbound table.
            dont_store_outbound: false
            # Ratchet megolm sessions forward after decrypting messages.
            ratchet_on_decrypt: true
            # Delete fully used keys (index >= max_messages) after decrypting messages.
            delete_fully_used_on_decrypt: true
            # Delete previous megolm sessions from same device when receiving a new one.
            delete_prev_on_new_session: true
            # Delete megolm sessions received from a device when the device is deleted.
            delete_on_device_delete: true
            # Periodically delete megolm sessions when 2x max_age has passed since receiving the session.
            periodically_delete_expired: true
            # Delete inbound megolm sessions that don't have the received_at field used for
            # automatic ratcheting and expired session deletion. This is meant as a migration
            # to delete old keys prior to the bridge update.
            delete_outdated_inbound: false
        # What level of device verification should be required from users?
        #
        # Valid levels:
        #   unverified - Send keys to all device in the room.
        #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
        #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
        #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
        #                           Note that creating user signatures from the bridge bot is not currently possible.
        #   verified - Require manual per-device verification
        #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
        verification_levels:
            # Minimum level for which the bridge should send keys to when bridging messages from WhatsApp to Matrix.
            receive: cross-signed-tofu
            # Minimum level that the bridge should accept for incoming Matrix messages.
            send: cross-signed-tofu
            # Minimum level that the bridge should require for accepting key requests.
            share: cross-signed-tofu
        # Options for Megolm room key rotation. These options allow you to
        # configure the m.room.encryption event content. See:
        # https://spec.matrix.org/v1.3/client-server-api/#mroomencryption for
        # more information about that event.
        rotation:
            # Enable custom Megolm room key rotation settings. Note that these
            # settings will only apply to rooms created after this option is
            # set.
            enable_custom: true
            # The maximum number of milliseconds a session should be used
            # before changing it. The Matrix spec recommends 604800000 (a week)
            # as the default.
            milliseconds: 2592000000
            # The maximum number of messages that should be sent with a given a
            # session before changing it. The Matrix spec recommends 100 as the
            # default.
            messages: 10000

            # Disable rotating keys when a user's devices change?
            # You should not enable this option unless you understand all the implications.
            disable_device_change_key_rotation: true

    # Settings for provisioning API
    provisioning:
        # Prefix for the provisioning API paths.
        prefix: /_matrix/provision
        # Shared secret for authentication. If set to "generate", a random secret will be generated,
        # or if set to "disable", the provisioning API will be disabled.
        shared_secret: {{ .ProvisioningSecret }}

    # Permissions for using the bridge.
    # Permitted values:
    #    relay - Talk through the relaybot (if enabled), no access otherwise
    #     user - Access to use the bridge to chat with a Discord account.
    #    admin - User level and some additional administration tools
    # Permitted keys:
    #        * - All Matrix users
    #   domain - All users on that homeserver
    #     mxid - Specific user
    permissions:
        "{{ .UserID }}": admin

# Logging config. See https://github.com/tulir/zeroconfig for details.
logging:
    min_level: debug
    writers:
    - type: stdout
      format: pretty-colored
    - type: file
      format: json
      filename: ./logs/mautrix-discord.log
      max_size: 100
      max_backups: 10
      compress: true



================================================
FILE: bridgeconfig/gmessages.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for SMS users.
    displayname_template: {{ `"{{or .FullName .PhoneNumber}}"` }}
    # Settings for how the bridge appears to the phone.
    device_meta:
        # OS name to tell the phone. This is the name that shows up in the paired devices list.
        os: Beeper (self-hosted)
        # Browser type to tell the phone. This decides which icon is shown.
        # Valid types: OTHER, CHROME, FIREFOX, SAFARI, OPERA, IE, EDGE
        browser: OTHER
        # Device type to tell the phone. This also affects the icon, as well as how many sessions are allowed simultaneously.
        # One web, two tablets and one PWA should be able to connect at the same time.
        # Valid types: WEB, TABLET, PWA
        type: TABLET
    # Should the bridge aggressively set itself as the active device if the user opens Google Messages in a browser?
    # If this is disabled, the user must manually use the `set-active` command to reactivate the bridge.
    aggressive_reconnect: true
    # Number of chats to sync when connecting to Google Messages.
    initial_chat_sync_count: 25

{{ setfield . "CommandPrefix" "!gm" -}}
{{ setfield . "DatabaseFileName" "mautrix-gmessages" -}}
{{ setfield . "BridgeTypeName" "Google Messages" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/yGOdcrJcwqARZqdzbfuxfhzb" -}}
{{ setfield . "DefaultPickleKey" "go.mau.fi/mautrix-gmessages" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/googlechat.tpl.yaml
================================================
# Homeserver details
homeserver:
    # The address that this appservice can use to connect to the homeserver.
    address: {{ .HungryAddress }}
    # The domain of the homeserver (for MXIDs, etc).
    domain: beeper.local
    # Whether or not to verify the SSL certificate of the homeserver.
    # Only applies if address starts with https://
    verify_ssl: true
    # What software is the homeserver running?
    # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
    software: hungry
    # Number of retries for all HTTP requests if the homeserver isn't reachable.
    http_retry_count: 4
    # The URL to push real-time bridge status to.
    # If set, the bridge will make POST requests to this URL whenever a user's Google Chat connection state changes.
    # The bridge will use the appservice as_token to authorize requests.
    status_endpoint: null
    # Endpoint for reporting per-message status.
    message_send_checkpoint_endpoint: null
    # Whether asynchronous uploads via MSC2246 should be enabled for media.
    # Requires a media repo that supports MSC2246.
    async_media: true

# Application service host/registration related details
# Changing these values requires regeneration of the registration.
appservice:
    # The address that the homeserver can use to connect to this appservice.
    address: "http://{{ .ListenAddr }}:{{ .ListenPort }}"

    # The hostname and port where this appservice should listen.
    hostname: {{ .ListenAddr }}
    port: {{ .ListenPort }}
    # The maximum body size of appservice API requests (from the homeserver) in mebibytes
    # Usually 1 is enough, but on high-traffic bridges you might need to increase this to avoid 413s
    max_body_size: 1

    # The full URI to the database. SQLite and Postgres are supported.
    # Format examples:
    #   SQLite:   sqlite:filename.db
    #   Postgres: postgres://username:password@hostname/dbname
    database: sqlite:{{.DatabasePrefix}}mautrix-googlechat.db
    # Additional arguments for asyncpg.create_pool() or sqlite3.connect()
    # https://magicstack.github.io/asyncpg/current/api/index.html#asyncpg.pool.create_pool
    # https://docs.python.org/3/library/sqlite3.html#sqlite3.connect
    # For sqlite, min_size is used as the connection thread pool size and max_size is ignored.
    # Additionally, SQLite supports init_commands as an array of SQL queries to run on connect (e.g. to set PRAGMAs).
    database_opts:
        min_size: 1
        max_size: 1

    # The unique ID of this appservice.
    id: {{ .AppserviceID }}
    # Username of the appservice bot.
    bot_username: {{ .BridgeName}}bot
    # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
    # to leave display name/avatar as-is.
    bot_displayname: Google Chat bridge bot
    bot_avatar: mxc://maunium.net/BDIWAQcbpPGASPUUBuEGWXnQ

    # Whether or not to receive ephemeral events via appservice transactions.
    # Requires MSC2409 support (i.e. Synapse 1.22+).
    # You should disable bridge -> sync_with_custom_puppets when this is enabled.
    ephemeral_events: true

    # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
    as_token: {{ .ASToken }}
    hs_token: {{ .HSToken }}

# Prometheus telemetry config. Requires prometheus-client to be installed.
metrics:
    enabled: false
    listen_port: 8000

# Manhole config.
manhole:
    # Whether or not opening the manhole is allowed.
    enabled: false
    # The path for the unix socket.
    path: /var/tmp/mautrix-googlechat.manhole
    # The list of UIDs who can be added to the whitelist.
    # If empty, any UIDs can be specified in the open-manhole command.
    whitelist:
    - 0

# Bridge config
bridge:
    # Localpart template of MXIDs for Google Chat users.
    # {userid} is replaced with the user ID of the Google Chat user.
    username_template: "{{ .BridgeName }}_{userid}"
    # Displayname template for Google Chat users.
    # {full_name}, {first_name}, {last_name} and {email} are replaced with names.
    displayname_template: "{full_name}"

    # The prefix for commands. Only required in non-management rooms.
    command_prefix: "!gc"

    # Number of chats to sync (and create portals for) on startup/login.
    # Set 0 to disable automatic syncing.
    initial_chat_sync: 10
    # Whether or not the Google Chat users of logged in Matrix users should be
    # invited to private chats when the user sends a message from another client.
    invite_own_puppet_to_pm: false
    # Whether or not to use /sync to get presence, read receipts and typing notifications
    # when double puppeting is enabled
    sync_with_custom_puppets: false
    # Whether or not to update the m.direct account data event when double puppeting is enabled.
    # Note that updating the m.direct event is not atomic (except with mautrix-asmux)
    # and is therefore prone to race conditions.
    sync_direct_chat_list: false
    # Servers to always allow double puppeting from
    double_puppet_server_map:
        {{ .BeeperDomain }}: {{ .HungryAddress }}
    # Allow using double puppeting from any server with a valid client .well-known file.
    double_puppet_allow_discovery: false
    # Shared secret for https://github.com/devture/matrix-synapse-shared-secret-auth
    #
    # If set, custom puppets will be enabled automatically for local users
    # instead of users having to find an access token and run `login-matrix`
    # manually.
    # If using this for other servers than the bridge's server,
    # you must also set the URL in the double_puppet_server_map.
    login_shared_secret_map:
        {{ .BeeperDomain }}: "as_token:{{ .ASToken }}"
    # Whether or not to update avatars when syncing all contacts at startup.
    update_avatar_initial_sync: true
    # End-to-bridge encryption support options.
    #
    # See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html for more info.
    encryption:
        # Allow encryption, work in group chat rooms with e2ee enabled
        allow: true
        # Default to encryption, force-enable encryption in all portals the bridge creates
        # This will cause the bridge bot to be in private chats for the encryption to work properly.
        default: true
        # Whether to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
        appservice: true
        # Require encryption, drop any unencrypted messages.
        require: true
        # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
        # You must use a client that supports requesting keys from other users to use this feature.
        allow_key_sharing: true
        # Options for deleting megolm sessions from the bridge.
        delete_keys:
            # Beeper-specific: delete outbound sessions when hungryserv confirms
            # that the user has uploaded the key to key backup.
            delete_outbound_on_ack: true
            # Don't store outbound sessions in the inbound table.
            dont_store_outbound: false
            # Ratchet megolm sessions forward after decrypting messages.
            ratchet_on_decrypt: true
            # Delete fully used keys (index >= max_messages) after decrypting messages.
            delete_fully_used_on_decrypt: true
            # Delete previous megolm sessions from same device when receiving a new one.
            delete_prev_on_new_session: true
            # Delete megolm sessions received from a device when the device is deleted.
            delete_on_device_delete: true
            # Periodically delete megolm sessions when 2x max_age has passed since receiving the session.
            periodically_delete_expired: true
            # Delete inbound megolm sessions that don't have the received_at field used for
            # automatic ratcheting and expired session deletion. This is meant as a migration
            # to delete old keys prior to the bridge update.
            delete_outdated_inbound: true
        # What level of device verification should be required from users?
        #
        # Valid levels:
        #   unverified - Send keys to all device in the room.
        #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
        #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
        #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
        #                           Note that creating user signatures from the bridge bot is not currently possible.
        #   verified - Require manual per-device verification
        #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
        verification_levels:
            # Minimum level for which the bridge should send keys to when bridging messages from Telegram to Matrix.
            receive: cross-signed-tofu
            # Minimum level that the bridge should accept for incoming Matrix messages.
            send: cross-signed-tofu
            # Minimum level that the bridge should require for accepting key requests.
            share: cross-signed-tofu
        # Options for Megolm room key rotation. These options allow you to
        # configure the m.room.encryption event content. See:
        # https://spec.matrix.org/v1.3/client-server-api/#mroomencryption for
        # more information about that event.
        rotation:
            # Enable custom Megolm room key rotation settings. Note that these
            # settings will only apply to rooms created after this option is
            # set.
            enable_custom: true
            # The maximum number of milliseconds a session should be used
            # before changing it. The Matrix spec recommends 604800000 (a week)
            # as the default.
            milliseconds: 2592000000
            # The maximum number of messages that should be sent with a given a
            # session before changing it. The Matrix spec recommends 100 as the
            # default.
            messages: 10000

            # Disable rotating keys when a user's devices change?
            # You should not enable this option unless you understand all the implications.
            disable_device_change_key_rotation: true

    # Whether or not the bridge should send a read receipt from the bridge bot when a message has
    # been sent to Google Chat.
    delivery_receipts: false
    # Whether or not delivery errors should be reported as messages in the Matrix room.
    delivery_error_reports: false
    # Whether the bridge should send the message status as a custom com.beeper.message_send_status event.
    message_status_events: true
    # Whether or not created rooms should have federation enabled.
    # If false, created portal rooms will never be federated.
    federate_rooms: false
    # Settings for backfilling messages from Google Chat.
    backfill:
        # Whether or not the Google Chat users of logged in Matrix users should be
        # invited to private chats when backfilling history from Google Chat. This is
        # usually needed to prevent rate limits and to allow timestamp massaging.
        invite_own_puppet: false
        # Number of threads to backfill in threaded spaces in initial backfill.
        initial_thread_limit: 0
        # Number of replies to backfill in each thread in initial backfill.
        initial_thread_reply_limit: 500
        # Number of messages to backfill in non-threaded spaces and DMs in initial backfill.
        initial_nonthread_limit: 1
        # Number of events to backfill in catchup backfill.
        missed_event_limit: 200
        # How many events to request from Google Chat at once in catchup backfill?
        missed_event_page_size: 100
        # If using double puppeting, should notifications be disabled
        # while the initial backfill is in progress?
        disable_notifications: true

    # Set this to true to tell the bridge to re-send m.bridge events to all rooms on the next run.
    # This field will automatically be changed back to false after it,
    # except if the config file is not writable.
    resend_bridge_info: false
    # Whether or not unimportant bridge notices should be sent to the bridge notice room.
    unimportant_bridge_notices: false
    # Whether or not bridge notices should be disabled entirely.
    disable_bridge_notices: true
    # Whether to explicitly set the avatar and room name for private chat portal rooms.
    # If set to `default`, this will be enabled in encrypted rooms and disabled in unencrypted rooms.
    # If set to `always`, all DM rooms will have explicit names and avatars set.
    # If set to `never`, DM rooms will never have names and avatars set.
    private_chat_portal_meta: never

    provisioning:
        # Internal prefix in the appservice web server for the login endpoints.
        prefix: /_matrix/provision
        # Shared secret for integration managers such as mautrix-manager.
        # If set to "generate", a random string will be generated on the next startup.
        # If null, integration manager access to the API will not be possible.
        shared_secret: {{ .ProvisioningSecret }}

    # Permissions for using the bridge.
    # Permitted values:
    #       user - Use the bridge with puppeting.
    #      admin - Use and administrate the bridge.
    # Permitted keys:
    #        * - All Matrix users
    #   domain - All users on that homeserver
    #     mxid - Specific user
    permissions:
        "{{ .UserID }}": "admin"

# Python logging configuration.
#
# See section 16.7.2 of the Python documentation for more info:
# https://docs.python.org/3.6/library/logging.config.html#configuration-dictionary-schema
logging:
    version: 1
    formatters:
        colored:
            (): mautrix_googlechat.util.ColorFormatter
            format: "[%(asctime)s] [%(levelname)s@%(name)s] %(message)s"
        normal:
            format: "[%(asctime)s] [%(levelname)s@%(name)s] %(message)s"
    handlers:
        file:
            class: logging.handlers.RotatingFileHandler
            formatter: normal
            filename: ./logs/mautrix-googlechat.log
            maxBytes: 10485760
            backupCount: 10
        console:
            class: logging.StreamHandler
            formatter: colored
    loggers:
        mau:
            level: DEBUG
        maugclib:
            level: INFO
        aiohttp:
            level: INFO
    root:
        level: DEBUG
        handlers: [file, console]



================================================
FILE: bridgeconfig/gvoice.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for SMS users. Available variables:
    #  .Name - same as phone number in most cases
    #  .Contact.Name - name from contact list
    #  .Contact.FirstName - first name from contact list
    #  .PhoneNumber
    displayname_template: {{ `"{{ or .Contact.Name .Name }}"` }}

{{ setfield . "CommandPrefix" "!gv" -}}
{{ setfield . "DatabaseFileName" "mautrix-gvoice" -}}
{{ setfield . "BridgeTypeName" "Google Voice" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/VOPtYGBzHLRfPTEzGgNMpeKo" -}}
{{ setfield . "DefaultPickleKey" "go.mau.fi/mautrix-gvoice" -}}
{{ setfield . "MaxInitialMessages" 10 -}}
{{ setfield . "MaxBackwardMessages" 100 -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/heisenbridge.tpl.yaml
================================================
id: {{ .AppserviceID }}
url: {{ if .Websocket }}websocket{{ else }}http://{{ .ListenAddr }}:{{ .ListenPort }}{{ end }}
as_token: {{ .ASToken }}
hs_token: {{ .HSToken }}
sender_localpart: {{ .BridgeName }}bot
namespaces:
  users:
  - regex: '@{{ .BridgeName }}_.+:beeper\.local'
    exclusive: true
push_ephemeral: true
heisenbridge:
  media_url: https://matrix.{{ .BeeperDomain }}
  displayname: Heisenbridge



================================================
FILE: bridgeconfig/imessage.tpl.yaml
================================================
# Homeserver details.
homeserver:
    # The address that this appservice can use to connect to the homeserver.
    address: {{ .HungryAddress }}
    # The address to mautrix-wsproxy (which should usually be next to the homeserver behind a reverse proxy).
    # Only the /_matrix/client/unstable/fi.mau.as_sync websocket endpoint is used on this address.
    #
    # Set to null to disable using the websocket. When not using the websocket, make sure hostname and port are set in the appservice section.
    websocket_proxy: {{ if .Websocket }}{{ replace .HungryAddress "https" "wss" }}{{ else }}null{{ end }}
    # How often should the websocket be pinged? Pinging will be disabled if this is zero.
    ping_interval_seconds: 180
    # The domain of the homeserver (also known as server_name, used for MXIDs, etc).
    domain: beeper.local

    # What software is the homeserver running?
    # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
    software: hungry
    # Does the homeserver support https://github.com/matrix-org/matrix-spec-proposals/pull/2246?
    async_media: true

# Application service host/registration related details.
# Changing these values requires regeneration of the registration.
appservice:
    # The hostname and port where this appservice should listen.
    # The default method of deploying mautrix-imessage is using a websocket proxy, so it doesn't need a http server
    # To use a http server instead of a websocket, set websocket_proxy to null in the homeserver section,
    # and set the port below to a real port.
    hostname: {{ if .Websocket }}null{{ else }}{{ .ListenAddr }}{{ end }}
    port: {{ if .Websocket }}null{{ else }}{{ .ListenPort }}{{ end }}
    # Optional TLS certificates to listen for https instead of http connections.
    tls_key: null
    tls_cert: null

    # Database config.
    database:
        # The database type. Only "sqlite3-fk-wal" is supported.
        type: sqlite3-fk-wal
        # SQLite database path. A raw file path is supported, but `file:<path>?_txlock=immediate` is recommended.
        uri: file:{{.DatabasePrefix}}mautrix-imessage.db?_txlock=immediate

    # The unique ID of this appservice.
    id: {{ .AppserviceID }}
    # Appservice bot details.
    bot:
        # Username of the appservice bot.
        username: {{ .BridgeName }}bot
        # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
        # to leave display name/avatar as-is.
        displayname: iMessage bridge bot
        avatar: mxc://maunium.net/tManJEpANASZvDVzvRvhILdX

    # Whether or not to receive ephemeral events via appservice transactions.
    # Requires MSC2409 support (i.e. Synapse 1.22+).
    # You should disable bridge -> sync_with_custom_puppets when this is enabled.
    ephemeral_events: true

    # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
    as_token: {{ .ASToken }}
    hs_token: {{ .HSToken }}

# iMessage connection config
imessage:
    # Available platforms:
    # * mac: Standard Mac connector, requires full disk access and will ask for AppleScript and contacts permission.
    # * ios: Jailbreak iOS connector when using with Brooklyn.
    # * android: Equivalent to ios, but for use with the Android SMS wrapper app.
    # * mac-nosip: Mac without SIP connector, runs Barcelona as a subprocess.
    platform: {{ .Params.imessage_platform }}
    # Path to the Barcelona executable for the mac-nosip connector
    imessage_rest_path: "{{ or .Params.barcelona_path "darwin-barcelona-mautrix" }}"
    # Additional arguments to pass to the mac-nosip connector
    imessage_rest_args: []
    # The mode for fetching contacts in the no-SIP connector.
    # The default mode is `ipc` which will ask Barcelona. However, recent versions of Barcelona have removed contact support.
    # You can specify `mac` to use Contacts.framework directly instead of through Barcelona.
    # You can also specify `disable` to not try to use contacts at all.
    contacts_mode: mac
    # Whether to log the contents of IPC payloads
    log_ipc_payloads: false
    # For the no-SIP connector, hackily set the user account locale before starting Barcelona.
    hacky_set_locale: null
    # A list of environment variables to add for the Barcelona process (as NAME=value strings)
    environment: []
    # Path to unix socket for Barcelona communication.
    unix_socket: mautrix-imessage.sock
    # Interval to ping Barcelona at. The process will exit if Barcelona doesn't respond in time.
    ping_interval_seconds: 15

    bluebubbles_url: {{ .Params.bluebubbles_url }}
    bluebubbles_password: {{ .Params.bluebubbles_password }}

# Segment settings for collecting some debug data.
segment:
    key: null
    user_id: null

hacky_startup_test:
    identifier: null
    message: null
    response_message: null
    key: null
    echo_mode: false

# Bridge config
bridge:
    # The user of the bridge.
    user: "{{ .UserID }}"

    # Localpart template of MXIDs for iMessage users.
    # {{ "{{.}}" }} is replaced with the phone number or email of the iMessage user.
    username_template: {{ .BridgeName }}_{{ "{{.}}" }}
    # Displayname template for iMessage users.
    # {{ "{{.}}" }} is replaced with the contact list name (if available) or username (phone number or email) of the iMessage user.
    displayname_template: "{{ "{{.}}" }}"
    # Should the bridge create a space and add bridged rooms to it?
    personal_filtering_spaces: true

    # Whether or not the bridge should send a read receipt from the bridge bot when a message has been
    # sent to iMessage.
    delivery_receipts: false
    # Whether or not the bridge should send the message status as a custom
    # com.beeper.message_send_status event.
    message_status_events: true
    # Whether or not the bridge should send error notices via m.notice events
    # when a message fails to bridge.
    send_error_notices: false
    # The maximum number of seconds between the message arriving at the
    # homeserver and the bridge attempting to send the message. This can help
    # prevent messages from being bridged a long time after arriving at the
    # homeserver which could cause confusion in the chat history on the remote
    # network. Set to 0 to disable.
    max_handle_seconds: 60
    # Device ID to include in m.bridge data, read by client-integrated Android SMS.
    # Not relevant for standalone bridges nor iMessage.
    device_id: null
    # Whether or not to sync with custom puppets to receive EDUs that are not normally sent to appservices.
    sync_with_custom_puppets: false
    # Whether or not to update the m.direct account data event when double puppeting is enabled.
    # Note that updating the m.direct event is not atomic (except with mautrix-asmux)
    # and is therefore prone to race conditions.
    sync_direct_chat_list: false
    # Shared secret for https://github.com/devture/matrix-synapse-shared-secret-auth
    #
    # If set, double puppeting will be enabled automatically instead of the user
    # having to find an access token and run `login-matrix` manually.
    login_shared_secret: appservice
    # Homeserver URL for the double puppet. If null, will use the URL set in homeserver -> address
    double_puppet_server_url: null
    # Backfill settings
    backfill:
        # Should backfilling be enabled at all?
        enable: true
        # Maximum number of messages to backfill for new portal rooms.
        initial_limit: 100
        # Maximum age of chats to sync in days.
        initial_sync_max_age: 7
        # If a backfilled chat is older than this number of hours, mark it as read even if it's unread on iMessage.
        # Set to -1 to let any chat be unread.
        unread_hours_threshold: 720
        # Use MSC2716 for backfilling?
        #
        # This requires a server with MSC2716 support, which is currently an experimental feature in Synapse.
        # It can be enabled by setting experimental_features -> msc2716_enabled to true in homeserver.yaml.
        msc2716: true
    # Whether or not the bridge should periodically resync chat and contact info.
    periodic_sync: true
    # Should the bridge look through joined rooms to find existing portals if the database has none?
    # This can be used to recover from bridge database loss.
    find_portals_if_db_empty: false
    # Media viewer settings. See https://gitlab.com/beeper/media-viewer for more info.
    # Used to send media viewer links instead of full files for attachments that are too big for MMS.
    media_viewer:
        # The address to the media viewer. If null, media viewer links will not be used.
        url: https://media.beeper.com
        # The homeserver domain to pass to the media viewer to use for downloading media.
        # If null, will use the server name configured in the homeserver section.
        homeserver: {{ .BeeperDomain }}
        # The minimum number of bytes in a file before the bridge switches to using the media viewer when sending MMS.
        # Note that for unencrypted files, this will use a direct link to the homeserver rather than the media viewer.
        sms_min_size: 409600
        # Same as above, but for iMessages.
        imessage_min_size: 52428800
        # Template text when inserting media viewer URLs.
        # %s is replaced with the actual URL.
        template: "Full size attachment: %s"
    # Should we convert heif images to jpeg before re-uploading? This increases
    # compatibility, but adds generation loss (reduces quality).
    convert_heif: false
    # Should we convert tiff images to jpeg before re-uploading? This increases
    # compatibility, but adds generation loss (reduces quality).
    convert_tiff: true
    # Modern Apple devices tend to use h265 encoding for video, which is a licensed standard and therefore not
    # supported by most major browsers. If enabled, all video attachments will be converted according to the
    # ffmpeg args.
    convert_video:
        enabled: false
        # Convert to h264 format (supported by all major browsers) at decent quality while retaining original
        # audio. Modify these args to do whatever encoding/quality you want.
        ffmpeg_args: ["-c:v", "libx264", "-preset", "faster", "-crf", "22", "-c:a", "copy"]
        extension: "mp4"
        mime_type: "video/mp4"
    # The prefix for commands.
    command_prefix: "!im"
    # Should we rewrite the sender in a DM to match the chat GUID?
    # This is helpful when the sender ID shifts depending on the device they use, since
    # the bridge is unable to add participants to the chat post-creation.
    force_uniform_dm_senders: true
    # Should SMS chats always be in the same room as iMessage chats with the same phone number?
    disable_sms_portals: false
    # iMessage has weird IDs for group chats, so getting all messages in the same MMS group chat into the same Matrix room
    # may require rerouting some messages based on the fake ReplyToGUID that iMessage adds.
    reroute_mms_group_replies: false
    # Whether or not created rooms should have federation enabled.
    # If false, created portal rooms will never be federated.
    federate_rooms: false
    # Send captions in the same message as images using MSC2530?
    # This is currently not supported in most clients.
    caption_in_message: true
    # Should the bridge explicitly set the avatar and room name for private chat portal rooms?
    # This is implicitly enabled in encrypted rooms.
    private_chat_portal_meta: never

    # End-to-bridge encryption support options.
    # See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html
    encryption:
        # Allow encryption, work in group chat rooms with e2ee enabled
        allow: true
        # Default to encryption, force-enable encryption in all portals the bridge creates
        # This will cause the bridge bot to be in private chats for the encryption to work properly.
        default: true
        # Whether or not to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
        appservice: true
        # Require encryption, drop any unencrypted messages.
        require: true
        # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
        # You must use a client that supports requesting keys from other users to use this feature.
        allow_key_sharing: true
        # Options for deleting megolm sessions from the bridge.
        delete_keys:
            # Beeper-specific: delete outbound sessions when hungryserv confirms
            # that the user has uploaded the key to key backup.
            delete_outbound_on_ack: true
            # Don't store outbound sessions in the inbound table.
            dont_store_outbound: false
            # Ratchet megolm sessions forward after decrypting messages.
            ratchet_on_decrypt: true
            # Delete fully used keys (index >= max_messages) after decrypting messages.
            delete_fully_used_on_decrypt: true
            # Delete previous megolm sessions from same device when receiving a new one.
            delete_prev_on_new_session: true
            # Delete megolm sessions received from a device when the device is deleted.
            delete_on_device_delete: true
            # Periodically delete megolm sessions when 2x max_age has passed since receiving the session.
            periodically_delete_expired: true
        # What level of device verification should be required from users?
        #
        # Valid levels:
        #   unverified - Send keys to all device in the room.
        #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
        #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
        #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
        #                           Note that creating user signatures from the bridge bot is not currently possible.
        #   verified - Require manual per-device verification
        #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
        verification_levels:
            # Minimum level for which the bridge should send keys to when bridging messages from WhatsApp to Matrix.
            receive: cross-signed-tofu
            # Minimum level that the bridge should accept for incoming Matrix messages.
            send: cross-signed-tofu
            # Minimum level that the bridge should require for accepting key requests.
            share: cross-signed-tofu
        # Options for Megolm room key rotation. These options allow you to
        # configure the m.room.encryption event content. See:
        # https://spec.matrix.org/v1.3/client-server-api/#mroomencryption for
        # more information about that event.
        rotation:
            # Enable custom Megolm room key rotation settings. Note that these
            # settings will only apply to rooms created after this option is
            # set.
            enable_custom: true
            # The maximum number of milliseconds a session should be used
            # before changing it. The Matrix spec recommends 604800000 (a week)
            # as the default.
            milliseconds: 2592000000
            # The maximum number of messages that should be sent with a given a
            # session before changing it. The Matrix spec recommends 100 as the
            # default.
            messages: 10000

            # Disable rotating keys when a user's devices change?
            # You should not enable this option unless you understand all the implications.
            disable_device_change_key_rotation: true

    # Settings for relay mode
    relay:
        # Whether relay mode should be allowed.
        enabled: false
        # A list of user IDs and server names who are allowed to be relayed through this bridge. Use * to allow everyone.
        whitelist: []

# Logging config. See https://github.com/tulir/zeroconfig for details.
logging:
    min_level: debug
    writers:
    - type: stdout
      format: pretty-colored
    - type: file
      format: json
      filename: ./logs/mautrix-imessage.log
      max_size: 100
      max_backups: 10
      compress: false

# This may be used by external config managers. mautrix-imessage does not read it, but will carry it across configuration migrations.
revision: 0



================================================
FILE: bridgeconfig/imessagego.tpl.yaml
================================================
# Homeserver details.
homeserver:
    # The address that this appservice can use to connect to the homeserver.
    address: {{ .HungryAddress }}
    # The domain of the homeserver (also known as server_name, used for MXIDs, etc).
    domain: beeper.local

    # What software is the homeserver running?
    # Standard Matrix homeservers like Synapse, Dendrite and Conduit should just use "standard" here.
    software: hungry
    # The URL to push real-time bridge status to.
    # If set, the bridge will make POST requests to this URL whenever a user's discord connection state changes.
    # The bridge will use the appservice as_token to authorize requests.
    status_endpoint: null
    # Endpoint for reporting per-message status.
    message_send_checkpoint_endpoint: null
    # Does the homeserver support https://github.com/matrix-org/matrix-spec-proposals/pull/2246?
    async_media: true

    # Should the bridge use a websocket for connecting to the homeserver?
    # The server side is currently not documented anywhere and is only implemented by mautrix-wsproxy,
    # mautrix-asmux (deprecated), and hungryserv (proprietary).
    websocket: {{ .Websocket }}
    # How often should the websocket be pinged? Pinging will be disabled if this is zero.
    ping_interval_seconds: 180

# Application service host/registration related details.
# Changing these values requires regeneration of the registration.
appservice:
    # The address that the homeserver can use to connect to this appservice.
    address: null

    # The hostname and port where this appservice should listen.
    hostname: {{ if .Websocket }}null{{ else }}{{ .ListenAddr }}{{ end }}
    port: {{ if .Websocket }}null{{ else }}{{ .ListenPort }}{{ end }}

    # Database config.
    database:
        # The database type. Only "sqlite3-fk-wal" is supported.
        type: sqlite3-fk-wal
        # SQLite database path. A raw file path is supported, but `file:<path>?_txlock=immediate` is recommended.
        uri: file:{{.DatabasePrefix}}beeper-imessage.db?_txlock=immediate

    # The unique ID of this appservice.
    id: {{ .AppserviceID }}
    # Appservice bot details.
    bot:
        # Username of the appservice bot.
        username: {{ .BridgeName }}bot
        # Display name and avatar for bot. Set to "remove" to remove display name/avatar, leave empty
        # to leave display name/avatar as-is.
        displayname: iMessage bridge bot
        avatar: mxc://maunium.net/tManJEpANASZvDVzvRvhILdX

    # Whether or not to receive ephemeral events via appservice transactions.
    # Requires MSC2409 support (i.e. Synapse 1.22+).
    # You should disable bridge -> sync_with_custom_puppets when this is enabled.
    ephemeral_events: true

    # Authentication tokens for AS <-> HS communication. Autogenerated; do not modify.
    as_token: {{ .ASToken }}
    hs_token: {{ .HSToken }}

# Segment-compatible analytics endpoint for tracking some events, like provisioning API login and encryption errors.
analytics:
    # Hostname of the tracking server. The path is hardcoded to /v1/track
    host: api.segment.io
    # API key to send with tracking requests. Tracking is disabled if this is null.
    token: null
    # Optional user ID for tracking events. If null, defaults to using Matrix user ID.
    user_id: null

imessage:
    device_name: {{ or .Params.device_name "Beeper (self-hosted)" }}

# Bridge config
bridge:
    # Localpart template of MXIDs for iMessage users.
    username_template: {{ .BridgeName }}_{{ "{{.}}" }}
    # Displayname template for iMessage users.
    displayname_template: "{{ "{{.}}" }}"

    # A URL to fetch validation data from. Use this option or the nac_plist option
    nac_validation_data_url: {{ or .Params.nac_url "https://registration-relay.beeper.com" }}
    # Optional auth token to use when fetching validation data. If null, defaults to passing the as_token.
    nac_validation_data_token: {{ .Params.nac_token }}
    nac_validation_is_relay: true

    # Servers to always allow double puppeting from
    double_puppet_server_map:
        {{ .BeeperDomain }}: {{ .HungryAddress }}
    # Allow using double puppeting from any server with a valid client .well-known file.
    double_puppet_allow_discovery: false
    # Shared secrets for https://github.com/devture/matrix-synapse-shared-secret-auth
    #
    # If set, double puppeting will be enabled automatically for local users
    # instead of users having to find an access token and run `login-matrix`
    # manually.
    login_shared_secret_map:
        {{ .BeeperDomain }}: "as_token:{{ .ASToken }}"

    # Should the bridge create a space and add bridged rooms to it?
    personal_filtering_spaces: true
    # Whether or not the bridge should send a read receipt from the bridge bot when a message has been
    # sent to iMessage.
    delivery_receipts: false
    # Whether or not the bridge should send the message status as a custom
    # com.beeper.message_send_status event.
    message_status_events: true
    # Whether or not the bridge should send error notices via m.notice events
    # when a message fails to bridge.
    send_error_notices: false
    # Enable notices about various things in the bridge management room?
    enable_bridge_notices: true
    # Enable less important notices (sent with m.notice) in the bridge management room?
    unimportant_bridge_notices: true
    # The maximum number of seconds between the message arriving at the
    # homeserver and the bridge attempting to send the message. This can help
    # prevent messages from being bridged a long time after arriving at the
    # homeserver which could cause confusion in the chat history on the remote
    # network. Set to 0 to disable.
    max_handle_seconds: 0
    # Should we convert heif images to jpeg before re-uploading? This increases
    # compatibility, but adds generation loss (reduces quality).
    convert_heif: false
    # Should we convert tiff images to jpeg before re-uploading? This increases
    # compatibility, but adds generation loss (reduces quality).
    convert_tiff: true
    # Modern Apple devices tend to use h265 encoding for video, which is a licensed standard and therefore not
    # supported by most major browsers. If enabled, all video attachments will be converted according to the
    # ffmpeg args.
    convert_mov: true
    # The prefix for commands.
    command_prefix: "!im"
    # Whether or not created rooms should have federation enabled.
    # If false, created portal rooms will never be federated.
    federate_rooms: false
    # Whether to explicitly set the avatar and room name for private chat portal rooms.
    # If set to `default`, this will be enabled in encrypted rooms and disabled in unencrypted rooms.
    # If set to `always`, all DM rooms will have explicit names and avatars set.
    # If set to `never`, DM rooms will never have names and avatars set.
    private_chat_portal_meta: never
    # Should iMessage reply threads be mapped to Matrix threads? If false, iMessage reply threads will be bridged
    # as replies to the previous message in the thread.
    matrix_threads: false

    # End-to-bridge encryption support options.
    # See https://docs.mau.fi/bridges/general/end-to-bridge-encryption.html
    encryption:
        # Allow encryption, work in group chat rooms with e2ee enabled
        allow: true
        # Default to encryption, force-enable encryption in all portals the bridge creates
        # This will cause the bridge bot to be in private chats for the encryption to work properly.
        default: true
        # Whether or not to use MSC2409/MSC3202 instead of /sync long polling for receiving encryption-related data.
        appservice: true
        # Require encryption, drop any unencrypted messages.
        require: true
        # Enable key sharing? If enabled, key requests for rooms where users are in will be fulfilled.
        # You must use a client that supports requesting keys from other users to use this feature.
        allow_key_sharing: true
        # Options for deleting megolm sessions from the bridge.
        delete_keys:
            # Beeper-specific: delete outbound sessions when hungryserv confirms
            # that the user has uploaded the key to key backup.
            delete_outbound_on_ack: true
            # Don't store outbound sessions in the inbound table.
            dont_store_outbound: false
            # Ratchet megolm sessions forward after decrypting messages.
            ratchet_on_decrypt: true
            # Delete fully used keys (index >= max_messages) after decrypting messages.
            delete_fully_used_on_decrypt: true
            # Delete previous megolm sessions from same device when receiving a new one.
            delete_prev_on_new_session: true
            # Delete megolm sessions received from a device when the device is deleted.
            delete_on_device_delete: true
            # Periodically delete megolm sessions when 2x max_age has passed since receiving the session.
            periodically_delete_expired: true
        # What level of device verification should be required from users?
        #
        # Valid levels:
        #   unverified - Send keys to all device in the room.
        #   cross-signed-untrusted - Require valid cross-signing, but trust all cross-signing keys.
        #   cross-signed-tofu - Require valid cross-signing, trust cross-signing keys on first use (and reject changes).
        #   cross-signed-verified - Require valid cross-signing, plus a valid user signature from the bridge bot.
        #                           Note that creating user signatures from the bridge bot is not currently possible.
        #   verified - Require manual per-device verification
        #              (currently only possible by modifying the `trust` column in the `crypto_device` database table).
        verification_levels:
            # Minimum level for which the bridge should send keys to when bridging messages from iMessage to Matrix.
            receive: cross-signed-tofu
            # Minimum level that the bridge should accept for incoming Matrix messages.
            send: cross-signed-tofu
            # Minimum level that the bridge should require for accepting key requests.
            share: cross-signed-tofu
        # Options for Megolm room key rotation. These options allow you to
        # configure the m.room.encryption event content. See:
        # https://spec.matrix.org/v1.3/client-server-api/#mroomencryption for
        # more information about that event.
        rotation:
            # Enable custom Megolm room key rotation settings. Note that these
            # settings will only apply to rooms created after this option is
            # set.
            enable_custom: true
            # The maximum number of milliseconds a session should be used
            # before changing it. The Matrix spec recommends 604800000 (a week)
            # as the default.
            milliseconds: 2592000000
            # The maximum number of messages that should be sent with a given a
            # session before changing it. The Matrix spec recommends 100 as the
            # default.
            messages: 10000

            # Disable rotating keys when a user's devices change?
            # You should not enable this option unless you understand all the implications.
            disable_device_change_key_rotation: true

    # Settings for provisioning API
    provisioning:
        # Prefix for the provisioning API paths.
        prefix: /_matrix/provision
        # Shared secret for authentication. If set to "generate", a random secret will be generated,
        # or if set to "disable", the provisioning API will be disabled.
        shared_secret: {{ .ProvisioningSecret }}

    # Permissions for using the bridge.
    # Permitted values:
    #     user - Access to use the bridge to chat with a WhatsApp account.
    #    admin - User level and some additional administration tools
    # Permitted keys:
    #        * - All Matrix users
    #   domain - All users on that homeserver
    #     mxid - Specific user
    permissions:
        "{{ .UserID }}": admin

# Logging config. See https://github.com/tulir/zeroconfig for details.
logging:
    min_level: debug
    writers:
    - type: stdout
      format: pretty-colored
    - type: file
      format: json
      filename: ./logs/beeper-imessage.log
      max_size: 100
      max_backups: 10
      compress: false



================================================
FILE: bridgeconfig/linkedin.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for LinkedIn users.
    # .FirstName is replaced with the first name
    # .LastName is replaced with the last name
    # .Organization is replaced with the organization name
    displayname_template: {{ `"{{ with .Organization }}{{ . }}{{ else }}{{ .FirstName }} {{ .LastName }}{{ end }}"` }}

    sync:
        # Number of most recently active dialogs to check when syncing chats.
        # Set to 0 to remove limit.
        update_limit: 0
        # Number of most recently active dialogs to create portals for when syncing
        # chats.
        # Set to 0 to remove limit.
        create_limit: 10

{{ setfield . "CommandPrefix" "!linkedin" -}}
{{ setfield . "DatabaseFileName" "mautrix-linkedin" -}}
{{ setfield . "BridgeTypeName" "LinkedIn" -}}
{{ setfield . "BridgeTypeIcon" "mxc://nevarro.space/cwsWnmeMpWSMZLUNblJHaIvP" -}}
{{ setfield . "DefaultPickleKey" "mautrix.bridge.e2ee" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/meta.tpl.yaml
================================================
# Network-specific config options
network:
    # Which service is this bridge for? Available options:
    # * unset - allow users to pick any service when logging in (except facebook-tor)
    # * facebook - connect to FB Messenger via facebook.com
    # * facebook-tor - connect to FB Messenger via facebookwkhpilnemxj7asaniu7vnjjbiltxjqhye3mhbshg7kx5tfyd.onion
    #                  (note: does not currently proxy media downloads)
    # * messenger - connect to FB Messenger via messenger.com (can be used with the facebook side deactivated)
    # * instagram - connect to Instagram DMs via instagram.com
    #
    # Remember to change the appservice id, bot profile info, bridge username_template and management_room_text too.
    mode: {{ .Params.meta_platform }}
    # Should users be allowed to pick messenger.com login when mode is set to `facebook`?
    allow_messenger_com_on_fb: true
    # When in Instagram mode, should the bridge connect to WhatsApp servers for encrypted chats?
    # In FB/Messenger mode encryption is always enabled, this option only affects Instagram mode.
    ig_e2ee: false
    # Displayname template for FB/IG users. Available variables:
    #  .DisplayName - The display name set by the user.
    #  .Username - The username set by the user.
    #  .ID - The internal user ID of the user.
    displayname_template: {{ `'{{or .DisplayName .Username "Unknown user"}}'` }}
    # Static proxy address (HTTP or SOCKS5) for connecting to Meta.
    proxy:
    # HTTP endpoint to request new proxy address from, for dynamically assigned proxies.
    # The endpoint must return a JSON body with a string field called proxy_url.
    get_proxy_from:
    # Minimum interval between full reconnects in seconds, default is 1 hour
    min_full_reconnect_interval_seconds: 3600
    # Interval to force refresh the connection (full reconnect), default is 20 hours. Set 0 to disable force refreshes.
    force_refresh_interval_seconds: 72000
    # Should connection state be cached to allow quicker restarts?
    cache_connection_state: false
    # Disable fetching XMA media (reels, stories, etc) when backfilling.
    disable_xma_backfill: true
    # Disable fetching XMA media entirely.
    disable_xma_always: false

{{ setfield . "DatabaseFileName" "mautrix-meta" -}}
{{ setfield . "DefaultPickleKey" "mautrix.bridge.e2ee" -}}
{{ if eq .Params.meta_platform "facebook" "facebook-tor" "messenger" -}}
    {{ setfield . "CommandPrefix" "!fb" -}}
    {{ setfield . "BridgeTypeName" "Facebook" -}}
    {{ setfield . "BridgeTypeIcon" "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak" -}}
{{ else if eq .Params.meta_platform "instagram" -}}
    {{ setfield . "CommandPrefix" "!ig" -}}
    {{ setfield . "BridgeTypeName" "Instagram" -}}
    {{ setfield . "BridgeTypeIcon" "mxc://maunium.net/JxjlbZUlCPULEeHZSwleUXQv" -}}
{{ else -}}
    {{ setfield . "CommandPrefix" "!meta" -}}
    {{ setfield . "BridgeTypeName" "Meta" -}}
    {{ setfield . "BridgeTypeIcon" "mxc://maunium.net/DxpVrwwzPUwaUSazpsjXgcKB" -}}
{{ end -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/signal.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for Signal users.
    displayname_template: {{ `'{{or .Nickname .ContactName .ProfileName .PhoneNumber "Unknown user" }}'` }}
    # Should avatars from the user's contact list be used? This is not safe on multi-user instances.
    use_contact_avatars: true
    # Should the bridge sync ghost user info even if profile fetching fails? This is not safe on multi-user instances.
    use_outdated_profiles: true
    # Should the Signal user's phone number be included in the room topic in private chat portal rooms?
    number_in_topic: true
    # Default device name that shows up in the Signal app.
    device_name: {{ or .Params.device_name "Beeper (self-hosted)" }}
    # Avatar image for the Note to Self room.
    note_to_self_avatar: mxc://maunium.net/REBIVrqjZwmaWpssCZpBlmlL
    # Format for generating URLs from location messages for sending to Signal.
    # Google Maps: 'https://www.google.com/maps/place/%[1]s,%[2]s'
    # OpenStreetMap: 'https://www.openstreetmap.org/?mlat=%[1]s&mlon=%[2]s'
    location_format: 'https://www.google.com/maps/place/%[1]s,%[2]s'
    # Should view-once messages disappear shortly after sending a read receipt on Matrix?
    disappear_view_once: true

{{ setfield . "CommandPrefix" "!signal" -}}
{{ setfield . "DatabaseFileName" "mautrix-signal" -}}
{{ setfield . "BridgeTypeName" "Signal" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/wPJgTQbZOtpBFmDNkiNEMDUp" -}}
{{ setfield . "DefaultPickleKey" "mautrix.bridge.e2ee" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/slack.tpl.yaml
================================================
network:
    # Displayname template for Slack users. Available variables:
    #  .Name - The username of the user
    #  .ID - The internal ID of the user
    #  .IsBot - Whether the user is a bot
    #  .Profile.DisplayName - The username or real name of the user (depending on settings)
    # Variables only available for users (not bots):
    #  .TeamID - The internal ID of the workspace the user is in
    #  .TZ - The timezone region of the user (e.g. Europe/London)
    #  .TZLabel - The label of the timezone of the user (e.g. Greenwich Mean Time)
    #  .TZOffset - The UTC offset of the timezone of the user (e.g. 0)
    #  .Profile.RealName - The real name of the user
    #  .Profile.FirstName - The first name of the user
    #  .Profile.LastName - The last name of the user
    #  .Profile.Title - The job title of the user
    #  .Profile.Pronouns - The pronouns of the user
    #  .Profile.Email - The email address of the user
    #  .Profile.Phone - The formatted phone number of the user
    displayname_template: '{{ `{{or .Profile.DisplayName .Profile.RealName .Name}}{{if .IsBot}} (bot){{end}}` }}'
    # Channel name template for Slack channels (all types). Available variables:
    #  .Name - The name of the channel
    #  .TeamName - The name of the team the channel is in
    #  .TeamDomain - The Slack subdomain of the team the channel is in
    #  .ID - The internal ID of the channel
    #  .IsNoteToSelf - Whether the channel is a DM with yourself
    #  .IsGeneral - Whether the channel is the #general channel
    #  .IsChannel - Whether the channel is a channel (rather than a DM)
    #  .IsPrivate - Whether the channel is private
    #  .IsIM - Whether the channel is a one-to-one DM
    #  .IsMpIM - Whether the channel is a group DM
    #  .IsShared - Whether the channel is shared with another workspace.
    #  .IsExtShared - Whether the channel is shared with an external organization.
    #  .IsOrgShared - Whether the channel is shared with an organization in the same enterprise grid.
    channel_name_template: '{{ `{{if or .IsNoteToSelf (and (not .IsIM) (not .IsMpIM))}}{{if and .IsChannel (not .IsPrivate)}}#{{end}}{{.Name}}{{if .IsNoteToSelf}} (you){{end}}{{end}}` }}'
    # Displayname template for Slack workspaces. Available variables:
    #  .Name - The name of the team
    #  .Domain - The Slack subdomain of the team
    #  .ID - The internal ID of the team
    team_name_template: '{{ `{{.Name}}` }}'
    # Should incoming custom emoji reactions be bridged as mxc:// URIs?
    # If set to false, custom emoji reactions will be bridged as the shortcode instead, and the image won't be available.
    custom_emoji_reactions: true
    # Should channels and group DMs have the workspace icon as the Matrix room avatar?
    workspace_avatar_in_rooms: false
    # Number of participants to sync in channels (doesn't affect group DMs)
    participant_sync_count: 5
    # Should channel participants only be synced when creating the room?
    # If you want participants to always be accurately synced, set participant_sync_count to a high value and this to false.
    participant_sync_only_on_create: true
    # Should channel portals be muted by default?
    mute_channels_by_default: true
    # Options for backfilling messages from Slack.
    backfill:
        # Number of conversations to fetch from Slack when syncing workspace.
        # This option applies even if message backfill is disabled below.
        # If set to -1, all chats in the client.boot response will be bridged, and nothing will be fetched separately.
        conversation_count: -1

{{ setfield . "CommandPrefix" "!slack" -}}
{{ setfield . "DatabaseFileName" "mautrix-slack" -}}
{{ setfield . "BridgeTypeName" "Slack" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/pVtzLmChZejGxLqmXtQjFxem" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/telegram.tpl.yaml
================================================
# Network-specific config options
network:
    # Get your own API keys at https://my.telegram.org/apps
    api_id: {{ .Params.api_id }}
    api_hash: {{ .Params.api_hash }}

    # Device info shown in the Telegram device list.
    device_info:
        device_model: {{ or .Params.device_name "Beeper (self-hosted)" }}
        system_version:
        app_version: auto
        lang_code: en
        system_lang_code: en

    # Settings for converting animated stickers.
    animated_sticker:
        # Format to which animated stickers should be converted.
        #
        # disable - no conversion, send as-is (gzipped lottie)
        # png -     converts to non-animated png (fastest),
        # gif -     converts to animated gif
        # webm -    converts to webm video, requires ffmpeg executable with vp9 codec
        #           and webm container support
        # webp -    converts to animated webp, requires ffmpeg executable with webp
        #           codec/container support
        target: webp
        # Should video stickers be converted to the specified format as well?
        convert_from_webm: false
        # Arguments for converter. All converters take width and height.
        args:
            width: 256
            height: 256
            fps: 25 # only for webm, webp and gif (2, 5, 10, 20 or 25 recommended)

    # Maximum number of pixels in an image before sending to Telegram as a
    # document. Defaults to 4096x4096 = 16777216.
    image_as_file_pixels: 16777216

    # Should view-once messages be disabled entirely?
    disable_view_once: false
    # Should disappearing messages be disabled entirely?
    disable_disappearing: false

    # Settings for syncing the member list for portals.
    member_list:
        # Maximum number of members to sync per portal when starting up. Other
        # members will be synced when they send messages. The maximum is 10000,
        # after which the Telegram server will not send any more members.
        #
        # -1 means no limit (which means it's limited to 10000 by the server)
        max_initial_sync: 20
        # Whether or not to sync the member list in broadcast channels. If
        # disabled, members will still be synced when they send messages.
        #
        # If no channel admins have logged into the bridge, the bridge won't be
        # able to sync the member list regardless of this setting.
        sync_broadcast_channels: false
        # Whether or not to skip deleted members when syncing members.
        skip_deleted: true
    # Maximum number of participants in chats to bridge. Only applies when the
    # portal is being created. If there are more members when trying to create a
    # room, the room creation will be cancelled.
    #
    # -1 means no limit (which means all chats can be bridged)
    max_member_count: 10000

    # Settings for pings to the Telegram server.
    ping:
        # The interval (in seconds) between pings.
        interval_seconds: 30
        # The timeout (in seconds) for a single ping.
        timeout_seconds: 10

    sync:
        # Number of most recently active dialogs to check when syncing chats.
        # Set to 0 to remove limit.
        update_limit: 0
        # Number of most recently active dialogs to create portals for when syncing
        # chats.
        # Set to 0 to remove limit.
        create_limit: 15
        # Whether or not to sync and create portals for direct chats at startup.
        direct_chats: true

    # Should the bridge send all unicode reactions as custom emoji reactions to
    # Telegram? By default, the bridge only uses custom emojis for unicode emojis
    # that aren't allowed in reactions.
    always_custom_emoji_reaction: false

    # The avatar to use for the Telegram Saved Messages chat
    saved_message_avatar: mxc://maunium.net/XhhfHoPejeneOngMyBbtyWDk

    # Create a new room and tombstone the old one when upgrading rooms
    always_tombstone_on_supergroup_migration: false

{{ setfield . "CommandPrefix" "!tg" -}}
{{ setfield . "DatabaseFileName" "mautrix-telegram" -}}
{{ setfield . "BridgeTypeName" "Telegram" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/tJCRmUyJDsgRNgqhOgoiHWbX" -}}
{{ setfield . "DefaultPickleKey" "mautrix.bridge.e2ee" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/twitter.tpl.yaml
================================================
# Network-specific config options
network:
    # Displayname template for Twitter users.
    #   .DisplayName is replaced with the display name of the Twitter user.
    #   .Username is replaced with the username of the Twitter user.
    displayname_template: {{ `"{{ .DisplayName }}"` }}

    # Maximum number of conversations to sync on startup
    conversation_sync_limit: 20

    # Should the bridge cache sessions instead of resyncing chats on every restart?
    cache_session: true

    # Should the bridge use "X" instead of "Twitter" in certain places,
    # such as the management room welcome message and MSC2346 bridge info?
    x: false

{{ setfield . "CommandPrefix" "!tw" -}}
{{ setfield . "DatabaseFileName" "mautrix-twitter" -}}
{{ setfield . "BridgeTypeName" "Twitter" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/HVHcnusJkQcpVcsVGZRELLCn" -}}
{{ setfield . "DefaultPickleKey" "mautrix.bridge.e2ee" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: bridgeconfig/whatsapp.tpl.yaml
================================================
# Network-specific config options
network:
    # Device name that's shown in the "WhatsApp Web" section in the mobile app.
    os_name: Beeper (self-hosted)
    # Browser name that determines the logo shown in the mobile app.
    # Must be "unknown" for a generic icon or a valid browser name if you want a specific icon.
    # List of valid browser names: https://github.com/tulir/whatsmeow/blob/efc632c008604016ddde63bfcfca8de4e5304da9/binary/proto/def.proto#L43-L64
    browser_name: unknown

    # Proxy to use for all WhatsApp connections.
    proxy: null
    # Alternative to proxy: an HTTP endpoint that returns the proxy URL to use for WhatsApp connections.
    get_proxy_url: null
    # Whether the proxy options should only apply to the login websocket and not to authenticated connections.
    proxy_only_login: false

    # Displayname template for WhatsApp users.
    #  .PushName     - nickname set by the WhatsApp user
    #  .BusinessName - validated WhatsApp business name
    #  .Phone        - phone number (international format)
    #  .FullName     - Name you set in the contacts list
    displayname_template: {{ `'{{or .FullName .BusinessName .PushName .Phone .RedactedPhone "Unknown user"}}'` }}

    # Should incoming calls send a message to the Matrix room?
    call_start_notices: true
    # Should another user's cryptographic identity changing send a message to Matrix?
    identity_change_notices: false
    # Send the presence as "available" to whatsapp when users start typing on a portal.
    # This works as a workaround for homeservers that do not support presence, and allows
    # users to see when the whatsapp user on the other side is typing during a conversation.
    send_presence_on_typing: false
    # Should WhatsApp status messages be bridged into a Matrix room?
    # Disabling this won't affect already created status broadcast rooms.
    enable_status_broadcast: true
    # Should sending WhatsApp status messages be allowed?
    # This can cause issues if the user has lots of contacts, so it's disabled by default.
    disable_status_broadcast_send: true
    # Should the status broadcast room be muted and moved into low priority by default?
    # This is only applied when creating the room, the user can unmute it later.
    mute_status_broadcast: true
    # Tag to apply to the status broadcast room.
    status_broadcast_tag: m.lowpriority
    # Should the bridge use thumbnails from WhatsApp?
    # They're disabled by default due to very low resolution.
    whatsapp_thumbnail: false
    # Should the bridge detect URLs in outgoing messages, ask the homeserver to generate a preview,
    # and send it to WhatsApp? URL previews can always be sent using the `com.beeper.linkpreviews`
    # key in the event content even if this is disabled.
    url_previews: false
    # Should the bridge always send "active" delivery receipts (two gray ticks on WhatsApp)
    # even if the user isn't marked as online (e.g. when presence bridging isn't enabled)?
    #
    # By default, the bridge acts like WhatsApp web, which only sends active delivery
    # receipts when it's in the foreground.
    force_active_delivery_receipts: false
    # Settings for converting animated stickers.
    animated_sticker:
        # Format to which animated stickers should be converted.
        # disable - No conversion, just unzip and send raw lottie JSON
        # png - converts to non-animated png (fastest)
        # gif - converts to animated gif
        # webm - converts to webm video, requires ffmpeg executable with vp9 codec and webm container support
        # webp - converts to animated webp, requires ffmpeg executable with webp codec/container support
        target: webp
        # Arguments for converter. All converters take width and height.
        args:
            width: 320
            height: 320
            fps: 25 # only for webm, webp and gif (2, 5, 10, 20 or 25 recommended)

    # Settings for handling history sync payloads.
    history_sync:
        # How many conversations should the bridge create after login?
        # If -1, all conversations received from history sync will be bridged.
        # Other conversations will be backfilled on demand when receiving a message.
        max_initial_conversations: -1
        # Should the bridge request a full sync from the phone when logging in?
        # This bumps the size of history syncs from 3 months to 1 year.
        request_full_sync: true
        # Configuration parameters that are sent to the phone along with the request full sync flag.
        # By default, (when the values are null or 0), the config isn't sent at all.
        full_sync_config:
            # Number of days of history to request.
            # The limit seems to be around 3 years, but using higher values doesn't break.
            days_limit: 1825
            # This is presumably the maximum size of the transferred history sync blob, which may affect what the phone includes in the blob.
            size_mb_limit: 512
            # This is presumably the local storage quota, which may affect what the phone includes in the history sync blob.
            storage_quota_mb: 16384
        # Settings for media requests. If the media expired, then it will not be on the WA servers.
        # Media can always be requested by reacting with the ♻️ (recycle) emoji.
        # These settings determine if the media requests should be done automatically during or after backfill.
        media_requests:
            # Should the expired media be automatically requested from the server as part of the backfill process?
            auto_request_media: true
            # Whether to request the media immediately after the media message is backfilled ("immediate")
            # or at a specific time of the day ("local_time").
            request_method: immediate
            # If request_method is "local_time", what time should the requests be sent (in minutes after midnight)?
            request_local_time: 120
            # Maximum number of media request responses to handle in parallel per user.
            max_async_handle: 2

{{ setfield . "CommandPrefix" "!wa" -}}
{{ setfield . "DatabaseFileName" "mautrix-whatsapp" -}}
{{ setfield . "BridgeTypeName" "WhatsApp" -}}
{{ setfield . "BridgeTypeIcon" "mxc://maunium.net/NeXNQarUbrlYBiPCpprYsRqr" -}}
{{ setfield . "DefaultPickleKey" "maunium.net/go/mautrix-whatsapp" -}}
{{ template "bridgev2.tpl.yaml" . }}



================================================
FILE: cli/hyper/link.go
================================================
package hyper

import (
	"fmt"

	"github.com/fatih/color"
)

const OSC = "\x1b]"
const OSC8 = OSC + "8"
const ST = "\x07" // or "\x1b\\"
const URLTemplate = OSC8 + ";%s;%s" + ST + "%s" + OSC8 + ";;" + ST

func Link(text string, url string, important bool) string {
	if color.NoColor {
		if !important {
			return text
		}
		return fmt.Sprintf("%s (%s)", text, url)
	}
	params := ""
	return fmt.Sprintf(URLTemplate, params, url, text)
}



================================================
FILE: cli/interactive/flag.go
================================================
package interactive

import (
	"fmt"

	"github.com/AlecAivazis/survey/v2"
	"github.com/urfave/cli/v2"
)

type Flag struct {
	cli.Flag
	Survey    survey.Prompt
	Validator survey.Validator
	Transform survey.Transformer
}

type settableContext struct {
	*cli.Context
}

func (sc *settableContext) WriteAnswer(field string, value interface{}) error {
	switch typedValue := value.(type) {
	case string:
		return sc.Set(field, typedValue)
	case []string:
		for _, item := range typedValue {
			if err := sc.Set(field, item); err != nil {
				return err
			}
		}
		return nil
	case int, uint, int8, uint8, int16, uint16, int32, uint32, int64, uint64:
		return sc.Set(field, fmt.Sprintf("%d", typedValue))
	default:
		return fmt.Errorf("unsupported type %T", value)
	}
}

func Ask(ctx *cli.Context) error {
	var questions []*survey.Question
	for _, subCtx := range ctx.Lineage() {
		var flags []cli.Flag
		if subCtx.Command != nil {
			flags = subCtx.Command.Flags
		} else if subCtx.App != nil {
			flags = subCtx.App.Flags
		} else {
			return nil
		}
		for _, flag := range flags {
			interactiveFlag, ok := flag.(Flag)
			if !ok || flag.IsSet() || interactiveFlag.Survey == nil {
				continue
			}
			questions = append(questions, &survey.Question{
				Name:      flag.Names()[0],
				Prompt:    interactiveFlag.Survey,
				Validate:  interactiveFlag.Validator,
				Transform: interactiveFlag.Transform,
			})
			var output string
			err := survey.AskOne(interactiveFlag.Survey, &output)
			if err != nil {
				return err
			}
			err = subCtx.Set(flag.Names()[0], output)
			if err != nil {
				return err
			}
		}
	}
	if len(questions) > 0 {
		err := survey.Ask(questions, &settableContext{ctx})
		if err != nil {
			return err
		}
	}
	return nil
}



================================================
FILE: cmd/bbctl/authconfig.go
================================================
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"runtime"
	"strings"

	"go.mau.fi/util/random"
	"maunium.net/go/mautrix/id"

	"github.com/beeper/bridge-manager/log"
)

var envs = map[string]string{
	"prod":    "beeper.com",
	"staging": "beeper-staging.com",
	"dev":     "beeper-dev.com",
	"local":   "beeper.localtest.me",
}

type EnvConfig struct {
	ClusterID     string `json:"cluster_id"`
	Username      string `json:"username"`
	AccessToken   string `json:"access_token"`
	BridgeDataDir string `json:"bridge_data_dir"`
	DatabaseDir   string `json:"database_dir,omitempty"`
}

func (ec *EnvConfig) HasCredentials() bool {
	return strings.HasPrefix(ec.AccessToken, "syt_")
}

type EnvConfigs map[string]*EnvConfig

func (ec EnvConfigs) Get(env string) *EnvConfig {
	conf, ok := ec[env]
	if !ok {
		conf = &EnvConfig{}
		ec[env] = conf
	}
	return conf
}

type Config struct {
	DeviceID     id.DeviceID `json:"device_id"`
	Environments EnvConfigs  `json:"environments"`
	Path         string      `json:"-"`
}

var UserDataDir string

func getUserDataDir() (dir string, err error) {
	dir = os.Getenv("BBCTL_DATA_HOME")
	if dir != "" {
		return
	}
	if runtime.GOOS == "windows" || runtime.GOOS == "darwin" {
		return os.UserConfigDir()
	}
	dir = os.Getenv("XDG_DATA_HOME")
	if dir == "" {
		dir = os.Getenv("HOME")
		if dir == "" {
			return "", errors.New("neither $XDG_DATA_HOME nor $HOME are defined")
		}
		dir = filepath.Join(dir, ".local", "share")
	}
	return
}

func init() {
	var err error
	UserDataDir, err = getUserDataDir()
	if err != nil {
		panic(fmt.Errorf("couldn't find data directory: %w", err))
	}
}

func migrateOldConfig(currentPath string) error {
	baseConfigDir, err := os.UserConfigDir()
	if err != nil {
		panic(err)
	}
	newDefault := path.Join(baseConfigDir, "bbctl", "config.json")
	oldDefault := path.Join(baseConfigDir, "bbctl.json")
	if currentPath != newDefault {
		return nil
	} else if _, err = os.Stat(oldDefault); err != nil {
		return nil
	} else if err = os.MkdirAll(filepath.Dir(newDefault), 0700); err != nil {
		return err
	} else if err = os.Rename(oldDefault, newDefault); err != nil {
		return err
	} else {
		log.Printf("Moved config to new path (from %s to %s)", oldDefault, newDefault)
		return nil
	}
}

func loadConfig(path string) (ret *Config, err error) {
	defer func() {
		if ret == nil {
			return
		}
		ret.Path = path
		if ret.DeviceID == "" {
			ret.DeviceID = id.DeviceID("bbctl_" + strings.ToUpper(random.String(8)))
		}
		if ret.Environments == nil {
			ret.Environments = make(EnvConfigs)
		}
		for key, env := range ret.Environments {
			if env == nil {
				delete(ret.Environments, key)
				continue
			}
			if env.BridgeDataDir == "" {
				env.BridgeDataDir = filepath.Join(UserDataDir, "bbctl", key)
				saveErr := ret.Save()
				if saveErr != nil {
					err = fmt.Errorf("failed to save config after updating data directory: %w", err)
				}
			}
		}
	}()

	err = migrateOldConfig(path)
	if err != nil {
		return nil, fmt.Errorf("failed to move config to new path: %w", err)
	}
	file, err := os.Open(path)
	if errors.Is(err, os.ErrNotExist) {
		return &Config{}, nil
	} else if err != nil {
		return nil, fmt.Errorf("failed to open config at %s for reading: %v", path, err)
	}
	var cfg Config
	err = json.NewDecoder(file).Decode(&cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to parse config at %s: %v", path, err)
	}
	return &cfg, nil
}

func (cfg *Config) Save() error {
	dirName := filepath.Dir(cfg.Path)
	err := os.MkdirAll(dirName, 0700)
	if err != nil {
		return fmt.Errorf("failed to create config directory at %s: %w", dirName, err)
	}
	file, err := os.OpenFile(cfg.Path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return fmt.Errorf("failed to open config at %s for writing: %v", cfg.Path, err)
	}
	err = json.NewEncoder(file).Encode(cfg)
	if err != nil {
		return fmt.Errorf("failed to write config to %s: %v", cfg.Path, err)
	}
	return nil
}



================================================
FILE: cmd/bbctl/bridgeutil.go
================================================
package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/AlecAivazis/survey/v2"
	"github.com/fatih/color"
	"github.com/urfave/cli/v2"

	"github.com/beeper/bridge-manager/bridgeconfig"
)

var allowedBridgeRegex = regexp.MustCompile("^[a-z0-9-]{1,32}$")

type bridgeTypeToNames struct {
	typeName string
	names    []string
}

var officialBridges = []bridgeTypeToNames{
	{"discord", []string{"discord"}},
	{"meta", []string{"meta", "instagram", "facebook"}},
	{"googlechat", []string{"googlechat", "gchat"}},
	{"imessagego", []string{"imessagego"}},
	{"imessage", []string{"imessage"}},
	{"linkedin", []string{"linkedin"}},
	{"signal", []string{"signal"}},
	{"slack", []string{"slack"}},
	{"telegram", []string{"telegram"}},
	{"twitter", []string{"twitter"}},
	{"whatsapp", []string{"whatsapp"}},
	{"heisenbridge", []string{"irc", "heisenbridge"}},
	{"gmessages", []string{"gmessages", "googlemessages", "rcs", "sms"}},
	{"gvoice", []string{"gvoice", "googlevoice"}},
	{"bluesky", []string{"bluesky", "bsky"}},
}

var websocketBridges = map[string]bool{
	"discord":      true,
	"slack":        true,
	"whatsapp":     true,
	"gmessages":    true,
	"gvoice":       true,
	"heisenbridge": true,
	"imessage":     true,
	"imessagego":   true,
	"signal":       true,
	"bridgev2":     true,
	"meta":         true,
	"twitter":      true,
	"bluesky":      true,
	"linkedin":     true,
	"telegram":     true,
}

func doOutputFile(ctx *cli.Context, name, data string) error {
	outputPath := ctx.String("output")
	if outputPath == "-" {
		_, _ = fmt.Fprintln(os.Stderr, color.YellowString(name+" file:"))
		fmt.Println(strings.TrimRight(data, "\n"))
	} else {
		err := os.WriteFile(outputPath, []byte(data), 0600)
		if err != nil {
			return fmt.Errorf("failed to write %s to %s: %w", strings.ToLower(name), outputPath, err)
		}
		_, _ = fmt.Fprintln(os.Stderr, color.YellowString("Wrote "+strings.ToLower(name)+" file to"), color.CyanString(outputPath))
	}
	return nil
}

func validateBridgeName(ctx *cli.Context, bridge string) error {
	if !allowedBridgeRegex.MatchString(bridge) {
		return UserError{"Invalid bridge name. Names must consist of 1-32 lowercase ASCII letters, digits and -."}
	}
	if !strings.HasPrefix(bridge, "sh-") {
		if !ctx.Bool("force") {
			return UserError{"Self-hosted bridge names should start with sh-"}
		}
		_, _ = fmt.Fprintln(os.Stderr, "Self-hosted bridge names should start with sh-")
	}
	return nil
}

func guessOrAskBridgeType(bridge, bridgeType string) (string, error) {
	if bridgeType == "" {
	Outer:
		for _, br := range officialBridges {
			for _, name := range br.names {
				if strings.Contains(bridge, name) {
					bridgeType = br.typeName
					break Outer
				}
			}
		}
	}
	if !bridgeconfig.IsSupported(bridgeType) {
		_, _ = fmt.Fprintln(os.Stderr, color.YellowString("Unsupported bridge type"), color.CyanString(bridgeType))
		err := survey.AskOne(&survey.Select{
			Message: "Select bridge type:",
			Options: bridgeconfig.SupportedBridges,
		}, &bridgeType)
		if err != nil {
			return "", err
		}
	}
	return bridgeType, nil
}



================================================
FILE: cmd/bbctl/config.go
================================================
package main

import (
	"crypto/aes"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"hash/crc32"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/AlecAivazis/survey/v2"
	"github.com/fatih/color"
	"github.com/urfave/cli/v2"
	"golang.org/x/exp/maps"

	"github.com/beeper/bridge-manager/bridgeconfig"
	"github.com/beeper/bridge-manager/cli/hyper"
)

var configCommand = &cli.Command{
	Name:      "config",
	Aliases:   []string{"c"},
	Usage:     "Generate a config for an official Beeper bridge",
	ArgsUsage: "BRIDGE",
	Before:    RequiresAuth,
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "type",
			Aliases: []string{"t"},
			EnvVars: []string{"BEEPER_BRIDGE_TYPE"},
			Usage:   "The type of bridge being registered.",
		},
		&cli.StringSliceFlag{
			Name:    "param",
			Aliases: []string{"p"},
			Usage:   "Set a bridge-specific config generation option. Can be specified multiple times for different keys. Format: key=value",
		},
		&cli.StringFlag{
			Name:    "output",
			Aliases: []string{"o"},
			Value:   "-",
			EnvVars: []string{"BEEPER_BRIDGE_CONFIG_FILE"},
			Usage:   "Path to save generated config file to.",
		},
		&cli.BoolFlag{
			Name:    "force",
			Aliases: []string{"f"},
			Usage:   "Force register a bridge without the sh- prefix (dangerous).",
			Hidden:  true,
		},
		&cli.BoolFlag{
			Name:   "no-state",
			Usage:  "Don't send a bridge state update (dangerous).",
			Hidden: true,
		},
	},
	Action: generateBridgeConfig,
}

func simpleDescriptions(descs map[string]string) func(string, int) string {
	return func(s string, i int) string {
		return descs[s]
	}
}

var askParams = map[string]func(string, map[string]string) (bool, error){
	"meta": func(bridgeName string, extraParams map[string]string) (bool, error) {
		metaPlatform := extraParams["meta_platform"]
		changed := false
		if metaPlatform == "" {
			if strings.Contains(bridgeName, "facebook-tor") || strings.Contains(bridgeName, "facebooktor") {
				metaPlatform = "facebook-tor"
			} else if strings.Contains(bridgeName, "facebook") {
				metaPlatform = "facebook"
			} else if strings.Contains(bridgeName, "messenger") {
				metaPlatform = "messenger"
			} else if strings.Contains(bridgeName, "instagram") {
				metaPlatform = "instagram"
			} else {
				extraParams["meta_platform"] = ""
				return false, nil
			}
			extraParams["meta_platform"] = metaPlatform
		} else if metaPlatform != "instagram" && metaPlatform != "facebook" && metaPlatform != "facebook-tor" && metaPlatform != "messenger" {
			return false, UserError{"Invalid Meta platform specified"}
		}
		if metaPlatform == "facebook-tor" {
			proxy := extraParams["proxy"]
			if proxy == "" {
				err := survey.AskOne(&survey.Input{
					Message: "Enter Tor proxy address",
					Default: "socks5://localhost:1080",
				}, &proxy)
				if err != nil {
					return false, err
				}
				extraParams["proxy"] = proxy
				changed = true
			}
		}
		return changed, nil
	},
	"imessagego": func(bridgeName string, extraParams map[string]string) (bool, error) {
		nacToken := extraParams["nac_token"]
		var didAddParams bool
		if nacToken == "" {
			err := survey.AskOne(&survey.Input{
				Message: "Enter iMessage registration code",
			}, &nacToken)
			if err != nil {
				return didAddParams, err
			}
			extraParams["nac_token"] = nacToken
			didAddParams = true
		}
		return didAddParams, nil
	},
	"imessage": func(bridgeName string, extraParams map[string]string) (bool, error) {
		platform := extraParams["imessage_platform"]
		barcelonaPath := extraParams["barcelona_path"]
		bbURL := extraParams["bluebubbles_url"]
		bbPassword := extraParams["bluebubbles_password"]
		var didAddParams bool
		if runtime.GOOS != "darwin" && platform == "" {
			// Linux can't run the other connectors
			platform = "bluebubbles"
		}
		if platform == "" {
			err := survey.AskOne(&survey.Select{
				Message: "Select iMessage connector:",
				Options: []string{"mac", "mac-nosip", "bluebubbles"},
				Description: simpleDescriptions(map[string]string{
					"mac":         "Use AppleScript to send messages and read chat.db for incoming data - only requires Full Disk Access (from system settings)",
					"mac-nosip":   "Use Barcelona to interact with private APIs - requires disabling SIP and AMFI",
					"bluebubbles": "Connect to a BlueBubbles instance",
				}),
				Default: "mac",
			}, &platform)
			if err != nil {
				return didAddParams, err
			}
			extraParams["imessage_platform"] = platform
			didAddParams = true
		}
		if platform == "mac-nosip" && barcelonaPath == "" {
			err := survey.AskOne(&survey.Input{
				Message: "Enter Barcelona executable path:",
				Default: "darwin-barcelona-mautrix",
			}, &barcelonaPath)
			if err != nil {
				return didAddParams, err
			}
			extraParams["barcelona_path"] = barcelonaPath
			didAddParams = true
		}
		if platform == "bluebubbles" {
			if bbURL == "" {
				err := survey.AskOne(&survey.Input{
					Message: "Enter BlueBubbles API address:",
				}, &bbURL)
				if err != nil {
					return didAddParams, err
				}
				extraParams["bluebubbles_url"] = bbURL
				didAddParams = true
			}
			if bbPassword == "" {
				err := survey.AskOne(&survey.Input{
					Message: "Enter BlueBubbles password:",
				}, &bbPassword)
				if err != nil {
					return didAddParams, err
				}
				extraParams["bluebubbles_password"] = bbPassword
				didAddParams = true
			}
		}
		return didAddParams, nil
	},
	"telegram": func(bridgeName string, extraParams map[string]string) (bool, error) {
		idKey, _ := base64.RawStdEncoding.DecodeString("YXBpX2lk")
		hashKey, _ := base64.RawStdEncoding.DecodeString("YXBpX2hhc2g")
		_, hasID := extraParams[string(idKey)]
		_, hasHash := extraParams[string(hashKey)]
		if !hasID || !hasHash {
			extraParams[string(idKey)] = "26417019"
			// This is mostly here so the api key wouldn't show up in automated searches.
			// It's not really secret, and this key is only used here, cloud bridges have their own key.
			k, _ := base64.RawStdEncoding.DecodeString("qDP2pQ1LogRjxUYrFUDjDw")
			d, _ := base64.RawStdEncoding.DecodeString("B9VMuZeZlFk0pkbLcfSDDQ")
			b, _ := aes.NewCipher(k)
			b.Decrypt(d, d)
			extraParams[string(hashKey)] = hex.EncodeToString(d)
		}
		return false, nil
	},
}

type generatedBridgeConfig struct {
	BridgeType string
	Config     string
	*RegisterJSON
}

// These should match the last 2 digits of https://mau.fi/ports
var bridgeIPSuffix = map[string]string{
	"telegram":   "17",
	"whatsapp":   "18",
	"meta":       "19",
	"googlechat": "20",
	"twitter":    "27",
	"signal":     "28",
	"discord":    "34",
	"slack":      "35",
	"gmessages":  "36",
	"imessagego": "37",
	"gvoice":     "38",
	"bluesky":    "40",
	"linkedin":   "41",
}

func doGenerateBridgeConfig(ctx *cli.Context, bridge string) (*generatedBridgeConfig, error) {
	if err := validateBridgeName(ctx, bridge); err != nil {
		return nil, err
	}

	whoami, err := getCachedWhoami(ctx)
	if err != nil {
		return nil, err
	}
	existingBridge, ok := whoami.User.Bridges[bridge]
	var bridgeType string
	if ok && existingBridge.BridgeState.BridgeType != "" {
		bridgeType = existingBridge.BridgeState.BridgeType
	} else {
		bridgeType, err = guessOrAskBridgeType(bridge, ctx.String("type"))
		if err != nil {
			return nil, err
		}
	}
	extraParamAsker := askParams[bridgeType]
	extraParams := make(map[string]string)
	for _, item := range ctx.StringSlice("param") {
		parts := strings.SplitN(item, "=", 2)
		if len(parts) != 2 {
			return nil, UserError{fmt.Sprintf("Invalid param %q", item)}
		}
		extraParams[strings.ToLower(parts[0])] = parts[1]
	}
	cliParams := maps.Clone(extraParams)
	if extraParamAsker != nil {
		var didAddParams bool
		didAddParams, err = extraParamAsker(bridge, extraParams)
		if err != nil {
			return nil, err
		}
		if didAddParams {
			formattedParams := make([]string, 0, len(extraParams))
			for key, value := range extraParams {
				_, isCli := cliParams[key]
				if !isCli {
					formattedParams = append(formattedParams, fmt.Sprintf("--param '%s=%s'", key, value))
				}
			}
			_, _ = fmt.Fprintf(os.Stderr, color.YellowString("To run without specifying parameters interactively, add `%s` next time\n"), strings.Join(formattedParams, " "))
		}
	}
	reg, err := doRegisterBridge(ctx, bridge, bridgeType, false)
	if err != nil {
		return nil, err
	}

	dbPrefix := GetEnvConfig(ctx).DatabaseDir
	if dbPrefix != "" {
		dbPrefix = filepath.Join(dbPrefix, bridge+"-")
	}
	websocket := websocketBridges[bridgeType]
	var listenAddress string
	var listenPort uint16
	if !websocket {
		listenAddress, listenPort, reg.Registration.URL = getBridgeWebsocketProxyConfig(bridge, bridgeType)
	}
	cfg, err := bridgeconfig.Generate(bridgeType, bridgeconfig.Params{
		HungryAddress:  reg.HomeserverURL,
		BeeperDomain:   ctx.String("homeserver"),
		Websocket:      websocket,
		AppserviceID:   reg.Registration.ID,
		ASToken:        reg.Registration.AppToken,
		HSToken:        reg.Registration.ServerToken,
		BridgeName:     bridge,
		Username:       reg.YourUserID.Localpart(),
		UserID:         reg.YourUserID,
		Params:         extraParams,
		DatabasePrefix: dbPrefix,

		ListenAddr: listenAddress,
		ListenPort: listenPort,

		ProvisioningSecret: whoami.User.AsmuxData.LoginToken,
	})
	return &generatedBridgeConfig{
		BridgeType:   bridgeType,
		Config:       cfg,
		RegisterJSON: reg,
	}, err
}

func getBridgeWebsocketProxyConfig(bridgeName, bridgeType string) (listenAddress string, listenPort uint16, url string) {
	ipSuffix := bridgeIPSuffix[bridgeType]
	if ipSuffix == "" {
		ipSuffix = "1"
	}
	listenAddress = "127.29.3." + ipSuffix
	// macOS is weird and doesn't support loopback addresses properly,
	// it only routes 127.0.0.1/32 rather than 127.0.0.0/8
	if runtime.GOOS == "darwin" {
		listenAddress = "127.0.0.1"
	}
	listenPort = uint16(30000 + (crc32.ChecksumIEEE([]byte(bridgeName)) % 30000))
	url = fmt.Sprintf("http://%s:%d", listenAddress, listenPort)
	return
}

func generateBridgeConfig(ctx *cli.Context) error {
	if ctx.NArg() == 0 {
		return UserError{"You must specify a bridge to generate a config for"}
	} else if ctx.NArg() > 1 {
		return UserError{"Too many arguments specified (flags must come before arguments)"}
	}
	bridge := ctx.Args().Get(0)
	cfg, err := doGenerateBridgeConfig(ctx, bridge)
	if err != nil {
		return err
	}

	err = doOutputFile(ctx, "Config", cfg.Config)
	if err != nil {
		return err
	}
	outputPath := ctx.String("output")
	if outputPath == "-" || outputPath == "" {
		outputPath = "<config file>"
	}
	var startupCommand, installInstructions string
	switch cfg.BridgeType {
	case "imessage", "whatsapp", "discord", "slack", "gmessages", "gvoice", "signal", "meta", "twitter", "bluesky", "linkedin":
		startupCommand = fmt.Sprintf("mautrix-%s", cfg.BridgeType)
		if outputPath != "config.yaml" && outputPath != "<config file>" {
			startupCommand += " -c " + outputPath
		}
		installInstructions = fmt.Sprintf("https://docs.mau.fi/bridges/go/setup.html?bridge=%s#installation", cfg.BridgeType)
	case "imessagego":
		startupCommand = "beeper-imessage"
		if outputPath != "config.yaml" && outputPath != "<config file>" {
			startupCommand += " -c " + outputPath
		}
	case "heisenbridge":
		heisenHomeserverURL := strings.Replace(cfg.HomeserverURL, "https://", "wss://", 1)
		startupCommand = fmt.Sprintf("python -m heisenbridge -c %s -o %s %s", outputPath, cfg.YourUserID, heisenHomeserverURL)
		installInstructions = "https://github.com/beeper/bridge-manager/wiki/Heisenbridge"
	}
	if startupCommand != "" {
		_, _ = fmt.Fprintf(os.Stderr, "\n%s: %s\n", color.YellowString("Startup command"), color.CyanString(startupCommand))
	}
	if installInstructions != "" {
		_, _ = fmt.Fprintf(os.Stderr, "See %s for bridge installation instructions\n", hyper.Link(installInstructions, installInstructions, false))
	}
	return nil
}



================================================
FILE: cmd/bbctl/context.go
================================================
package main

import (
	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix"

	"github.com/beeper/bridge-manager/api/hungryapi"
)

type contextKey int

const (
	contextKeyConfig contextKey = iota
	contextKeyEnvConfig
	contextKeyMatrixClient
	contextKeyHungryClient
)

func GetConfig(ctx *cli.Context) *Config {
	return ctx.Context.Value(contextKeyConfig).(*Config)
}

func GetEnvConfig(ctx *cli.Context) *EnvConfig {
	return ctx.Context.Value(contextKeyEnvConfig).(*EnvConfig)
}

func GetMatrixClient(ctx *cli.Context) *mautrix.Client {
	val := ctx.Context.Value(contextKeyMatrixClient)
	if val == nil {
		return nil
	}
	return val.(*mautrix.Client)
}

func GetHungryClient(ctx *cli.Context) *hungryapi.Client {
	val := ctx.Context.Value(contextKeyHungryClient)
	if val == nil {
		return nil
	}
	return val.(*hungryapi.Client)
}



================================================
FILE: cmd/bbctl/delete.go
================================================
package main

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"github.com/AlecAivazis/survey/v2"
	"github.com/fatih/color"
	"github.com/urfave/cli/v2"

	"github.com/beeper/bridge-manager/api/beeperapi"
	"github.com/beeper/bridge-manager/log"
)

var deleteCommand = &cli.Command{
	Name:      "delete",
	Aliases:   []string{"d"},
	Usage:     "Delete a bridge and all associated rooms on the Beeper servers",
	ArgsUsage: "BRIDGE",
	Action:    deleteBridge,
	Before:    RequiresAuth,
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:    "force",
			Aliases: []string{"f"},
			Usage:   "Force delete the bridge, even if it's not self-hosted or doesn't seem to exist.",
		},
	},
}

func deleteBridge(ctx *cli.Context) error {
	if ctx.NArg() == 0 {
		return UserError{"You must specify a bridge to delete"}
	} else if ctx.NArg() > 1 {
		return UserError{"Too many arguments specified (flags must come before arguments)"}
	}
	bridge := ctx.Args().Get(0)
	if !allowedBridgeRegex.MatchString(bridge) {
		return UserError{"Invalid bridge name"}
	} else if bridge == "hungryserv" {
		return UserError{"You really shouldn't do that"}
	}
	homeserver := ctx.String("homeserver")
	accessToken := GetEnvConfig(ctx).AccessToken
	if !ctx.Bool("force") {
		whoami, err := getCachedWhoami(ctx)
		if err != nil {
			return fmt.Errorf("failed to get whoami: %w", err)
		}
		bridgeInfo, ok := whoami.User.Bridges[bridge]
		if !ok {
			return UserError{fmt.Sprintf("You don't have a %s bridge.", color.CyanString(bridge))}
		}
		if !bridgeInfo.BridgeState.IsSelfHosted {
			return UserError{fmt.Sprintf("Your %s bridge is not self-hosted.", color.CyanString(bridge))}
		}
	}

	var confirmation bool
	err := survey.AskOne(&survey.Confirm{Message: fmt.Sprintf("Are you sure you want to permanently delete %s?", bridge)}, &confirmation)
	if err != nil {
		return err
	} else if !confirmation {
		return fmt.Errorf("bridge delete cancelled")
	}
	err = beeperapi.DeleteBridge(homeserver, bridge, accessToken)
	if err != nil {
		return fmt.Errorf("error deleting bridge: %w", err)
	}
	fmt.Println("Started deleting bridge")
	bridgeDir := filepath.Join(GetEnvConfig(ctx).BridgeDataDir, bridge)
	err = os.RemoveAll(bridgeDir)
	if err != nil && !errors.Is(err, fs.ErrNotExist) {
		log.Printf("Failed to delete [magenta]%s[reset]: [red]%v[reset]", bridgeDir, err)
	} else {
		log.Printf("Deleted local bridge data from [magenta]%s[reset]", bridgeDir)
	}
	return nil
}



================================================
FILE: cmd/bbctl/login-email.go
================================================
package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"github.com/AlecAivazis/survey/v2"
	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix"

	"github.com/beeper/bridge-manager/api/beeperapi"
	"github.com/beeper/bridge-manager/cli/interactive"
)

var loginCommand = &cli.Command{
	Name:    "login",
	Aliases: []string{"l"},
	Usage:   "Log into the Beeper server",
	Before:  interactive.Ask,
	Action:  beeperLogin,
	Flags: []cli.Flag{
		interactive.Flag{Flag: &cli.StringFlag{
			Name:    "email",
			EnvVars: []string{"BEEPER_EMAIL"},
			Usage:   "The Beeper account email to log in with",
		}, Survey: &survey.Input{
			Message: "Email:",
		}},
	},
}

func beeperLogin(ctx *cli.Context) error {
	homeserver := ctx.String("homeserver")
	email := ctx.String("email")

	startLogin, err := beeperapi.StartLogin(homeserver)
	if err != nil {
		return fmt.Errorf("failed to start login: %w", err)
	}
	err = beeperapi.SendLoginEmail(homeserver, startLogin.RequestID, email)
	if err != nil {
		return fmt.Errorf("failed to send login email: %w", err)
	}
	var apiResp *beeperapi.RespSendLoginCode
	for {
		var code string
		err = survey.AskOne(&survey.Input{
			Message: "Enter login code sent to your email:",
		}, &code)
		if err != nil {
			return err
		}
		apiResp, err = beeperapi.SendLoginCode(homeserver, startLogin.RequestID, code)
		if errors.Is(err, beeperapi.ErrInvalidLoginCode) {
			_, _ = fmt.Fprintln(os.Stderr, err.Error())
			continue
		} else if err != nil {
			return fmt.Errorf("failed to send login code: %w", err)
		}
		break
	}

	return doMatrixLogin(ctx, &mautrix.ReqLogin{
		Type:  "org.matrix.login.jwt",
		Token: apiResp.LoginToken,
	}, apiResp.Whoami)
}

func doMatrixLogin(ctx *cli.Context, req *mautrix.ReqLogin, whoami *beeperapi.RespWhoami) error {
	cfg := GetConfig(ctx)
	req.DeviceID = cfg.DeviceID
	req.InitialDeviceDisplayName = "github.com/beeper/bridge-manager"

	homeserver := ctx.String("homeserver")
	api := NewMatrixAPI(homeserver, "", "")
	resp, err := api.Login(ctx.Context, req)
	if err != nil {
		return fmt.Errorf("failed to log in: %w", err)
	}
	fmt.Printf("Successfully logged in as %s\n", resp.UserID)
	if whoami == nil {
		whoami, err = beeperapi.Whoami(homeserver, resp.AccessToken)
		if err != nil {
			_, _ = api.Logout(ctx.Context)
			return fmt.Errorf("failed to get user details: %w", err)
		}
	}
	envCfg := GetEnvConfig(ctx)
	envCfg.ClusterID = whoami.UserInfo.BridgeClusterID
	envCfg.Username = whoami.UserInfo.Username
	envCfg.AccessToken = resp.AccessToken
	envCfg.BridgeDataDir = filepath.Join(UserDataDir, "bbctl", ctx.String("env"))
	err = cfg.Save()
	if err != nil {
		_, _ = api.Logout(ctx.Context)
		return fmt.Errorf("failed to save config: %w", err)
	}
	return nil
}



================================================
FILE: cmd/bbctl/login-password.go
================================================
package main

import (
	"github.com/AlecAivazis/survey/v2"
	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix"

	"github.com/beeper/bridge-manager/cli/interactive"
)

var loginPasswordCommand = &cli.Command{
	Name:    "login-password",
	Aliases: []string{"p"},
	Usage:   "Log into the Beeper server using username and password",
	Before:  interactive.Ask,
	Action:  beeperLoginPassword,
	Flags: []cli.Flag{
		interactive.Flag{Flag: &cli.StringFlag{
			Name:    "username",
			Aliases: []string{"u"},
			EnvVars: []string{"BEEPER_USERNAME"},
			Usage:   "The Beeper username to log in as",
		}, Survey: &survey.Input{
			Message: "Username:",
		}},
		interactive.Flag{Flag: &cli.StringFlag{
			Name:    "password",
			Aliases: []string{"p"},
			EnvVars: []string{"BEEPER_PASSWORD"},
			Usage:   "The Beeper password to log in with",
		}, Survey: &survey.Password{
			Message: "Password:",
		}},
	},
}

func beeperLoginPassword(ctx *cli.Context) error {
	return doMatrixLogin(ctx, &mautrix.ReqLogin{
		Type: mautrix.AuthTypePassword,
		Identifier: mautrix.UserIdentifier{
			Type: mautrix.IdentifierTypeUser,
			User: ctx.String("username"),
		},
		Password: ctx.String("password"),
	}, nil)
}



================================================
FILE: cmd/bbctl/logout.go
================================================
package main

import (
	"fmt"

	"github.com/urfave/cli/v2"
)

var logoutCommand = &cli.Command{
	Name:   "logout",
	Usage:  "Log out from the Beeper server",
	Before: RequiresAuth,
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:    "force",
			Aliases: []string{"f"},
			EnvVars: []string{"BEEPER_FORCE_LOGOUT"},
			Usage:   "Remove access token even if logout API call fails",
		},
	},
	Action: beeperLogout,
}

func beeperLogout(ctx *cli.Context) error {
	_, err := GetMatrixClient(ctx).Logout(ctx.Context)
	if err != nil && !ctx.Bool("force") {
		return fmt.Errorf("error logging out: %w", err)
	}
	cfg := GetConfig(ctx)
	delete(cfg.Environments, ctx.String("env"))
	err = cfg.Save()
	if err != nil {
		return fmt.Errorf("error saving config: %w", err)
	}
	fmt.Println("Logged out successfully")
	return nil
}



================================================
FILE: cmd/bbctl/main.go
================================================
package main

import (
	"context"
	"fmt"
	"os"
	"path"
	"time"

	"github.com/fatih/color"
	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix"
	"maunium.net/go/mautrix/id"

	"github.com/beeper/bridge-manager/api/hungryapi"
	"github.com/beeper/bridge-manager/log"
)

type UserError struct {
	Message string
}

func (ue UserError) Error() string {
	return ue.Message
}

var (
	Tag       string
	Commit    string
	BuildTime string

	ParsedBuildTime time.Time

	Version = "v0.13.0"
)

const BuildTimeFormat = "Jan _2 2006, 15:04:05 MST"

func init() {
	var err error
	ParsedBuildTime, err = time.Parse(time.RFC3339, BuildTime)
	if BuildTime != "" && err != nil {
		panic(fmt.Errorf("program compiled with malformed build time: %w", err))
	}
	if Tag != Version {
		if Commit == "" {
			Version = fmt.Sprintf("%s+dev.unknown", Version)
		} else {
			Version = fmt.Sprintf("%s+dev.%s", Version, Commit[:8])
		}
	}
	if BuildTime != "" {
		app.Version = fmt.Sprintf("%s (built at %s)", Version, ParsedBuildTime.Format(BuildTimeFormat))
		app.Compiled = ParsedBuildTime
	} else {
		app.Version = Version
	}
	mautrix.DefaultUserAgent = fmt.Sprintf("bbctl/%s %s", Version, mautrix.DefaultUserAgent)
}

func getDefaultConfigPath() string {
	baseConfigDir, err := os.UserConfigDir()
	if err != nil {
		panic(err)
	}
	return path.Join(baseConfigDir, "bbctl", "config.json")
}

func prepareApp(ctx *cli.Context) error {
	cfg, err := loadConfig(ctx.String("config"))
	if err != nil {
		return err
	}
	env := ctx.String("env")
	homeserver, ok := envs[env]
	if !ok {
		return fmt.Errorf("invalid environment %q", env)
	} else if err = ctx.Set("homeserver", homeserver); err != nil {
		return err
	}
	envConfig := cfg.Environments.Get(env)
	ctx.Context = context.WithValue(ctx.Context, contextKeyConfig, cfg)
	ctx.Context = context.WithValue(ctx.Context, contextKeyEnvConfig, envConfig)
	if envConfig.HasCredentials() {
		if envConfig.Username == "" {
			log.Printf("Fetching whoami to fill missing env config details")
			_, err = getCachedWhoami(ctx)
			if err != nil {
				return fmt.Errorf("failed to get whoami: %w", err)
			}
		}
		ctx.Context = context.WithValue(ctx.Context, contextKeyMatrixClient, NewMatrixAPI(homeserver, envConfig.Username, envConfig.AccessToken))
		ctx.Context = context.WithValue(ctx.Context, contextKeyHungryClient, hungryapi.NewClient(homeserver, envConfig.Username, envConfig.AccessToken))
	}
	return nil
}

var app = &cli.App{
	Name:  "bbctl",
	Usage: "Manage self-hosted bridges for Beeper",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:   "homeserver",
			Hidden: true,
		},
		&cli.StringFlag{
			Name:    "env",
			Aliases: []string{"e"},
			EnvVars: []string{"BEEPER_ENV"},
			Value:   "prod",
			Usage:   "The Beeper environment to connect to",
		},
		&cli.StringFlag{
			Name:    "config",
			Aliases: []string{"c"},
			EnvVars: []string{"BBCTL_CONFIG"},
			Usage:   "Path to the config file where access tokens are saved",
			Value:   getDefaultConfigPath(),
		},
		&cli.StringFlag{
			Name:    "color",
			EnvVars: []string{"BBCTL_COLOR"},
			Usage:   "Enable or disable all colors and hyperlinks in output (valid values: always/never/auto)",
			Value:   "auto",
			Action: func(ctx *cli.Context, val string) error {
				switch val {
				case "never":
					color.NoColor = true
				case "always":
					color.NoColor = false
				case "auto":
					// The color package auto-detects by default
				default:
					return fmt.Errorf("invalid value for --color: %q", val)
				}
				return nil
			},
		},
	},
	Before: prepareApp,
	Commands: []*cli.Command{
		loginCommand,
		loginPasswordCommand,
		logoutCommand,
		registerCommand,
		deleteCommand,
		whoamiCommand,
		configCommand,
		runCommand,
		proxyCommand,
	},
}

func main() {
	if err := app.Run(os.Args); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err.Error())
	}
}

const MatrixURLTemplate = "https://matrix.%s"

func NewMatrixAPI(baseDomain string, username, accessToken string) *mautrix.Client {
	homeserverURL := fmt.Sprintf(MatrixURLTemplate, baseDomain)
	var userID id.UserID
	if username != "" {
		userID = id.NewUserID(username, baseDomain)
	}
	client, err := mautrix.NewClient(homeserverURL, userID, accessToken)
	if err != nil {
		panic(err)
	}
	return client
}

func RequiresAuth(ctx *cli.Context) error {
	if !GetEnvConfig(ctx).HasCredentials() {
		return UserError{"You're not logged in"}
	}
	return nil
}



================================================
FILE: cmd/bbctl/proxy.go
================================================
package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"

	"maunium.net/go/mautrix"
	"maunium.net/go/mautrix/appservice"
	"maunium.net/go/mautrix/bridgev2/status"
)

var proxyCommand = &cli.Command{
	Name:    "proxy",
	Aliases: []string{"x"},
	Usage:   "Connect to an appservice websocket, and proxy it to a local appservice HTTP server",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "registration",
			Required: true,
			Aliases:  []string{"r"},
			EnvVars:  []string{"BEEPER_BRIDGE_REGISTRATION_FILE"},
			Usage:    "The path to the registration file to read the as_token, hs_token and local appservice URL from",
		},
	},
	Action: proxyAppserviceWebsocket,
}

const defaultReconnectBackoff = 2 * time.Second
const maxReconnectBackoff = 2 * time.Minute
const reconnectBackoffReset = 5 * time.Minute

func runAppserviceWebsocket(ctx context.Context, doneCallback func(), as *appservice.AppService) {
	defer doneCallback()
	reconnectBackoff := defaultReconnectBackoff
	lastDisconnect := time.Now()
	for {
		err := as.StartWebsocket(ctx, "", func() {
			// TODO support states properly instead of just sending unconfigured
			_ = as.SendWebsocket(ctx, &appservice.WebsocketRequest{
				Command: "bridge_status",
				Data:    &status.BridgeState{StateEvent: status.StateUnconfigured},
			})
		})
		if errors.Is(err, appservice.ErrWebsocketManualStop) {
			return
		} else if closeCommand := (&appservice.CloseCommand{}); errors.As(err, &closeCommand) && closeCommand.Status == appservice.MeowConnectionReplaced {
			as.Log.Info().Msg("Appservice websocket closed by another connection, shutting down...")
			return
		} else if err != nil {
			as.Log.Err(err).Msg("Error in appservice websocket")
		}
		if ctx.Err() != nil {
			return
		}
		now := time.Now()
		if lastDisconnect.Add(reconnectBackoffReset).Before(now) {
			reconnectBackoff = defaultReconnectBackoff
		} else {
			reconnectBackoff *= 2
			if reconnectBackoff > maxReconnectBackoff {
				reconnectBackoff = maxReconnectBackoff
			}
		}
		lastDisconnect = now
		as.Log.Info().
			Int("backoff_seconds", int(reconnectBackoff.Seconds())).
			Msg("Websocket disconnected, reconnecting after a while...")
		select {
		case <-ctx.Done():
			return
		case <-time.After(reconnectBackoff):
		}
	}
}

var wsProxyClient = http.Client{Timeout: 10 * time.Second}

func proxyWebsocketTransaction(ctx context.Context, hsToken string, baseURL *url.URL, msg appservice.WebsocketMessage) error {
	log := zerolog.Ctx(ctx)
	log.Info().Object("contents", &msg.Transaction).Msg("Forwarding transaction")
	fullURL := mautrix.BuildURL(baseURL, "_matrix", "app", "v1", "transactions", msg.TxnID)
	var body bytes.Buffer
	err := json.NewEncoder(&body).Encode(&msg.Transaction)
	if err != nil {
		log.Err(err).Msg("Failed to re-encode transaction")
		return fmt.Errorf("failed to encode transaction: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPut, fullURL.String(), &body)
	if err != nil {
		log.Err(err).Msg("Failed to prepare transaction request")
		return fmt.Errorf("failed to prepare request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", hsToken))
	resp, err := wsProxyClient.Do(req)
	if err != nil {
		log.Err(err).Msg("Failed to send transaction request")
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()
	var errorResp mautrix.RespError
	if resp.StatusCode >= 300 {
		err = json.NewDecoder(resp.Body).Decode(&errorResp)
		if err != nil {
			log.Error().
				AnErr("json_decode_err", err).
				Int("status_code", resp.StatusCode).
				Msg("Got non-JSON error response sending transaction")
			return fmt.Errorf("http %d with non-JSON body", resp.StatusCode)
		}
		log.Err(errorResp).
			Int("status_code", resp.StatusCode).
			Msg("Got error response sending transaction")
		return fmt.Errorf("http %d: %s: %s", resp.StatusCode, errorResp.Err, errorResp.ErrCode)
	}
	return nil
}

func proxyWebsocketRequest(baseURL *url.URL, cmd appservice.WebsocketCommand) (bool, any) {
	var reqData appservice.HTTPProxyRequest
	if err := json.Unmarshal(cmd.Data, &reqData); err != nil {
		return false, fmt.Errorf("failed to parse proxy request: %w", err)
	}
	fullURL := baseURL.JoinPath(reqData.Path)
	fullURL.RawQuery = reqData.Query
	body := bytes.NewReader(reqData.Body)
	httpReq, err := http.NewRequestWithContext(cmd.Ctx, http.MethodPut, fullURL.String(), body)
	if err != nil {
		return false, fmt.Errorf("failed to prepare request: %w", err)
	}
	httpReq.Header = reqData.Headers
	resp, err := wsProxyClient.Do(httpReq)
	if err != nil {
		return false, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()
	respData, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, fmt.Errorf("failed to read request body: %w", err)
	}
	if !json.Valid(respData) {
		encodedData := make([]byte, 2+base64.RawStdEncoding.EncodedLen(len(respData)))
		encodedData[0] = '"'
		base64.RawStdEncoding.Encode(encodedData[1:], respData)
		encodedData[len(encodedData)-1] = '"'
		respData = encodedData
	}
	return true, &appservice.HTTPProxyResponse{
		Status:  resp.StatusCode,
		Headers: resp.Header,
		Body:    respData,
	}
}

func prepareAppserviceWebsocketProxy(ctx *cli.Context, as *appservice.AppService) {
	parsedURL, _ := url.Parse(as.Registration.URL)
	zerolog.TimeFieldFormat = time.RFC3339Nano
	as.Log = zerolog.New(zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
		w.TimeFormat = time.StampMilli
	})).With().Timestamp().Logger()
	as.PrepareWebsocket()
	as.WebsocketTransactionHandler = func(ctx context.Context, msg appservice.WebsocketMessage) (bool, any) {
		err := proxyWebsocketTransaction(ctx, as.Registration.ServerToken, parsedURL, msg)
		if err != nil {
			return false, err
		}
		return true, &appservice.WebsocketTransactionResponse{TxnID: msg.TxnID}
	}
	as.SetWebsocketCommandHandler(appservice.WebsocketCommandHTTPProxy, func(cmd appservice.WebsocketCommand) (bool, any) {
		if cmd.Ctx == nil {
			cmd.Ctx = ctx.Context
		}
		return proxyWebsocketRequest(parsedURL, cmd)
	})
	_ = as.SetHomeserverURL(GetHungryClient(ctx).HomeserverURL.String())
}

type wsPingData struct {
	Timestamp int64 `json:"timestamp"`
}

func keepaliveAppserviceWebsocket(ctx context.Context, doneCallback func(), as *appservice.AppService) {
	log := as.Log.With().Str("component", "websocket pinger").Logger()
	defer doneCallback()
	ticker := time.NewTicker(3 * time.Minute)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
		case <-ctx.Done():
			return
		}
		if !as.HasWebsocket() {
			log.Debug().Msg("Not pinging: websocket not connected")
			continue
		}
		var resp wsPingData
		start := time.Now()
		err := as.RequestWebsocket(ctx, &appservice.WebsocketRequest{
			Command: "ping",
			Data:    &wsPingData{Timestamp: time.Now().UnixMilli()},
		}, &resp)
		if ctx.Err() != nil {
			return
		}
		duration := time.Since(start)
		if err != nil {
			log.Warn().Err(err).Dur("duration", duration).Msg("Websocket ping returned error")
			as.StopWebsocket(fmt.Errorf("websocket ping returned error in %s: %w", duration, err))
		} else {
			serverTs := time.UnixMilli(resp.Timestamp)
			log.Debug().
				Dur("duration", duration).
				Dur("req_duration", serverTs.Sub(start)).
				Dur("resp_duration", time.Since(serverTs)).
				Msg("Websocket ping returned success")
		}
	}
}

func proxyAppserviceWebsocket(ctx *cli.Context) error {
	regPath := ctx.String("registration")
	reg, err := appservice.LoadRegistration(regPath)
	if err != nil {
		return fmt.Errorf("failed to load registration: %w", err)
	} else if reg.URL == "" || reg.URL == "websocket" {
		return UserError{"You must change the `url` field in the registration file to point at the local appservice HTTP server (e.g. `http://localhost:8080`)"}
	} else if !strings.HasPrefix(reg.URL, "http://") && !strings.HasPrefix(reg.URL, "https://") {
		return UserError{"`url` field in registration must start with http:// or https://"}
	}
	as := appservice.Create()
	as.Registration = reg
	as.HomeserverDomain = "beeper.local"
	prepareAppserviceWebsocketProxy(ctx, as)

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	wsCtx, cancel := context.WithCancel(ctx.Context)
	var wg sync.WaitGroup
	wg.Add(2)
	go runAppserviceWebsocket(wsCtx, wg.Done, as)
	go keepaliveAppserviceWebsocket(wsCtx, wg.Done, as)

	<-c

	fmt.Println()
	cancel()
	as.Log.Info().Msg("Interrupt received, stopping...")
	as.StopWebsocket(appservice.ErrWebsocketManualStop)
	wg.Wait()
	return nil
}



================================================
FILE: cmd/bbctl/register.go
================================================
package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/fatih/color"
	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix/appservice"
	"maunium.net/go/mautrix/bridgev2/status"
	"maunium.net/go/mautrix/id"

	"github.com/beeper/bridge-manager/api/beeperapi"
	"github.com/beeper/bridge-manager/api/hungryapi"
)

var registerCommand = &cli.Command{
	Name:      "register",
	Aliases:   []string{"r"},
	Usage:     "Register a 3rd party bridge and print the appservice registration file",
	ArgsUsage: "BRIDGE",
	Action:    registerBridge,
	Before:    RequiresAuth,
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "address",
			Aliases: []string{"a"},
			EnvVars: []string{"BEEPER_BRIDGE_ADDRESS"},
			Usage:   "Optionally, a https address where the Beeper server can push events.\nWhen omitted, the server will expect the bridge to connect with a websocket to receive events.",
		},
		&cli.StringFlag{
			Name:    "output",
			Aliases: []string{"o"},
			Value:   "-",
			EnvVars: []string{"BEEPER_BRIDGE_REGISTRATION_FILE"},
			Usage:   "Path to save generated registration file to.",
		},
		&cli.BoolFlag{
			Name:    "json",
			Aliases: []string{"j"},
			EnvVars: []string{"BEEPER_BRIDGE_REGISTRATION_JSON"},
			Usage:   "Return all data as JSON instead of registration YAML and pretty-printed metadata",
		},
		&cli.BoolFlag{
			Name:    "get",
			Aliases: []string{"g"},
			EnvVars: []string{"BEEPER_BRIDGE_REGISTRATION_GET_ONLY"},
			Usage:   "Only get existing registrations, don't create if it doesn't exist",
		},
		&cli.BoolFlag{
			Name:    "force",
			Aliases: []string{"f"},
			Usage:   "Force register a bridge without the sh- prefix (dangerous).",
			Hidden:  true,
		},
		&cli.BoolFlag{
			Name:   "no-state",
			Usage:  "Don't send a bridge state update (dangerous).",
			Hidden: true,
		},
	},
}

type RegisterJSON struct {
	Registration     *appservice.Registration `json:"registration"`
	HomeserverURL    string                   `json:"homeserver_url"`
	HomeserverDomain string                   `json:"homeserver_domain"`
	YourUserID       id.UserID                `json:"your_user_id"`
}

func doRegisterBridge(ctx *cli.Context, bridge, bridgeType string, onlyGet bool) (*RegisterJSON, error) {
	whoami, err := getCachedWhoami(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get whoami: %w", err)
	}
	bridgeInfo, ok := whoami.User.Bridges[bridge]
	if ok && !bridgeInfo.BridgeState.IsSelfHosted && !ctx.Bool("force") {
		return nil, UserError{fmt.Sprintf("Your %s bridge is not self-hosted.", color.CyanString(bridge))}
	}
	if ok && !onlyGet && ctx.Command.Name == "register" {
		_, _ = fmt.Fprintf(os.Stderr, "You already have a %s bridge, returning existing registration file\n\n", color.CyanString(bridge))
	}
	hungryAPI := GetHungryClient(ctx)

	req := hungryapi.ReqRegisterAppService{
		Push:       false,
		SelfHosted: true,
	}
	if addr := ctx.String("address"); addr != "" {
		req.Push = true
		req.Address = addr
	}

	var resp appservice.Registration
	if onlyGet {
		if req.Address != "" {
			return nil, UserError{"You can't use --get with --address"}
		}
		resp, err = hungryAPI.GetAppService(ctx.Context, bridge)
	} else {
		resp, err = hungryAPI.RegisterAppService(ctx.Context, bridge, req)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to register appservice: %w", err)
	}
	// Remove the explicit bot user namespace (same as sender_localpart)
	resp.Namespaces.UserIDs = resp.Namespaces.UserIDs[0:1]

	state := status.StateRunning
	if (bridgeType != "" && bridgeType != "heisenbridge") || bridge == "androidsms" || bridge == "imessagecloud" || bridge == "imessage" {
		state = status.StateStarting
	}

	if !ctx.Bool("no-state") {
		err = beeperapi.PostBridgeState(ctx.String("homeserver"), GetEnvConfig(ctx).Username, bridge, resp.AppToken, beeperapi.ReqPostBridgeState{
			StateEvent:   state,
			Reason:       "SELF_HOST_REGISTERED",
			IsSelfHosted: true,
			BridgeType:   bridgeType,
		})
		if err != nil {
			return nil, fmt.Errorf("failed to mark bridge as RUNNING: %w", err)
		}
	}
	output := &RegisterJSON{
		Registration:     &resp,
		HomeserverURL:    hungryAPI.HomeserverURL.String(),
		HomeserverDomain: "beeper.local",
		YourUserID:       hungryAPI.UserID,
	}
	return output, nil
}

func registerBridge(ctx *cli.Context) error {
	if ctx.NArg() == 0 {
		return UserError{"You must specify a bridge to register"}
	} else if ctx.NArg() > 1 {
		return UserError{"Too many arguments specified (flags must come before arguments)"}
	}
	bridge := ctx.Args().Get(0)
	if err := validateBridgeName(ctx, bridge); err != nil {
		return err
	}
	output, err := doRegisterBridge(ctx, bridge, "", ctx.Bool("get"))
	if err != nil {
		return err
	}
	if ctx.Bool("json") {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		return enc.Encode(output)
	}

	yaml, err := output.Registration.YAML()
	if err != nil {
		return fmt.Errorf("failed to get yaml: %w", err)
	} else if err = doOutputFile(ctx, "Registration", yaml); err != nil {
		return err
	}
	_, _ = fmt.Fprintln(os.Stderr, color.YellowString("\nAdditional bridge configuration details:"))
	_, _ = fmt.Fprintf(os.Stderr, "* Homeserver domain: %s\n", color.CyanString(output.HomeserverDomain))
	_, _ = fmt.Fprintf(os.Stderr, "* Homeserver URL: %s\n", color.CyanString(output.HomeserverURL))
	_, _ = fmt.Fprintf(os.Stderr, "* Your user ID: %s\n", color.CyanString(output.YourUserID.String()))

	return nil
}



================================================
FILE: cmd/bbctl/run.go
================================================
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/urfave/cli/v2"
	"maunium.net/go/mautrix/appservice"

	"github.com/beeper/bridge-manager/api/gitlab"
	"github.com/beeper/bridge-manager/log"
)

var runCommand = &cli.Command{
	Name:      "run",
	Usage:     "Run an official Beeper bridge",
	ArgsUsage: "BRIDGE",
	Before:    RequiresAuth,
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "type",
			Aliases: []string{"t"},
			EnvVars: []string{"BEEPER_BRIDGE_TYPE"},
			Usage:   "The type of bridge to run.",
		},
		&cli.StringSliceFlag{
			Name:    "param",
			Aliases: []string{"p"},
			Usage:   "Set a bridge-specific config generation option. Can be specified multiple times for different keys. Format: key=value",
		},
		&cli.BoolFlag{
			Name:    "no-update",
			Aliases: []string{"n"},
			Usage:   "Don't update the bridge even if it is out of date.",
			EnvVars: []string{"BEEPER_BRIDGE_NO_UPDATE"},
		},
		&cli.BoolFlag{
			Name:    "local-dev",
			Aliases: []string{"l"},
			Usage:   "Run the bridge in your current working directory instead of downloading and installing a new copy. Useful for developing bridges.",
			EnvVars: []string{"BEEPER_BRIDGE_LOCAL"},
		},
		&cli.BoolFlag{
			Name:    "compile",
			Usage:   "Clone the bridge repository and compile it locally instead of downloading a binary from CI. Useful for architectures that aren't built in CI. Not meant for development/modifying the bridge, use --local-dev for that instead.",
			EnvVars: []string{"BEEPER_BRIDGE_COMPILE"},
		},
		&cli.StringFlag{
			Name:    "config-file",
			Aliases: []string{"c"},
			Value:   "config.yaml",
			EnvVars: []string{"BEEPER_BRIDGE_CONFIG_FILE"},
			Usage:   "File name to save the config to. Mostly relevant for local dev mode.",
		},
		&cli.BoolFlag{
			Name:    "no-override-config",
			Usage:   "Don't override the config file if it already exists. Defaults to true with --local-dev mode, otherwise false (always override)",
			EnvVars: []string{"BEEPER_BRIDGE_NO_OVERRIDE_CONFIG"},
		},
		&cli.StringFlag{
			Name:    "custom-startup-command",
			Usage:   "A custom binary or script to run for startup. Disables checking for updates entirely.",
			EnvVars: []string{"BEEPER_BRIDGE_CUSTOM_STARTUP_COMMAND"},
		},
		&cli.BoolFlag{
			Name:    "force",
			Aliases: []string{"f"},
			Usage:   "Force register a bridge without the sh- prefix (dangerous).",
			Hidden:  true,
		},
		&cli.BoolFlag{
			Name:   "no-state",
			Usage:  "Don't send a bridge state update (dangerous).",
			Hidden: true,
		},
	},
	Action: runBridge,
}

type VersionJSONOutput struct {
	Name string
	URL  string

	Version          string
	IsRelease        bool
	Commit           string
	FormattedVersion string
	BuildTime        string

	Mautrix struct {
		Version string
		Commit  string
	}
}

func updateGoBridge(ctx context.Context, binaryPath, bridgeType string, v2, noUpdate bool) error {
	var currentVersion VersionJSONOutput

	err := os.MkdirAll(filepath.Dir(binaryPath), 0700)
	if err != nil {
		return err
	}

	if _, err = os.Stat(binaryPath); err == nil || !errors.Is(err, fs.ErrNotExist) {
		if currentVersionBytes, err := exec.Command(binaryPath, "--version-json").Output(); err != nil {
			log.Printf("Failed to get current bridge version: [red]%v[reset] - reinstalling", err)
		} else if err = json.Unmarshal(currentVersionBytes, &currentVersion); err != nil {
			log.Printf("Failed to get parse bridge version: [red]%v[reset] - reinstalling", err)
		}
	}
	return gitlab.DownloadMautrixBridgeBinary(ctx, bridgeType, binaryPath, v2, noUpdate, "", currentVersion.Commit)
}

func compileGoBridge(ctx context.Context, buildDir, binaryPath, bridgeType string, noUpdate bool) error {
	buildDirParent := filepath.Dir(buildDir)
	err := os.MkdirAll(buildDirParent, 0700)
	if err != nil {
		return err
	}

	if _, err = os.Stat(buildDir); err != nil && errors.Is(err, fs.ErrNotExist) {
		repo := fmt.Sprintf("https://github.com/mautrix/%s.git", bridgeType)
		if bridgeType == "imessagego" {
			repo = "https://github.com/beeper/imessage.git"
		}
		log.Printf("Cloning [cyan]%s[reset] to [cyan]%s[reset]", repo, buildDir)
		err = makeCmd(ctx, buildDirParent, "git", "clone", repo, buildDir).Run()
		if err != nil {
			return fmt.Errorf("failed to clone repo: %w", err)
		}
	} else {
		if _, err = os.Stat(binaryPath); err == nil || !errors.Is(err, fs.ErrNotExist) {
			if _, err = exec.Command(binaryPath, "--version-json").Output(); err != nil {
				log.Printf("Failed to get current bridge version: [red]%v[reset] - reinstalling", err)
			} else if noUpdate {
				log.Printf("Not updating bridge because --no-update was specified")
				return nil
			}
		}
		log.Printf("Pulling [cyan]%s[reset]", buildDir)
		err = makeCmd(ctx, buildDir, "git", "pull").Run()
		if err != nil {
			return fmt.Errorf("failed to pull repo: %w", err)
		}
	}
	buildScript := "./build.sh"
	log.Printf("Compiling bridge with %s", buildScript)
	err = makeCmd(ctx, buildDir, buildScript).Run()
	if err != nil {
		return fmt.Errorf("failed to compile bridge: %w", err)
	}
	log.Printf("Successfully compiled bridge")
	return nil
}

func setupPythonVenv(ctx context.Context, bridgeDir, bridgeType string, localDev bool) (string, error) {
	var installPackage string
	localRequirements := []string{"-r", "requirements.txt"}
	switch bridgeType {
	case "heisenbridge":
		installPackage = "heisenbridge"
	case "googlechat":
		installPackage = "mautrix-googlechat[all]"
		localRequirements = append(localRequirements, "-r", "optional-requirements.txt")
	default:
		return "", fmt.Errorf("unknown python bridge type %s", bridgeType)
	}
	var venvPath string
	if localDev {
		venvPath = filepath.Join(bridgeDir, ".venv")
	} else {
		venvPath = filepath.Join(bridgeDir, "venv")
	}
	log.Printf("Creating Python virtualenv at [magenta]%s[reset]", venvPath)
	venvArgs := []string{"-m", "venv"}
	if os.Getenv("SYSTEM_SITE_PACKAGES") == "true" {
		venvArgs = append(venvArgs, "--system-site-packages")
	}
	venvArgs = append(venvArgs, venvPath)
	err := makeCmd(ctx, bridgeDir, "python3", venvArgs...).Run()
	if err != nil {
		return venvPath, fmt.Errorf("failed to create venv: %w", err)
	}
	packages := []string{installPackage}
	if localDev {
		packages = localRequirements
	}
	log.Printf("Installing [cyan]%s[reset] into virtualenv", strings.Join(packages, " "))
	pipPath := filepath.Join(venvPath, "bin", "pip3")
	installArgs := append([]string{"install", "--upgrade"}, packages...)
	err = makeCmd(ctx, bridgeDir, pipPath, installArgs...).Run()
	if err != nil {
		return venvPath, fmt.Errorf("failed to install package: %w", err)
	}
	log.Printf("[green]Installation complete[reset]")
	return venvPath, nil
}

func makeCmd(ctx context.Context, pwd, path string, args ...string) *exec.Cmd {
	cmd := exec.CommandContext(ctx, path, args...)
	cmd.Dir = pwd
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd
}

func runBridge(ctx *cli.Context) error {
	if ctx.NArg() == 0 {
		return UserError{"You must specify a bridge to run"}
	} else if ctx.NArg() > 1 {
		return UserError{"Too many arguments specified (flags must come before arguments)"}
	}
	bridgeName := ctx.Args().Get(0)

	var err error
	dataDir := GetEnvConfig(ctx).BridgeDataDir
	var bridgeDir string
	compile := ctx.Bool("compile")
	localDev := ctx.Bool("local-dev")
	if localDev {
		if compile {
			log.Printf("--compile does nothing when using --local-dev")
		}
		bridgeDir, err = os.Getwd()
		if err != nil {
			return fmt.Errorf("failed to get working directory: %w", err)
		}
	} else {
		bridgeDir = filepath.Join(dataDir, bridgeName)
		err = os.MkdirAll(bridgeDir, 0700)
		if err != nil {
			return fmt.Errorf("failed to create bridge directory: %w", err)
		}
	}
	// TODO creating this here feels a bit hacky
	err = os.MkdirAll(filepath.Join(bridgeDir, "logs"), 0700)
	if err != nil {
		return err
	}

	configFileName := ctx.String("config-file")
	configPath := filepath.Join(bridgeDir, configFileName)
	noOverrideConfig := ctx.Bool("no-override-config") || localDev
	doWriteConfig := true
	if noOverrideConfig {
		_, err = os.Stat(configPath)
		doWriteConfig = errors.Is(err, fs.ErrNotExist)
	}

	var cfg *generatedBridgeConfig
	if !doWriteConfig {
		whoami, err := getCachedWhoami(ctx)
		if err != nil {
			return fmt.Errorf("failed to get whoami: %w", err)
		}
		existingBridge, ok := whoami.User.Bridges[bridgeName]
		if !ok || existingBridge.BridgeState.BridgeType == "" {
			log.Printf("Existing bridge type not found, falling back to generating new config")
			doWriteConfig = true
		} else if reg, err := doRegisterBridge(ctx, bridgeName, existingBridge.BridgeState.BridgeType, true); err != nil {
			log.Printf("Failed to get existing bridge registration: %v", err)
			log.Printf("Falling back to generating new config")
			doWriteConfig = true
		} else {
			cfg = &generatedBridgeConfig{
				BridgeType:   existingBridge.BridgeState.BridgeType,
				RegisterJSON: reg,
			}
		}
	}

	if doWriteConfig {
		cfg, err = doGenerateBridgeConfig(ctx, bridgeName)
		if err != nil {
			return err
		}
		err = os.WriteFile(configPath, []byte(cfg.Config), 0600)
		if err != nil {
			return fmt.Errorf("failed to save config: %w", err)
		}
	} else {
		log.Printf("Config already exists, not overriding - if you want to regenerate it, delete [cyan]%s[reset]", configPath)
	}

	overrideBridgeCmd := ctx.String("custom-startup-command")
	if overrideBridgeCmd != "" {
		if localDev {
			log.Printf("--local-dev does nothing when using --custom-startup-command")
		}
		if compile {
			log.Printf("--compile does nothing when using --custom-startup-command")
		}
	}
	var bridgeCmd string
	var bridgeArgs []string
	var needsWebsocketProxy bool
	switch cfg.BridgeType {
	case "imessage", "imessagego", "whatsapp", "discord", "slack", "gmessages", "gvoice",
		"signal", "meta", "twitter", "bluesky", "linkedin", "telegram":
		ciBridgeType := cfg.BridgeType
		binaryName := fmt.Sprintf("mautrix-%s", cfg.BridgeType)
		ciV2 := false
		switch cfg.BridgeType {
		case "telegram":
			ciV2 = true
			ciBridgeType = "telegramgo"
		case "imessagego":
			binaryName = "beeper-imessage"
		}
		bridgeCmd = filepath.Join(dataDir, "binaries", binaryName)
		if localDev && overrideBridgeCmd == "" {
			bridgeCmd = filepath.Join(bridgeDir, binaryName)
			buildScript := "./build.sh"
			log.Printf("Compiling [cyan]%s[reset] with %s", binaryName, buildScript)
			err = makeCmd(ctx.Context, bridgeDir, buildScript).Run()
			if err != nil {
				return fmt.Errorf("failed to compile bridge: %w", err)
			}
		} else if compile && overrideBridgeCmd == "" {
			buildDir := filepath.Join(dataDir, "compile", binaryName)
			bridgeCmd = filepath.Join(buildDir, binaryName)
			err = compileGoBridge(ctx.Context, buildDir, bridgeCmd, ciBridgeType, ctx.Bool("no-update"))
			if err != nil {
				return fmt.Errorf("failed to compile bridge: %w", err)
			}
		} else if overrideBridgeCmd == "" {
			err = updateGoBridge(ctx.Context, bridgeCmd, ciBridgeType, ciV2, ctx.Bool("no-update"))
			if errors.Is(err, gitlab.ErrNotBuiltInCI) {
				return UserError{fmt.Sprintf("Binaries for %s are not built in the CI. Use --compile to tell bbctl to build the bridge locally.", binaryName)}
			} else if err != nil {
				return fmt.Errorf("failed to update bridge: %w", err)
			}
		}
		bridgeArgs = []string{"-c", configFileName}
	case "googlechat":
		if overrideBridgeCmd == "" {
			var venvPath string
			venvPath, err = setupPythonVenv(ctx.Context, bridgeDir, cfg.BridgeType, localDev)
			if err != nil {
				return fmt.Errorf("failed to update bridge: %w", err)
			}
			bridgeCmd = filepath.Join(venvPath, "bin", "python3")
		}
		bridgeArgs = []string{"-m", "mautrix_" + cfg.BridgeType, "-c", configFileName}
		needsWebsocketProxy = true
	case "heisenbridge":
		if overrideBridgeCmd == "" {
			var venvPath string
			venvPath, err = setupPythonVenv(ctx.Context, bridgeDir, cfg.BridgeType, localDev)
			if err != nil {
				return fmt.Errorf("failed to update bridge: %w", err)
			}
			bridgeCmd = filepath.Join(venvPath, "bin", "python3")
		}
		heisenHomeserverURL := strings.Replace(cfg.HomeserverURL, "https://", "wss://", 1)
		bridgeArgs = []string{"-m", "heisenbridge", "-c", configFileName, "-o", cfg.YourUserID.String(), heisenHomeserverURL}
	default:
		if overrideBridgeCmd == "" {
			return UserError{"Unsupported bridge type for bbctl run"}
		}
	}
	if overrideBridgeCmd != "" {
		bridgeCmd = overrideBridgeCmd
	}

	cmd := makeCmd(ctx.Context, bridgeDir, bridgeCmd, bridgeArgs...)
	if runtime.GOOS == "linux" {
		cmd.SysProcAttr = &syscall.SysProcAttr{
			// Don't pass through signals to the bridge, we'll send a sigterm when we want to stop it.
			// Causes weird issues on macOS, so limited to Linux.
			Setpgid: true,
		}
	}
	var as *appservice.AppService
	var wg sync.WaitGroup
	var cancelWS context.CancelFunc
	wsProxyClosed := make(chan struct{})
	if needsWebsocketProxy {
		if cfg.Registration.URL == "" || cfg.Registration.URL == "websocket" {
			_, _, cfg.Registration.URL = getBridgeWebsocketProxyConfig(bridgeName, cfg.BridgeType)
		}
		wg.Add(2)
		log.Printf("Starting websocket proxy")
		as = appservice.Create()
		as.Registration = cfg.Registration
		as.HomeserverDomain = "beeper.local"
		prepareAppserviceWebsocketProxy(ctx, as)
		var wsCtx context.Context
		wsCtx, cancelWS = context.WithCancel(ctx.Context)
		defer cancelWS()
		go runAppserviceWebsocket(wsCtx, func() {
			wg.Done()
			close(wsProxyClosed)
		}, as)
		go keepaliveAppserviceWebsocket(wsCtx, wg.Done, as)
	}

	log.Printf("Starting [cyan]%s[reset]", cfg.BridgeType)

	c := make(chan os.Signal, 1)
	interrupted := false
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	go func() {
		select {
		case <-c:
			interrupted = true
			fmt.Println()
		case <-wsProxyClosed:
			log.Printf("Websocket proxy exited, shutting down bridge")
		}
		log.Printf("Shutting down [cyan]%s[reset]", cfg.BridgeType)
		if as != nil && as.StopWebsocket != nil {
			as.StopWebsocket(appservice.ErrWebsocketManualStop)
		}
		proc := cmd.Process
		// On non-Linux, assume setpgid wasn't set, so the signal will be automatically sent to both processes.
		if proc != nil && runtime.GOOS == "linux" {
			err := proc.Signal(syscall.SIGTERM)
			if err != nil {
				log.Printf("Failed to send SIGTERM to bridge: %v", err)
			}
		}
		time.Sleep(3 * time.Second)
		log.Printf("Killing process")
		err := proc.Kill()
		if err != nil {
			log.Printf("Failed to kill bridge: %v", err)
		}
		os.Exit(1)
	}()

	err = cmd.Run()
	if !interrupted {
		log.Printf("Bridge exited")
	}
	if as != nil && as.StopWebsocket != nil {
		as.StopWebsocket(appservice.ErrWebsocketManualStop)
	}
	if cancelWS != nil {
		cancelWS()
	}
	if err != nil {
		return err
	}
	wg.Wait()
	return nil
}



================================================
FILE: cmd/bbctl/whoami.go
================================================
package main

import (
	"encoding/json"
	"fmt"
	"regexp"
	"sort"
	"strings"

	"github.com/fatih/color"
	"github.com/urfave/cli/v2"
	"golang.org/x/exp/maps"
	"maunium.net/go/mautrix/bridgev2/status"

	"github.com/beeper/bridge-manager/api/beeperapi"
	"github.com/beeper/bridge-manager/cli/hyper"
	"github.com/beeper/bridge-manager/log"
)

var whoamiCommand = &cli.Command{
	Name:    "whoami",
	Aliases: []string{"w"},
	Usage:   "Get info about yourself",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:    "raw",
			Aliases: []string{"r"},
			EnvVars: []string{"BEEPER_WHOAMI_RAW"},
			Usage:   "Get raw JSON output instead of pretty-printed bridge status",
		},
	},
	Before: RequiresAuth,
	Action: whoamiFunction,
}

func coloredHomeserver(domain string) string {
	switch domain {
	case "beeper.com":
		return color.GreenString(domain)
	case "beeper-staging.com":
		return color.CyanString(domain)
	case "beeper-dev.com":
		return color.RedString(domain)
	case "beeper.localtest.me":
		return color.YellowString(domain)
	default:
		return domain
	}
}

func coloredChannel(channel string) string {
	switch channel {
	case "STABLE":
		return color.GreenString(channel)
	case "NIGHTLY":
		return color.YellowString(channel)
	case "INTERNAL":
		return color.RedString(channel)
	default:
		return channel
	}
}

func coloredBridgeState(state status.BridgeStateEvent) string {
	switch state {
	case status.StateStarting, status.StateConnecting:
		return color.CyanString(string(state))
	case status.StateTransientDisconnect, status.StateBridgeUnreachable:
		return color.YellowString(string(state))
	case status.StateUnknownError, status.StateBadCredentials:
		return color.RedString(string(state))
	case status.StateRunning, status.StateConnected:
		return color.GreenString(string(state))
	default:
		return string(state)
	}
}

var bridgeImageRegex = regexp.MustCompile(`^docker\.beeper-tools\.com/(?:bridge/)?([a-z]+):(v2-)?([0-9a-f]{40})(?:-amd64)?$`)

var dockerToGitRepo = map[string]string{
	"hungryserv":  "https://github.com/beeper/hungryserv/commit/%s",
	"discordgo":   "https://github.com/mautrix/discord/commit/%s",
	"dummybridge": "https://github.com/beeper/dummybridge/commit/%s",
	"facebook":    "https://github.com/mautrix/facebook/commit/%s",
	"googlechat":  "https://github.com/mautrix/googlechat/commit/%s",
	"instagram":   "https://github.com/mautrix/instagram/commit/%s",
	"meta":        "https://github.com/mautrix/meta/commit/%s",
	"linkedin":    "https://github.com/mautrix/linkedin/commit/%s",
	"signal":      "https://github.com/mautrix/signal/commit/%s",
	"slackgo":     "https://github.com/mautrix/slack/commit/%s",
	"telegram":    "https://github.com/mautrix/telegram/commit/%s",
	"telegramgo":  "https://github.com/mautrix/telegramgo/commit/%s",
	"twitter":     "https://github.com/mautrix/twitter/commit/%s",
	"bluesky":     "https://github.com/mautrix/bluesky/commit/%s",
	"whatsapp":    "https://github.com/mautrix/whatsapp/commit/%s",
}

func parseBridgeImage(bridge, image string, internal bool) string {
	if image == "" || image == "?" {
		// Self-hosted bridges don't have a version in whoami
		return ""
	} else if bridge == "imessagecloud" {
		return image[:8]
	}
	match := bridgeImageRegex.FindStringSubmatch(image)
	if match == nil {
		return color.YellowString(image)
	}
	if match[1] == "hungryserv" && !internal {
		return match[3][:8]
	}
	return color.HiBlueString(match[2] + hyper.Link(match[3][:8], fmt.Sprintf(dockerToGitRepo[match[1]], match[3]), false))
}

func formatBridgeRemotes(name string, bridge beeperapi.WhoamiBridge) string {
	switch {
	case name == "hungryserv", name == "androidsms", name == "imessage":
		return ""
	case len(bridge.RemoteState) == 0:
		if bridge.BridgeState.IsSelfHosted {
			return ""
		}
		return color.YellowString("not logged in")
	case len(bridge.RemoteState) == 1:
		remoteState := maps.Values(bridge.RemoteState)[0]
		return fmt.Sprintf("remote: %s (%s / %s)", coloredBridgeState(remoteState.StateEvent), color.CyanString(remoteState.RemoteName), color.CyanString(remoteState.RemoteID))
	case len(bridge.RemoteState) > 1:
		return "multiple remotes"
	}
	return ""
}

func formatBridge(name string, bridge beeperapi.WhoamiBridge, internal bool) string {
	formatted := color.CyanString(name)
	versionString := parseBridgeImage(name, bridge.Version, internal)
	if versionString != "" {
		formatted += fmt.Sprintf(" (version: %s)", versionString)
	}
	if bridge.BridgeState.IsSelfHosted {
		var typeName string
		if !strings.Contains(name, bridge.BridgeState.BridgeType) {
			typeName = bridge.BridgeState.BridgeType + ", "
		}
		formatted += fmt.Sprintf(" (%s%s)", typeName, color.HiGreenString("self-hosted"))
	}
	formatted += fmt.Sprintf(" - %s", coloredBridgeState(bridge.BridgeState.StateEvent))
	remotes := formatBridgeRemotes(name, bridge)
	if remotes != "" {
		formatted += " - " + remotes
	}
	return formatted
}

var cachedWhoami *beeperapi.RespWhoami

func getCachedWhoami(ctx *cli.Context) (*beeperapi.RespWhoami, error) {
	if cachedWhoami != nil {
		return cachedWhoami, nil
	}
	ec := GetEnvConfig(ctx)
	resp, err := beeperapi.Whoami(ctx.String("homeserver"), ec.AccessToken)
	if err != nil {
		return nil, err
	}
	changed := false
	if ec.Username != resp.UserInfo.Username {
		ec.Username = resp.UserInfo.Username
		changed = true
	}
	if ec.ClusterID != resp.UserInfo.BridgeClusterID {
		ec.ClusterID = resp.UserInfo.BridgeClusterID
		changed = true
	}
	if changed {
		err = GetConfig(ctx).Save()
		if err != nil {
			log.Printf("Failed to save config after updating: %v", err)
		}
	}
	cachedWhoami = resp
	return resp, nil
}

func whoamiFunction(ctx *cli.Context) error {
	whoami, err := getCachedWhoami(ctx)
	if err != nil {
		return fmt.Errorf("failed to get whoami: %w", err)
	}
	if ctx.Bool("raw") {
		data, err := json.MarshalIndent(whoami, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to marshal JSON: %w", err)
		}
		fmt.Println(string(data))
		return nil
	}
	if oldID := GetEnvConfig(ctx).ClusterID; whoami.UserInfo.BridgeClusterID != oldID {
		GetEnvConfig(ctx).ClusterID = whoami.UserInfo.BridgeClusterID
		err = GetConfig(ctx).Save()
		if err != nil {
			fmt.Printf("Noticed cluster ID changed from %s to %s, but failed to save change: %v\n", oldID, whoami.UserInfo.BridgeClusterID, err)
		} else {
			fmt.Printf("Noticed cluster ID changed from %s to %s and saved to config\n", oldID, whoami.UserInfo.BridgeClusterID)
		}
	}
	homeserver := ctx.String("homeserver")
	fmt.Printf("User ID: @%s:%s\n", color.GreenString(whoami.UserInfo.Username), coloredHomeserver(homeserver))
	if whoami.UserInfo.Admin {
		fmt.Printf("Admin: %s\n", color.RedString("true"))
	}
	if whoami.UserInfo.Free {
		fmt.Printf("Free: %s\n", color.GreenString("true"))
	}
	fmt.Printf("Name: %s\n", color.CyanString(whoami.UserInfo.FullName))
	fmt.Printf("Email: %s\n", color.CyanString(whoami.UserInfo.Email))
	fmt.Printf("Support room ID: %s\n", color.CyanString(whoami.UserInfo.SupportRoomID.String()))
	fmt.Printf("Registered at: %s\n", color.CyanString(whoami.UserInfo.CreatedAt.Local().Format(BuildTimeFormat)))
	fmt.Printf("Cloud bridge details:\n")
	fmt.Printf("  Update channel: %s\n", coloredChannel(whoami.UserInfo.Channel))
	fmt.Printf("  Cluster ID: %s\n", color.CyanString(whoami.UserInfo.BridgeClusterID))
	hungryAPI := GetHungryClient(ctx)
	homeserverURL := hungryAPI.HomeserverURL.String()
	fmt.Printf("  Hungryserv URL: %s\n", color.CyanString(hyper.Link(homeserverURL, homeserverURL, false)))
	fmt.Printf("Bridges:\n")
	internal := homeserver != "beeper.com" || whoami.UserInfo.Channel == "INTERNAL"
	fmt.Println(" ", formatBridge("hungryserv", whoami.User.Hungryserv, internal))
	keys := maps.Keys(whoami.User.Bridges)
	sort.Strings(keys)
	for _, name := range keys {
		fmt.Println(" ", formatBridge(name, whoami.User.Bridges[name], internal))
	}
	return nil
}



================================================
FILE: docker/README.md
================================================
# Docker
bridge-manager includes a docker file which wraps `bbctl run`. It's primarily
meant for the automated Fly deployer ([self-host.beeper.com]), but can be used
manually as well.

[self-host.beeper.com]: https://self-host.beeper.com

## Usage
```sh
docker run \
	# Mount the current directory to /data in the container
	# (the bridge binaries, config and database will be stored here)
	-v $(pwd):/data \
	# Pass your Beeper access token here. You can find it in ~/.config/bbctl/config.json
	# or Beeper Desktop settings -> Help & About
	-e MATRIX_ACCESS_TOKEN=... \
	# The image to run, followed by the name of the bridge to run.
	ghcr.io/beeper/bridge-manager sh-telegram
```

The container should work fine as any user (as long as the mounted `/data`
directory is writable), so you can just use the standard `--user` flag to
change the UID/GID.



================================================
FILE: docker/Dockerfile
================================================
FROM dock.mau.dev/tulir/lottieconverter:alpine-3.21 AS lottie

FROM golang:1.24-alpine3.21 AS builder

COPY . /build/
RUN cd /build && ./build.sh

FROM alpine:3.21

RUN apk add --no-cache bash curl jq git ffmpeg \
	# Python for python bridges
	python3 py3-pip py3-setuptools py3-wheel \
	# Common dependencies that need native extensions for Python bridges
	py3-magic py3-ruamel.yaml py3-aiohttp py3-pillow py3-olm py3-pycryptodome

COPY --from=lottie /cryptg-*.whl /tmp/
RUN pip3 install --break-system-packages /tmp/cryptg-*.whl && rm -f /tmp/cryptg-*.whl

COPY --from=builder /build/bbctl /usr/local/bin/bbctl
COPY --from=lottie /usr/lib/librlottie.so* /usr/lib/
COPY --from=lottie /usr/local/bin/lottieconverter /usr/local/bin/lottieconverter
COPY ./docker/run-bridge.sh /usr/local/bin/run-bridge.sh
ENV SYSTEM_SITE_PACKAGES=true
VOLUME /data

ENTRYPOINT ["/usr/local/bin/run-bridge.sh"]



================================================
FILE: docker/run-bridge.sh
================================================
#!/bin/bash
set -euf -o pipefail
if [[ -z "${BRIDGE_NAME:-}" ]]; then
	if [[ ! -z "$1" ]]; then
		export BRIDGE_NAME="$1"
	else
		echo "BRIDGE_NAME not set"
		exit 1
	fi
fi
export BBCTL_CONFIG=${BBCTL_CONFIG:-/tmp/bbctl.json}
export BEEPER_ENV=${BEEPER_ENV:-prod}
if [[ ! -f $BBCTL_CONFIG ]]; then
	if [[ -z "$MATRIX_ACCESS_TOKEN" ]]; then
		echo "MATRIX_ACCESS_TOKEN not set"
		exit 1
	fi
	export DATA_DIR=${DATA_DIR:-/data}
	if [[ ! -d $DATA_DIR ]]; then
		echo "DATA_DIR ($DATA_DIR) does not exist, creating"
		mkdir -p $DATA_DIR
	fi
	export DB_DIR=${DB_DIR:-/data/db}
	mkdir -p $DB_DIR
	jq -n '{environments: {"\(env.BEEPER_ENV)": {access_token: env.MATRIX_ACCESS_TOKEN, database_dir: env.DB_DIR, bridge_data_dir: env.DATA_DIR}}}' > $BBCTL_CONFIG
fi
bbctl -e $BEEPER_ENV run $BRIDGE_NAME



================================================
FILE: log/log.go
================================================
package log

import (
	"fmt"
	"os"

	"github.com/fatih/color"
	"github.com/mitchellh/colorstring"
)

func Printf(format string, args ...any) {
	if !color.NoColor {
		format = colorstring.Color(format)
	}
	_, _ = fmt.Fprintf(os.Stderr, format+"\n", args...)
}



================================================
FILE: .github/ISSUE_TEMPLATE/config.yml
================================================
blank_issues_enabled: false



================================================
FILE: .github/ISSUE_TEMPLATE/issue.md
================================================
---
name: Issue
about: Submit a bug report or feature request related to bbctl.

---

<!--
Do not submit anything unrelated to bbctl here.

For issues with self-hosting bridges with a self-hosted Matrix server (outside Beeper),
refer to the official bridge repositories under github.com/mautrix.

For issues with bridges built into Beeper, as well as Beeper client issues
unrelated to bridges, use the "Report a problem" button in the clients.

For any other Beeper-related questions, email support@beeper.com
or ask in the Beeper Community room.

Also, for setup issues related to bbctl, it's often quicker to
ask in #self-hosting:beeper.com than creating an issue.
-->



================================================
FILE: .github/workflows/go.yaml
================================================
name: Go

on: [push, pull_request]

env:
  GO_VERSION: "1.25"
  GHCR_REGISTRY: ghcr.io
  GHCR_REGISTRY_IMAGE: "ghcr.io/${{ github.repository }}"
  GOTOOLCHAIN: local

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5

      - name: Set up Go ${{ env.GO_VERSION }}
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}
          cache: true

      - name: Install dependencies
        run: |
          go install golang.org/x/tools/cmd/goimports@latest
          go install honnef.co/go/tools/cmd/staticcheck@latest
          export PATH="$HOME/go/bin:$PATH"

      - name: Run pre-commit
        uses: pre-commit/action@v3.0.1

  build:
    runs-on: ubuntu-latest
    env:
      CGO_ENABLED: "0"
    steps:
      - uses: actions/checkout@v5

      - name: Set up Go ${{ env.GO_VERSION }}
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}
          cache: true

      - name: Build binaries
        run: ./ci-build-all.sh

      - name: Upload linux/amd64 artifact
        uses: actions/upload-artifact@v4
        with:
          name: bbctl-linux-amd64
          path: bbctl-linux-amd64
          if-no-files-found: error

      - name: Upload linux/arm64 artifact
        uses: actions/upload-artifact@v4
        with:
          name: bbctl-linux-arm64
          path: bbctl-linux-arm64
          if-no-files-found: error

      - name: Upload macos/amd64 artifact
        uses: actions/upload-artifact@v4
        with:
          name: bbctl-macos-amd64
          path: bbctl-macos-amd64
          if-no-files-found: error

      - name: Upload macos/arm64 artifact
        uses: actions/upload-artifact@v4
        with:
          name: bbctl-macos-arm64
          path: bbctl-macos-arm64
          if-no-files-found: error

  build-docker:
    runs-on: ${{ matrix.runs-on }}
    strategy:
      matrix:
        include:
        - runs-on: ubuntu-latest
          target: amd64
        - runs-on: ubuntu-arm64
          target: arm64
    name: build-docker (${{ matrix.target }})
    steps:
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.GHCR_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Docker Build
        uses: docker/build-push-action@v5
        with:
          cache-from: ${{ env.GHCR_REGISTRY_IMAGE }}:latest
          pull: true
          file: docker/Dockerfile
          tags: ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-${{ matrix.target }}
          push: true
          build-args: |
            COMMIT_HASH=${{ github.sha }}
          # These will apparently disable making a manifest
          provenance: false
          sbom: false

  deploy-docker:
    runs-on: ubuntu-latest
    needs:
      - build-docker
    steps:
      - name: Login to registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.GHCR_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Create commit manifest
        run: |
          docker pull ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-amd64
          docker pull ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-arm64
          docker manifest create ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }} ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-amd64 ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-arm64
          docker manifest push ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}

      - name: Create :latest manifest
        if: github.ref == 'refs/heads/main'
        run: |
          docker manifest create ${{ env.GHCR_REGISTRY_IMAGE }}:latest ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-amd64 ${{ env.GHCR_REGISTRY_IMAGE }}:${{ github.sha }}-arm64
          docker manifest push ${{ env.GHCR_REGISTRY_IMAGE }}:latest