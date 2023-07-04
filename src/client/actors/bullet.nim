import actor
import ../../common/vectors
import tilengine/bitmapUtils
import ../room/background

type
    Bullet* = ref object of Actor
        bulletType*: int
        isPlayer*: bool
        vector*: VectorF64

method draw*(bullet: Bullet): void =
    bitmap.drawCircleFill(Point(x: bullet.position.x.int, y: bullet.position.y.int), 4)