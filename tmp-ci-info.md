--------------------------------------------------------------------------------
fastlane

Waldo integration with <0>fastlane</0> requires you only to add the
<1>waldo</1> plugin to your project:

```
fastlane add_plugin waldo
```

Next, generate a simulator build of your app and upload it to Waldo.

```
#...
#... simulator build step e.g.
#... gym(configuration: 'Release',
#...     derived_data_path: '/path/to/derivedData',
#...     skip_package_ipa: true,
#...     skip_archive: true,
#...     destination: 'generic/platform=iOS Simulator')
#...
waldo(app_path: '/path/to/YourApp.app',
      upload_token: '${apiKey}')
```

Along with uploading your app, the fastlane waldo plugin also allows you to
supply the path of the dSYM(s) for your app. While this is optional, we highly
recommend it. With this additional information we will be able to
<0>automatically symbolicate</0> any crash reports that might be generated from
your app.

Next, build a new development IPA for your app. <0>If you use gym</0> (aka
build_ios_app) to build your IPA, waldo will automatically find the path of the
generated IPA.

```
#...
#... build step using gym, e.g.
#... gym(export_method:'ad-hoc')
#...
#
# Note: The "dsym_path" parameter is optional but we highly recommend supplying it.
#
waldo(upload_token: '${apiKey}',
      dsym_path: lane_context[SharedValues::DSYM_OUTPUT_PATH])
```

<0>If you do not use gym</0> to build your IPA, you will need to explicitly
specify the IPA path:

```
#...
#... build step to produce an .ipa (and associated .dSYM)
#...
#
# Note: The "dsym_path" parameter is optional but we highly recommend supplying it.
#
waldo(upload_token: '${apiKey}',
      ipa_path: '/path/to/YourApp.ipa',
      dsym_path: '/path/to/YourApp.app.dSYM.zip')
```

--------------------------------------------------------------------------------
App Center

Waldo integration with <0>App Center</0> requires you only to add a couple of
<1>custom build steps</1>.

Add the following to <0>appcenter-post-clone.sh</0>:

```
WALDO_CLI_BIN=/usr/local/bin

curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
chmod +x "$WALDO_CLI_BIN"/waldo
```

Add the following to <0>appcenter-post-build.sh</0>:

```
WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=${apiKey}

BUILD_PATH=$APPCENTER_OUTPUT_DIRECTORY/YourApp.${extension}

"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"
```

--------------------------------------------------------------------------------
Bitrise

Along with uploading your app, Waldo CLI also allows you to supply the path of
the dSYM(s) for your app. While this is optional, we highly recommend it. With
this additional information we will be able to <0>automatically symbolicate</0>
any crash reports that might be generated from your app.

Waldo integration with <0>Bitrise</0> requires you only to add a <1>custom
Script step</1> to your workflow containing the following:

```
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin

if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi

#... (Xcode build for simulator)

export WALDO_UPLOAD_TOKEN=${apiKey}

"$WALDO_CLI_BIN"/waldo "$BITRISE_APP_DIR_PATH"
```

```
#!/bin/bash

set -ex

WALDO_CLI_BIN=/usr/local/bin

if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi

#... (Xcode Archive & Export for iOS)
# Note: BITRISE_DSYM_PATH is optional but recommended

export WALDO_UPLOAD_TOKEN=${apiKey}

"$WALDO_CLI_BIN"/waldo "$BITRISE_IPA_PATH" "$BITRISE_DSYM_PATH"
```

--------------------------------------------------------------------------------
CircleCI

Along with uploading your app, Waldo CLI also allows you to supply the path of
the dSYM(s) for your app. While this is optional, we highly recommend it. With
this additional information we will be able to <0>automatically symbolicate</0>
any crash reports that might be generated from your app.

Waldo integration with <0>CircleCI</0> requires you only to add a couple of
steps to your <1>configuration</1>:

