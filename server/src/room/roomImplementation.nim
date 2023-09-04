import room
import ../camera
import common/[vectors, constants, commonActors, serializedObjects, message]
import ../actors/actors
import ../actors/bulletList
import ../actors/implementations/[player, bullet]
import tilengine/tilengine
import std/tables
import ../gameInfos
import netty
import std/[options, json, strformat]
import ../ipComp

proc updatePlayers(room: Room, infos: var GameInfos) =
    for p in room.playerList:
        if(p != nil): p.update(infos)

proc updateBullets(room: Room, infos: var GameInfos) =
    for b in infos.loadedRoom.bulletList:
        if(b == nil): continue
        if(b.bulletType < 0):
            room.bulletList.remove(b)
            continue
        if(b.position.x > SCREEN_X or b.position.x < 0 or
            b.position.y > SCREEN_Y or b.position.y < 0):
            room.bulletList.remove(b)
            continue

        b.update(infos)


    # for i in 0..<game.infos.loadedRoom.bulletList.list.len:
    #     var b = game.infos.loadedRoom.bulletList[i]
    #     if(b == nil): continue
    #     if(b.bulletType < 0):
    #         game.infos.loadedRoom.bulletList.remove(i)
    #         continue
    #     if(b.position.x > SCREEN_X or b.position.x < 0 or
    #         b.position.y > SCREEN_Y or b.position.y < 0):
    #         game.infos.loadedRoom.bulletList.remove(i)
    #         continue
    #     b.update(game.infos)

proc update*(room: Room, infos: var GameInfos): void =
    room.camera.update()
    room.updatePlayers(infos)
    room.updateBullets(infos)

proc getDestroyableTiles(room: var Room): void =
    var buffer = initTable[VectorI64, bool]()
    var tile = Tile()
    for row in 0..<room.collisions.getRows():
        for col in 0..<room.collisions.getCols():
            tile = room.collisions.getTile(row, col)
            if tile.index.Collision == DESTROYABLE_TILE:
                buffer[VectorI64(x: col.int, y: row.int)] = true
    room.destroyableTilesList = buffer

proc setupMap*(room: var Room, level: int) =
    let json = readFile(fmt"./assets/levels/{level}.json")
    let jNode = parseJson(json)
    let tmxPath = jNode["tilemap"].getStr()
    room.collisions = loadTilemap(tmxPath, "collisions")
    room.camera = Camera(position: VectorF64(x: 0, y: 0))
    room.getDestroyableTiles()

proc loadRoom*(path: string): Room =
    var room = Room()
    room.collisions = loadTilemap(path, "collisions")
    room.camera = Camera(position: VectorF64(x: 0, y: 0))
    room.switchOn = true
    room.getDestroyableTiles()
    
    # let actorMap = tiledMap.tiledMap.layers[2]

    # for obj in actorMap.objects:
    #     case obj.id.ActorType
    #         of ENNEMY:
    #             room.actorList.add(
    #                 Ennemy(
    #                     position: VectorI16(x: obj.x.int16, y: obj.y.int16),
    #                     ennemyType: 0,
    #                     lifePoints: 100,
    #                 )
    #             )
    return room

proc onDisconnect*(room: Room, address: Address, infos: var GameInfos) =
    if infos.master.address.get == address:
        infos.state = DEAD_GAME

    for p in room.playerList:
        if p == nil: continue
        if p.address.isNone: continue
        if address == p.address.get():
            p.address = none(Address)
            p.state = PLAYER_DISCONNETED
            break

proc serializePlayers(room: Room): array[4, PlayerSerialize] =
    var arr: array[4, PlayerSerialize]
    for i in 0..<room.playerList.len:
        let p = room.playerList[i]
        if(p != nil and p.address.isSome):
            arr[i] = p.serialize()
    return arr

import flatty

proc serialize*(room: Room): string =
    var r = RoomSerialize(
        camera: room.camera,
        switchOn: room.switchOn,
        bulletList: room.bulletList.list,
        playerList: room.serializePlayers()
    )
    return toFlatty(r)