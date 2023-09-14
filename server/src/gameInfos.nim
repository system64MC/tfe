import common/message
import ./actors/actors
import room/room
import hub/hub
import std/lists

type
    GameState* = enum
        HUB,
        LEVEL,
        DEAD_GAME,
        WAIT_READY,
        GAME_OVER,
        LEVEL_FINISHED,
        GAME_FINISHED,

    GameInfos* = object
        eventList*: seq[message.Message]
        timeStart*: float64
        timeFinish*: float64
        delta*: float64
        frame*: int
        loadedRoom*: Room
        hub*: Hub
        state*: GameState
        master*: Player