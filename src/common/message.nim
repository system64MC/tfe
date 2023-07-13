type
    MessageHeader* = enum
        PLAYER_DATA,
        BULLET_LIST,
        BULLET_NULL,
        BULLET_DATA

    Message* = object
        header*: MessageHeader
        data*: string
        