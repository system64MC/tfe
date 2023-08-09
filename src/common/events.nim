import vectors
import std/monotimes

type
    EventTileChange* = object
        coordinates*: VectorI64
        tileType*: uint16

    EventSwitch* = object
        state*: bool

    EventInput* = object
        input*: byte
        sentAt*: float
