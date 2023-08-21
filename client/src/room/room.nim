import common/commonActors
import background

const NUM_BACKGRONDS* = 1

type
    Room* = ref object of RootObj
        layers*: array[NUM_BACKGRONDS, Background]
        camera*: Camera
        # objList*: Tlnobjectlist
        music*: string