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
        EVENT_INPUT,
        # If the game is full
        ERROR_FULL,
        # If game not full but already begun
        ERROR_STARTED,
        # Auth error
        ERROR_AUTH,
        ENCRYPTED_CREDENTIALS_DATA,
        ROOM_DATA

    Message* = object
        header*: MessageHeader
        data*: string
        