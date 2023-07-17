import ../common/vectors

type
    Camera* = ref object of RootObj
        position*: VectorF64