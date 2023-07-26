import ../common/vectors
import ../common/message
import flatty

type
    Camera* = ref object of RootObj
        position*: VectorF64
        velocity*: VectorF64

method update*(camera: Camera): void {.base.} =
    # camera.position.x.inc()
    return

method serialize*(camera: Camera): string {.base.} = 
    return toFlatty(message.Message(header: MessageHeader.CAMERA_DATA, data: toFlatty(camera)))