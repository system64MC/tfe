import std/lists
import ../../common/commonActors

type
    BulletList* = object
        list*:array[512, Bullet]
        slotStack: SinglyLinkedList[int]

iterator items*(bulletList: BulletList): Bullet =
    for b in bulletList.list:
        yield b

proc initBulletList*(): BulletList =
    var bl = BulletList()
    for i in 0..<512:
        bl.slotStack.add(i)
    return bl

proc `[]`*(bulletList: BulletList; index: int): Bullet =
    if(index < 0): return bulletList.list[bulletList.slotStack.head.value]
    return bulletList.list[index]

proc `[]=`*(bulletList: var BulletList; index: int, bullet: Bullet): void =
    if(index < 0):
        if(bulletList.slotStack.head == nil): return
        bulletList.list[bulletList.slotStack.head.value] = bullet
        bulletList.slotStack.remove(bulletList.slotStack.head)
        return
    bulletList.list[index] = bullet

proc add*(bulletList: var BulletList, bullet: Bullet) =
    if(bulletList.slotStack.head == nil): return 
    bulletList.list[bulletList.slotStack.head.value] = bullet
    bulletList.slotStack.remove(bulletList.slotStack.head)

proc remove*(bulletList: var BulletList, bullet: Bullet) =
    let index = bullet.bulletId
    bulletList.list[index] = nil
    bulletList.slotStack.add(index.int)

proc remove*(bulletList: var BulletList, index: int) =
    bulletList.list[index] = nil
    bulletList.slotStack.add(index.int)

proc getFreeIndex*(bulletList: BulletList): int =
    return bulletList.slotStack.head.value