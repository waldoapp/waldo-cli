# CI Integration

## Uploading a Build with App Center

Waldo integration with [App Center](https://appcenter.ms) requires you only to
add a couple of build scripts.

Before you can upload a build to Waldo, you must first download Waldo CLI. Add
the following script, named `appcenter-post-clone.sh`, next to the project file
in your repository:

```bash
#!/usr/bin/env bash

set -ex

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > /path/to/waldo

chmod +x /path/to/waldo
```

After you have packaged your build into an IPA or APK, you can upload it by
invoking the `waldo` executable you downloaded earlier. Add the following
script, named `appcenter-post-build.sh`, next to the project file in your
repository:

```bash
/path/to/waldo $APPCENTER_OUTPUT_DIRECTORY/YourApp.ipa \
               --key 0123456789abcdef0123456789abcdef  \
               --application app-0123456789abcdef
```

> **Note:** You can also specify the API key and application ID as environment
> variables available during the build process.

## Uploading a Build with Bitrise

Waldo integration with [Bitrise](https://www.bitrise.io) requires you only to
add a custom `Script` step to your workflow.

Before you can upload a build to Waldo, you must first download Waldo CLI.
After you have packaged your build into an IPA or APK, you can upload it by
invoking the downloaded `waldo` executable. Both of these tasks can be done in
a single custom step. Simply add a new `Script` step to your workflow and write
the following into the `Script content` input:

```bash
#!/bin/bash

set -ex

curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > /path/to/waldo

chmod +x /path/to/waldo

/path/to/waldo $BITRISE_APK_PATH                      \
               --key 0123456789abcdef0123456789abcdef \
               --application app-0123456789abcdef
```

> **Note:** You can also specify the API key and application ID as environment
> variables available to the workflow.

## Uploading a Build with CircleCI

Waldo integration with [Circle CI](https://circleci.com) requires you only to
add a couple of steps to your configuration.

Before you can upload a build to Waldo, you must first download Waldo CLI. Add
the following setup step to your `.circleci/config.yml`:

```yaml
steps:
  #...
  - run:
    name: Download Waldo CLI
    command: |
      curl -fLs https://github.com/waldoapp/waldo-cli/releases/download/1.0.0/waldo > .circleci/waldo
  #...
```

After you have packaged your build into an IPA or APK, you can upload it by
invoking the `waldo` executable you downloaded earlier:

```yaml
steps:
  #...
  - run:
    name: Upload build to Waldo
    command: .circleci/waldo /path/to/YourApp.ipa
    environment:
      WALDO_API_KEY: 0123456789abcdef0123456789abcdef
      WALDO_APPLICATION_ID: app-0123456789abcdef
  #...
```

## Uploading a Build Manually

For the pain-lovers out there, you can also upload your iOS or Android build
_manually_ using `curl`. This is _not_ recommended because there are several
options to the `curl` command that must be specified exactly for the build to
be accepted.

### Uploading an iOS Build

```bash
$ curl --data-binary @"/path/to/YourApp.ipa"                             \
       -H "Authorization: Upload-Token 0123456789abcdef0123456789abcdef" \
       -H "Content-Type: application/octet-stream"                       \
       -H "User-Agent: Waldo CLI/iOS v1.0.0"                             \
       "https://api.waldo.io/versions?variantName=manual"
```

### Uploading an Android Build

```bash
$ curl --data-binary @"/path/to/YourApp.apk"                             \
       -H "Authorization: Upload-Token 0123456789abcdef0123456789abcdef" \
       -H "Content-Type: application/octet-stream"                       \
       -H "User-Agent: Waldo CLI/Android v1.0.0"                         \
       "https://api.waldo.io/versions?variantName=manual"
```
