# CI Integration

## Uploading a Build with App Center

Waldo integration with [App Center](https://appcenter.ms) requires you only to
add a couple of [custom build
steps](https://docs.microsoft.com/en-us/appcenter/build/custom/scripts/).

Add the following to `appcenter-post-clone.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin                        # or wherever you prefer

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > "$WALDO_CLI_BIN"/waldo
chmod +x "$WALDO_CLI_BIN"/waldo
```

Add the following to `appcenter-post-build.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin                        # or wherever you prefer

API_KEY=0123456789abcdef0123456789abcdef            # set to your real API key
APPLICATION_ID=app-0123456789abcdef                 # set to your real application ID
BUILD_PATH=$APPCENTER_OUTPUT_DIRECTORY/YourApp.apk  # for Android
BUILD_PATH=$APPCENTER_OUTPUT_DIRECTORY/YourApp.ipa  # for iOS

"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"                \
                       --key $API_KEY               \
                       --application $APPLICATION_ID
```

## Uploading a Build with Bitrise

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a [custom `Script`
step](https://devcenter.bitrise.io/tips-and-tricks/install-additional-tools/)
to your workflow containing the following:

```bash
#!/bin/bash

set -ex

WALDO_CLI_BIN="/usr/local/bin"              # or wherever you prefer

if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi

API_KEY=0123456789abcdef0123456789abcdef    # set to your real API key
APPLICATION_ID=app-0123456789abcdef         # set to your real application ID
BUILD_PATH=$BITRISE_APK_PATH                # for Android
BUILD_PATH=$BITRISE_IPA_PATH                # for iOS

"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"                \
                       --key $API_KEY               \
                       --application $APPLICATION_ID
```

## Uploading a Build with CircleCI

Waldo integration with [Circle CI](https://circleci.com) requires you only to
add a couple of steps to your
[configuration](https://circleci.com/docs/2.0/configuration-reference/):

```yaml
jobs:
  build:    # or whatever name you choose
    steps:
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > .circleci/waldo

      #...
      #... (build steps)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH"
        environment:
          WALDO_API_KEY: 0123456789abcdef0123456789abcdef
          WALDO_APPLICATION_ID: app-0123456789abcdef
          WALDO_BUILD_PATH: /path/to/YourApp.ipa
```

## Uploading a Build Manually

For the pain-lovers out there, you can also upload your iOS or Android build
_manually_ using `curl`. This is _not_ recommended because there are several
options to the `curl` command that must be specified exactly for the build to
be accepted.

### Uploading an iOS Build

```bash
$ API_KEY=0123456789abcdef0123456789abcdef    # set to your real API key
$ BUILD_PATH=/path/to/YourApp.ipa
$ curl --data-binary @"$BUILD_PATH"                     \
       -H "Authorization: Upload-Token $API_KEY"        \
       -H "Content-Type: application/octet-stream"      \
       -H "User-Agent: Waldo CLI/iOS v1.0.0"            \
       "https://api.waldo.io/versions?variantName=manual"
```

### Uploading an Android Build

```bash
$ API_KEY=0123456789abcdef0123456789abcdef    # set to your real API key
$ BUILD_PATH=/path/to/YourApp.apk
$ curl --data-binary @"$BUILD_PATH"                     \
       -H "Authorization: Upload-Token $API_KEY"        \
       -H "Content-Type: application/octet-stream"      \
       -H "User-Agent: Waldo CLI/Android v1.0.0"        \
       "https://api.waldo.io/versions?variantName=manual"
```