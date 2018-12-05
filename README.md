# Waldo CLI

[![License](https://img.shields.io/badge/license-MIT-000000.svg?style=flat)][license]
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS-lightgrey.svg?style=flat)

## About Waldo

[Waldo](https://www.waldo.io) provides fast, reliable, and maintainable tests
for the most critical flows in your app. Waldo CLI is a command-line tool which
allows you to upload an iOS or Android build to Waldo for processing.

Simply download the `waldo` executable for the [latest release][release] and
install it into `/usr/local/bin`. You can verify that you have installed it
correctly with the `which waldo` and `waldo --help` commands.

If you ever need to uninstall Waldo CLI, simply delete the executable from
`/usr/local/bin`.

## Usage

To get started, first obtain an API key and an application ID from Waldo for
your app. These are used to authenticate with the Waldo backend on each call.

Build a new IPA or APK for your app and specify the path to it (along with the
Waldo API key and application ID) on the `waldo` command invocation:

```bash
$ waldo --key 0123456789abcdef0123456789abcdef \
        --application app-0123456789abcdef     \
        /path/to/YourApp.ipa
```

Alternatively, you can use a configuration file to provide the Waldo API key
and application ID. Simply create a plain text file named `.waldo.yml`. (If you
prefer, you can name it `.waldo.yaml` instead.) Add the following two lines:

```yaml
api_key: 0123456789abcdef0123456789abcdef
application_id: app-0123456789abcdef
```

Make sure you replace the fake application ID and API key values shown above
with the real credential values for your Waldo application.

By default, Waldo CLI looks for your configuration file in the current working
directory. You can provide an explicit path to your configuration file by
specifying the `--configuration` option on the `waldo` command:

```bash
$ waldo --configuration /path/to/.waldo.yml \
        /path/to/YourApp.apk
```

And as a final alternative, you can use environment variables to provide the
Waldo API key and application ID to Waldo CLI:

```bash
$ export WALDO_API_KEY=0123456789abcdef0123456789abcdef
$ export WALDO_APPLICATION_ID=app-0123456789abcdef
$ waldo /path/to/YourApp.ipa
```

[license]:  https://github.com/waldoapp/waldo-cli/blob/master/LICENSE
[release]:  https://github.com/waldoapp/waldo-cli/releases
