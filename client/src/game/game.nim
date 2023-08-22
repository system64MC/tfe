import ../room/room
import netty

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

