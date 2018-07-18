# Waldo CLI

[![License](https://img.shields.io/cocoapods/l/WaldoCLI.svg?style=flat)](http://cocoapods.org/pods/WaldoCLI)
[![Platform](https://img.shields.io/cocoapods/p/WaldoCLI.svg?style=flat)](https://cocoapods.org/pods/WaldoCLI)

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

The Waldo CLI is distributed as an installation package. Simply download the
appropriate installation package from [here] and double-click it.

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

Typically, you will run the Waldo CLI from a build phase in your Xcode project.
See ??? for details.

## <a name="credits">Credits</a>

Your friends at Waldo (info@waldo.io)

## <a name="license">License</a>

The Waldo CLI is available under [commercial license].

[commercial license]:   https://github.com/waldoapp/WaldoCLI/blob/master/LICENSE.md
[here]:                 https://github.com/waldoapp/WaldoCLI/releases
