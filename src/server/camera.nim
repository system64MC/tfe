import ../common/vectors

type
    Camera* = ref object of RootObj
        position: VectorI16

method update*(camera: Camera): void {.base.} =
    camera.position.x.inc()
    