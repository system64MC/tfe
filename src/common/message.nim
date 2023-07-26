type
    MessageHeader* = enum
        PLAYER_DATA,
        BULLET_LIST,
        BULLET_NULL,
        BULLET_DATA,
        CAMERA_DATA,
        EVENT_DESTROY_TILE

    Message* = object
        header*: MessageHeader
        data*: string
        