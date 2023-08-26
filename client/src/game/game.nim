import ../room/room
import netty
import common/[credentials]

type
    GameState* = enum
        TITLE_SCREEN,
        MUSIC_ROOM,
        HUB,
        GAME_LEVEL

    Game* = ref object
        state*: GameState
        room*: Room
        client*: Reactor
        connection*: Connection
        frame*: int
        credentials*: CredentialsEncrypted

var frame* = 0