# CI Integration

## Uploading a Build with fastlane

Waldo integration with [fastlane](https://fastlane.tools) requires you only to
add the `waldo` plugin to your project:

```bash
$ fastlane add_plugin waldo
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

You can then find your app (and associated symbols) relative to the derived
data path:

```ruby
app_path = File.join(derived_data_path,
                     'Build',
                     'Products',
                     'ReleaseSim-iphonesimulator',
                     'YourApp.app')
```

Regardless of how you create the actual simulator build for your app, the
upload itself is very simple:

```ruby
waldo(upload_token: '0123456789abcdef0123456789abcdef',
      app_path: '/path/to/YourApp.app',
      include_symbols: true)
```

> **Note:** You _must_ specify _both_ the Waldo upload token _and_ the path of
> the `.app`. The `include_symbols` parameter is optional but we highly
> recommend supplying it.

### Uploading an iOS Device Build

Build a new IPA for your app. If you use `gym` (aka `build_ios_app`) to build
your IPA, `waldo` will automatically find and upload the generated IPA.

```ruby
gym(export_method: 'ad-hoc')                            # or 'development'

waldo(upload_token: '0123456789abcdef0123456789abcdef',
      dsym_path: lane_context[SharedValues::DSYM_OUTPUT_PATH])
```

> **Note:** You _must_ specify the Waldo upload token. The `dsym_path`
> parameter is optional but we highly recommend supplying it.

If you do _not_ use `gym` to build your IPA, you will need to explicitly
specify the IPA path to `waldo`:

```ruby
waldo(upload_token: '0123456789abcdef0123456789abcdef',
      ipa_path: '/path/to/YourApp.ipa',
      dsym_path: '/path/to/YourApp.app.dSYM.zip')
```

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
waldo(upload_token: '0123456789abcdef0123456789abcdef',
      apk_path: '/path/to/YourApp.apk')
```

----------

## Uploading a Build with App Center

Waldo integration with [App Center](https://appcenter.ms) requires you only to
add a couple of [custom build
steps](https://docs.microsoft.com/en-us/appcenter/build/custom/scripts/).

In all cases, add the following to `appcenter-post-clone.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
chmod +x ${WALDO_CLI_BIN}/waldo
```

### Uploading an iOS Simulator Build

_Not supported by the CI._

### Uploading an iOS Device Build

Add the following to `appcenter-post-build.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=${APPCENTER_OUTPUT_DIRECTORY}/YourApp.ipa
SYMBOLS_PATH=${AGENT_BUILDDIRECTORY}/output/build/archive/YourApp.xcarchive

${WALDO_CLI_BIN}/waldo "$BUILD_PATH" "$SYMBOLS_PATH"
```

> **Note:** The `SYMBOLS_PATH` parameter is optional but we highly recommend
> supplying it.

### Uploading an Android Build

Add the following to `appcenter-post-build.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=${APPCENTER_OUTPUT_DIRECTORY}/YourApp.apk

${WALDO_CLI_BIN}/waldo "$BUILD_PATH"
```

----------

## Uploading a Build with Bitrise

### Uploading an iOS Simulator Build

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a [custom `Script`
step](https://devcenter.bitrise.io/tips-and-tricks/install-additional-tools/)
to your workflow containing the following:

```bash
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

${WALDO_CLI_BIN}/waldo "$BITRISE_APP_DIR_PATH" --include-symbols
```

> **Note:** The `--include-symbols` option is optional but we highly recommend
> supplying it.

### Uploading an iOS Device Build

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a [custom `Script`
step](https://devcenter.bitrise.io/tips-and-tricks/install-additional-tools/)
to your workflow containing the following:

```bash
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

${WALDO_CLI_BIN}/waldo "$BITRISE_IPA_PATH" "$BITRISE_DSYM_PATH"
```

> **Note:** The `BITRISE_DSYM_PATH` parameter is optional but we highly
> recommend supplying it.

### Uploading an Android Build

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a [custom `Script`
step](https://devcenter.bitrise.io/tips-and-tricks/install-additional-tools/)
to your workflow containing the following:

```bash
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

${WALDO_CLI_BIN}/waldo "$BITRISE_APK_PATH"
```

----------

## Uploading a Build with buddybuild

Waldo integration with [buddybuild](https://www.buddybuild.com) requires you
only to add a couple of [custom build
steps](https://docs.buddybuild.com/builds/custom_build_steps.html).

In all cases, add the following to `buddybuild_postclone.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
chmod +x ${WALDO_CLI_BIN}/waldo
```

### Uploading an iOS Simulator Build

Add the following to `buddybuild_postbuild.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=/path/to/YourApp.app

${WALDO_CLI_BIN}/waldo "$BUILD_PATH" --include-symbols
```

> **Note:** The `--include-symbols` option is optional but we highly recommend
> supplying it.

### Uploading an iOS Device Build

Add the following to `buddybuild_postbuild.sh`:

```bash
WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

SYMBOLS_PATH=/tmp/dSYMs.zip

cd $BUDDYBUILD_PRODUCT_DIR

find . -name "*.dSYM" -print | zip "$SYMBOLS_PATH" -@

${WALDO_CLI_BIN}/waldo "$BUDDYBUILD_IPA_PATH" "$SYMBOLS_PATH"
```

> **Note:** The `SYMBOLS_PATH` parameter is optional but we highly recommend
> supplying it.

### Uploading an Android Build

_Not supported by the CI._

----------

## Uploading a Build with CircleCI

### Uploading an iOS Simulator Build

Waldo integration with [CircleCI](https://circleci.com) requires you only to
add a couple of steps to your
[configuration](https://circleci.com/docs/2.0/configuration-reference/):

```yaml
jobs:
  build:
    steps:
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > .circleci/waldo
          chmod +x .circleci/waldo

      #...
      #... (generate .app and associated .dSYM)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH" --include-symbols
        environment:
          WALDO_UPLOAD_TOKEN: 0123456789abcdef0123456789abcdef
          WALDO_BUILD_PATH: /path/to/YourApp.app
```

> **Note:** The `--include-symbols` option is optional but we highly recommend
> supplying it.

### Uploading an iOS Device Build

Waldo integration with [CircleCI](https://circleci.com) requires you only to
add a couple of steps to your
[configuration](https://circleci.com/docs/2.0/configuration-reference/):

```yaml
jobs:
  build:
    steps:
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > .circleci/waldo
          chmod +x .circleci/waldo

      #...
      #... (generate .ipa and associated .dSYM)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH" "$WALDO_SYMBOLS_PATH"
        environment:
          WALDO_UPLOAD_TOKEN: 0123456789abcdef0123456789abcdef
          WALDO_BUILD_PATH: /path/to/YourApp.ipa
          WALDO_SYMBOLS_PATH: /path/to/YourApp.app.dSYM.zip
```

> **Note:** The `WALDO_SYMBOLS_PATH` parameter is optional but we highly
> recommend supplying it.

### Uploading an Android Build

Waldo integration with [CircleCI](https://circleci.com) requires you only to
add a couple of steps to your
[configuration](https://circleci.com/docs/2.0/configuration-reference/):

```yaml
jobs:
  build:
    steps:
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > .circleci/waldo
          chmod +x .circleci/waldo

      #...
      #... (generate .apk)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH"
        environment:
          WALDO_UPLOAD_TOKEN: 0123456789abcdef0123456789abcdef
          WALDO_BUILD_PATH: /path/to/YourApp.apk
```

----------

## Uploading a Build with Travis CI

### Uploading an iOS Simulator Build

Waldo integration with [Travis CI](https://travis-ci.com) requires you only to
add a few steps to your [.travis.yml](https://docs.travis-ci.com):

```yaml
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin
    - WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef
install:
  - curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  - chmod +x ${WALDO_CLI_BIN}/waldo
script:
  #...
  #... Build your app for simulator with:
  #...
  #...     - xcodebuild [...] -derivedDataPath "$TRAVIS_BUILD_DIR" [...] build
  #...
  - BUILD_PATH="$TRAVIS_BUILD_DIR"/Build/Products/Release-iphonesimulator/YourApp.app
  - ${WALDO_CLI_BIN}/waldo "$BUILD_PATH" --include-symbols
```

> **Note:** The `--include-symbols` option is optional but we highly recommend
> supplying it.

### Uploading an iOS Device Build

Waldo integration with [Travis CI](https://travis-ci.com) requires you only to
add a few steps to your [.travis.yml](https://docs.travis-ci.com):

```yaml
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin
    - WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef
install:
  - curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  - chmod +x ${WALDO_CLI_BIN}/waldo
script:
  #...
  #... Build your IPA with:
  #...
  #...     - xcodebuild [...] -archivePath /path/to/YourApp.xcarchive [...] archive
  #...     - xcodebuild -exportArchive [...] -archivePath /path/to/YourApp.xcarchive -exportPath /path/to/export [...]
  #...
  - BUILD_PATH=/path/to/export/YourApp-release.ipa
  - SYMBOLS_PATH=/path/to/YourApp.xcarchive
  - ${WALDO_CLI_BIN}/waldo "$BUILD_PATH" "$SYMBOLS_PATH"
```

> **Note:** The `SYMBOLS_PATH` parameter is optional but we highly recommend
> supplying it.

### Uploading an Android Build

Waldo integration with [Travis CI](https://travis-ci.com) requires you only to
add a few steps to your [.travis.yml](https://docs.travis-ci.com):

```yaml
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin
    - WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef
install:
  - curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  - chmod +x ${WALDO_CLI_BIN}/waldo
script:
  #...
  #... Build your APK
  #...
  - ${WALDO_CLI_BIN}/waldo "/path/to/YourApp.apk"
```

----------

## Uploading a Build Manually

If you are building outside of CI/CD or in another CI provider, you can also
upload your iOS build manually using Waldo CLI.

### Uploading an iOS Simulator Build

```
WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

#...
#... (generate .app and associated .dSYM)
#...

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=/path/to/YourApp.app

${WALDO_CLI_BIN}/waldo "$BUILD_PATH" --include-symbols
```

> **Note:** The `--include-symbols` option is optional but we highly recommend
> supplying it.

### Uploading an iOS Device Build

```
WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

#...
#... (generate .ipa and associated .dSYM)
#...

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=/path/to/YourApp.ipa
SYMBOLS_PATH=/path/to/YourApp.app.dSYM.zip

${WALDO_CLI_BIN}/waldo "$BUILD_PATH" "$SYMBOLS_PATH"
```

> **Note:** The `SYMBOLS_PATH` parameter is optional but we highly recommend
> supplying it.

### Uploading an Android Build

```
WALDO_CLI_BIN=/usr/local/bin

if [ ! -e ${WALDO_CLI_BIN}/waldo ]; then
  curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.6.1/waldo > ${WALDO_CLI_BIN}/waldo
  chmod +x ${WALDO_CLI_BIN}/waldo
fi

#...
#... (generate .apk)
#...

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH=/path/to/YourApp.apk

${WALDO_CLI_BIN}/waldo "$BUILD_PATH"
```
