import vectors
type
    EventTileChange* = object
        coordinates*: VectorI64
        tileType*: uint16
    EventSwitch* = object
        state*: bool