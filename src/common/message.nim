type
    MessageHeader* = enum
        PLAYER_DATA,
        BULLET_LIST,
        BULLET_NULL,
        BULLET_DATA,
        CAMERA_DATA,
        DESTROYABLE_TILES_DATA,
        EVENT_DESTROY_TILE,
        EVENT_SWITCH,
        EVENT_INPUT

    Message* = object
        header*: MessageHeader
        data*: string
        