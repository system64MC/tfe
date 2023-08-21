# Package

version       = "0.1.0"
author        = "System64MC"
description   = "A new awesome nimble package"
license       = "Proprietary"
srcDir        = "src"
binDir        = "out"
bin           = @["client"]


# Dependencies

requires "nim >= 2.0.0"
requires "file:///C:/Users/nicol/Documents/programmation/tfeTest/common"
requires "flatty"
requires "netty"
requires "libsodium"
requires "https://github.com/system64MC/nim-tilengine"
requires "supersnappy"
requires "regex"
requires "nimgl"
requires "imgui"