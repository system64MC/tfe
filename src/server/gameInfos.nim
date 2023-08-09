import ../common/message
import ./actors/actors
import room/room
# import ./actors/player
# import ./actors/bullet
# import ../common/vectors
# import ../common/constants
# import netty
# import flatty
# import tilengine/tilengine


type
    GameInfos* = object
        playerList*: array[4, Player]
        actorList*: array[512, int] # TODO : Replace int by Actor
        # bulletList*:array[512, Bullet] # TODO : Replace int by Bullet
        bulletList*:array[512, Bullet]
        eventList*: seq[message.Message]
        timeStart*: float64
        timeFinish*: float64
        delta*: float64
        frame*: int
        loadedRoom*: Room