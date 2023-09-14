import common/commonActors
import common/serializedObjects
import common/constants
import background
import tilengine/tilengine
import ../music/music

const NUM_BACKGRONDS* = 3

type
    RoomKind* = enum
        ROOM_TITLE,
        ROOM_HUB,
        ROOM_LEVEL,
        ROOM_SCORE,
        ROOM_MUSIC,
        ROOM_GAMEOVER,
        ROOM_FINISHED,

    RoomState* = enum
        NONE,
        WAITING_HUB_TRANSFER,
        CHARACTER_SELECTED

    Room* = ref object
        kind*: RoomKind
        layers*: array[NUM_BACKGRONDS, Background]
        bitmap*: Bitmap
        # objList*: Tlnobjectlist
        music*: string
        data*: RoomSerialize
        hubData*: HubSerialize
        cursor*: Cursor
        needSwitching*: bool
        switchState*: bool
        state*: RoomState
        finalScore*: int
        validateCounter*: int
        scoreList*: seq[GameScoreSerialize] = newSeq[GameScoreSerialize](0)

    TitleChoices* = enum
        JOIN_GAME,
        CREATE_GAME,
        SCORES,
        MUSIC_ROOM,
        EXIT

    Cursor* = object
        position*: int
        timer*: int

