# Package

version       = "0.1.0"
author        = "System64MC"
description   = "A new awesome nimble package"
license       = "Proprietary"
srcDir        = "src"
binDir        = "out"
bin           = @["server"]


# Dependencies

requires "nim >= 2.0.0"
requires "file:///C:/Users/nicol/Documents/programmation/TFE/common"
requires "flatty"
requires "netty"
requires "libsodium"
requires "https://github.com/system64MC/nim-tilengine"
requires "supersnappy"
requires "jester"
requires "norm"
requires "nimcrypto"
requires "regex"