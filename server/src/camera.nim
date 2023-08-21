import common/vectors
import common/message
import common/commonActors
import flatty

method update*(camera: Camera): void {.base.} =
    # camera.position.x.inc()
    return

method serialize*(camera: Camera): string {.base, gcsafe.} = 
    return toFlatty(message.Message(header: MessageHeader.CAMERA_DATA, data: toFlatty(camera)))