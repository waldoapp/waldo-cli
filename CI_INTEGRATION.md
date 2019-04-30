# CI Integration

## Uploading a Build with App Center

Waldo integration with [App Center](https://appcenter.ms) requires you only to
add a couple of [custom build
steps](https://docs.microsoft.com/en-us/appcenter/build/custom/scripts/).

Add the following to `appcenter-post-clone.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin                                # or wherever you prefer

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.2.0/waldo > "$WALDO_CLI_BIN"/waldo
chmod +x "$WALDO_CLI_BIN"/waldo
```

Add the following to `appcenter-post-build.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin                                # or wherever you prefer

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef  # set to your real upload token

BUILD_PATH=$APPCENTER_OUTPUT_DIRECTORY/YourApp.apk          # for Android
BUILD_PATH=$APPCENTER_OUTPUT_DIRECTORY/YourApp.ipa          # for iOS

"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"
```

## Uploading a Build with Bitrise

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a [custom `Script`
step](https://devcenter.bitrise.io/tips-and-tricks/install-additional-tools/)
to your workflow containing the following:

```bash
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin                        # or wherever you prefer

if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.2.0/waldo > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef  # set to your real upload token

BUILD_PATH=$BITRISE_APK_PATH                                # for Android
BUILD_PATH=$BITRISE_IPA_PATH                                # for iOS

"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"
```

## Uploading a Build with CircleCI

Waldo integration with [CircleCI](https://circleci.com) requires you only to
add a couple of steps to your
[configuration](https://circleci.com/docs/2.0/configuration-reference/):

```yaml
jobs:
  build:    # or whatever name you choose
    steps:
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.2.0/waldo > .circleci/waldo

      #...
      #... (build steps)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH"
        environment:
          WALDO_UPLOAD_TOKEN: 0123456789abcdef0123456789abcdef  # set to your real upload token
          WALDO_BUILD_PATH: /path/to/YourApp.ipa                # set to your real build path
```

## Uploading a Build with Travis CI

Waldo integration with [Travis CI](https://travis-ci.com) requires you only to
add a few steps to your [.travis.yml](https://docs.travis-ci.com):

```yaml
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin                          # or wherever you prefer
    - WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef   # set to your real upload token
    - WALDO_BUILD_PATH=/path/to/YourApp.ipa                 # set to your real build path

install:
  - curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.2.0/waldo > "$WALDO_CLI_BIN"/waldo
  - chmod +x "$WALDO_CLI_BIN"/waldo

script:
  - "$WALDO_CLI_BIN"/waldo "$WALDO_BUILD_PATH"
```

## Uploading a Build with fastlane

Waldo integration with [fastlane](https://fastlane.tools) requires you only to
add the `waldo` plugin to your project:

```bash
fastlane add_plugin waldo
```

### Uploading an iOS Device Build

Build a new IPA for your app. If you use `gym` (aka `build_ios_app`) to build
your IPA, `waldo` will automatically find and upload the generated IPA.

```ruby
gym(export_method: 'development')                       # or 'ad-hoc'
waldo(upload_token: '0123456789abcdef0123456789abcdef')
```

> **Note:** You _must_ specify the Waldo upload token.

If you do _not_ use `gym` to build your IPA, you will need to explicitly
specify the IPA path to `waldo`:

```ruby
waldo(ipa_path: '/path/to/YourApp.ipa',
      upload_token: '0123456789abcdef0123456789abcdef')
```

### Uploading an iOS Simulator Build

Create a new simulator build for your app.

You can use `gym` (aka `build_ios_app`) to build your app provided that you
supply several parameters in order to convince Xcode to _both_ build for the
simulator _and_ not attempt to generate an IPA:

```ruby
gym(configuration: 'Release',
    derived_data_path: '/path/to/derivedData',
    skip_package_ipa: true,
    skip_archive: true,
    destination: 'generic/platform=iOS Simulator')
```

You can then find your app relative to the derived data path in the
`./Build/Products/Release-iphonesimulator` directory.

Regardless of how you create the actual simulator build for your app, the
upload itself is very simple:

```ruby
waldo(app_path: '/path/to/YourApp.app',
      upload_token: '0123456789abcdef0123456789abcdef')
```

> **Note:** You _must_ specify _both_ the path of the `.app` _and_ the Waldo
> upload token.

### Uploading an Android Build

Build a new APK for your app. If you use `gradle` to build your APK, `waldo`
will automatically find and upload the generated APK.

```ruby
gradle(task: 'assemble',
       build_type: 'Release')
waldo(upload_token: '0123456789abcdef0123456789abcdef')
```

> **Note:** You _must_ specify the Waldo upload token.

If you do _not_ use `gradle` to build your APK, you will need to explicitly
specify the APK path to `waldo`:

```ruby
waldo(apk_path: '/path/to/YourApp.apk',
      upload_token: '0123456789abcdef0123456789abcdef')
```

## Uploading a Build Manually

For the pain-lovers out there, you can also upload your iOS or Android build
_manually_ using `curl`. This is _not_ recommended because there are several
options to the `curl` command that must be specified _exactly_ for the build to
be accepted.

### Uploading an iOS Device Build

```bash
$ UPLOAD_TOKEN=0123456789abcdef0123456789abcdef # set to your real upload token
$ BUILD_PATH=/path/to/YourApp.ipa               # set to your real build path
$ curl --data-binary @"$BUILD_PATH"                     \
       -H "Authorization: Upload-Token $UPLOAD_TOKEN"   \
       -H "Content-Type: application/octet-stream"      \
       -H "User-Agent: Waldo CLI/iOS v1.2.0"            \
       https://api.waldo.io/versions
```

### Uploading an iOS Simulator Build

```bash
$ UPLOAD_TOKEN=0123456789abcdef0123456789abcdef # set to your real upload token
$ BUILD_PATH=/path/to/YourApp.app.zip           # set to your real build path
$ curl --data-binary @"$BUILD_PATH"                     \
       -H "Authorization: Upload-Token $UPLOAD_TOKEN"   \
       -H "Content-Type: application/zip"               \
       -H "User-Agent: Waldo CLI/iOS v1.2.0"            \
       https://api.waldo.io/versions
```

> **Note:** You _must_ zip the simulator app bundle before uploading.

### Uploading an Android Build

```bash
$ UPLOAD_TOKEN=0123456789abcdef0123456789abcdef # set to your real upload token
$ BUILD_PATH=/path/to/YourApp.apk               # set to your real build path
$ curl --data-binary @"$BUILD_PATH"                     \
       -H "Authorization: Upload-Token $UPLOAD_TOKEN"   \
       -H "Content-Type: application/octet-stream"      \
       -H "User-Agent: Waldo CLI/Android v1.2.0"        \
       https://api.waldo.io/versions
```