```
jobs:
  build:
    steps:
      - checkout
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs ${cliLocation} > .circleci/waldo
          chmod +x .circleci/waldo

      #...
      #... (build steps)
      #...

      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH"
        environment:
          WALDO_UPLOAD_TOKEN: ${apiKey}
          WALDO_BUILD_PATH: /path/to/YourApp.${extension}
```

```
jobs:
  build:
    steps:
      - checkout
      - run:
        name: Download Waldo CLI
        command: |
          curl -fLs ${cliLocation} > .circleci/waldo
          chmod +x .circleci/waldo
      #...
      #... (build steps)
      #...
      - run:
        name: Upload build to Waldo
        command: .circleci/waldo "$WALDO_BUILD_PATH" "$WALDO_DSYM_PATH"
        environment:
          WALDO_UPLOAD_TOKEN: ${apiKey}
          WALDO_BUILD_PATH: /path/to/YourApp.${extension}
          # Note that WALDO_DSYM_PATH is optional but highly recommended
          WALDO_DSYM_PATH: /path/to/YourApp.app.dSYM.zip
```

--------------------------------------------------------------------------------
Travis CI

Along with uploading your app, Waldo CLI also allows you to supply the path of
the dSYM(s) for your app. While this is optional, we highly recommend it. With
this additional information we will be able to <0>automatically symbolicate</0>
any crash reports that might be generated from your app.

Waldo integration with <0>Travis CI</0> requires you only to add a few steps to
your <1>.travis.yml</1>:

```
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin
    - WALDO_UPLOAD_TOKEN=${apiKey}
    - WALDO_BUILD_PATH=/path/to/YourApp.${extension}

install:
  - curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  - chmod +x "$WALDO_CLI_BIN"/waldo

script:
  - "$WALDO_CLI_BIN"/waldo "$WALDO_BUILD_PATH"
```

```
env:
  global:
    - WALDO_CLI_BIN=/usr/local/bin
    - WALDO_UPLOAD_TOKEN=${apiKey}
    - WALDO_BUILD_PATH=/path/to/YourApp.${extension}
    - WALDO_DSYM_PATH=/path/to/YourApp.app.dSYM.zip

install:
  - curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  - chmod +x "$WALDO_CLI_BIN"/waldo

# Note that WALDO_DSYM_PATH is optional but highly recommended
script:
  - "$WALDO_CLI_BIN"/waldo "$WALDO_BUILD_PATH" "$WALDO_DSYM_PATH"
```

--------------------------------------------------------------------------------
Manual

Along with uploading your app, Waldo CLI also allows you to supply the path of
the dSYM(s) for your app. While this is optional, we highly recommend it. With
this additional information we will be able to <0>automatically symbolicate</0>
any crash reports that might be generated from your app.

If you are building outside of CI/CD or in another CI provider, you can also
upload your iOS build manually using Waldo CLI.

```
WALDO_CLI_BIN=/usr/local/bin
if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi
#...
#... (generate .app and associated .dSYM)
#...
export WALDO_UPLOAD_TOKEN=${apiKey}
BUILD_PATH=/path/to/YourApp.app
"$WALDO_CLI_BIN"/waldo "$BUILD_PATH"
```

```
WALDO_CLI_BIN=/usr/local/bin
if [ ! -e "$WALDO_CLI_BIN"/waldo ]; then
  curl -fLs ${cliLocation} > "$WALDO_CLI_BIN"/waldo
  chmod +x "$WALDO_CLI_BIN"/waldo
fi
#...
#... (generate .ipa and associated .dSYM)
#...
export WALDO_UPLOAD_TOKEN=${apiKey}
BUILD_PATH=/path/to/YourApp.${extension}
# Note that DSYM_PATH is optional but highly recommended
DSYM_PATH=/path/to/YourApp.app.dSYM.zip
"$WALDO_CLI_BIN"/waldo "$BUILD_PATH" "$DSYM_PATH"
```
