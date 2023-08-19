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
        ERROR_FULL
        ERROR_STARTED
        ERROR_AUTH
        ENCRYPTED_CREDENTIALS_DATA

    Message* = object
        header*: MessageHeader
        data*: string
        