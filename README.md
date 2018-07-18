# Waldo CLI

[![License](https://img.shields.io/badge/license-Commercial-lightgrey.svg?style=flat)][commercial license]
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat)
[![Release](https://img.shields.io/github/release/waldoapp/waldocli.svg?style=flat)][release]

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The Waldo CLI is a command-line tool for uploading your iOS app binary to the
Waldo backend for processing.

## <a name="requirements">Requirements</a>

* macOS 10.10+

## <a name="installation">Installation</a>

The Waldo CLI is distributed as an installation package. Simply download and
run the `WaldoCLI-x.y.z.pkg` file for the latest [release], then follow the
on-screen instructions.

When the installation completes, you should find that a single executable named
`waldo` has been installed into `/usr/local/bin`. You can can confirm this with
the following command:

```
$ which waldo
/usr/local/bin/waldo
```

You can also verify that the Waldo CLI is correctly installed:

```
$ waldo version
Waldo CLI 1.0.0 (macOS)
```

If you ever need to uninstall the Waldo CLI, simply delete the executable from
`/usr/local/bin`:

```
$ rm -f /usr/local/bin/waldo
```

## <a name="usage">Usage</a>

Typically, you will invoke the `waldo upload` command from a build phase in
your Xcode project in conjunction with a configuration file.

See ??? for details.

## <a name="credits">Credits</a>

Your friends at Waldo (info@waldo.io)

## <a name="license">License</a>

The Waldo CLI is available under [commercial license].

[commercial license]:   https://github.com/waldoapp/WaldoCLI/blob/master/LICENSE.md
[release]:              https://github.com/waldoapp/WaldoCLI/releases
