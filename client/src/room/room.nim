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
        ROOM_MUSIC

    RoomState* = enum
        NONE
        WAITING_HUB_TRANSFER

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

    TitleChoices* = enum
        JOIN_GAME,
        CREATE_GAME,
        SCORES,
        MUSIC_ROOM,
        EXIT

    Cursor* = object
        position*: int
        timer*: int

