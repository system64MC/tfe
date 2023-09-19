import common/[vectors, constants, commonActors, serializedObjects, message]
import flatty
import room/room
import tilengine/tilengine

method update*(camera: Camera, room: Room): void {.base, gcsafe.} =
    camera.position.x += 1
    if(camera.position.x > (room.collisions.getCols() * 16 - SCREEN_X).float):
        camera.position.x = (room.collisions.getCols() * 16 - SCREEN_X).float
    # return

# method serialize*(camera: Camera): string {.base, gcsafe.} = 
#     return toFlatty(message.Message(header: MessageHeader.CAMERA_DATA, data: toFlatty(camera)))