type
    MessageHeader* = enum
        PLAYER_DATA,
        BULLET_LIST
        BULLET

    Message* = object
        header*: MessageHeader
        data*: string
        