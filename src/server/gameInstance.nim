import std/[times, os]
import ./actors/implementations/player
import ./actors/implementations/bullet
import ./actors/bulletList
import ../common/[vectors, message, events, constants]
import camera
import room/[room, roomImplementation]
import netty
import flatty
import std/threadpool
import tilengine/tilengine
import math
import gameInfos
import ./actors/actors
import std/monotimes
import std/tables

type
    GameInstance* = ref object
        infos*: GameInfos
        server*: Reactor

proc fetchMessages*(game: GameInstance) {.gcsafe.} =
    for msg in game.server.messages:
        let data = fromFlatty(msg.data, message.Message)
        if(data.header == MessageHeader.EVENT_INPUT):
            let e = fromFlatty(data.data, events.EventInput)
            game.infos.loadedRoom.playerList[0].input = game.infos.loadedRoom.playerList[0].input or e.input
            let t = getTime().toUnixFloat()
            let duration = (t - e.sentAt)
            game.infos.loadedRoom.playerList[0].deltaTimeAccumulator += duration
            game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues.inc
    if(game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues >= 64):
        let avg = game.infos.loadedRoom.playerList[0].deltaTimeAccumulator / game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues.float
        game.infos.loadedRoom.playerList[0].deltaTime = clamp(avg, MINIMAL_LATENCY, MAX_LATENCY)
        game.infos.loadedRoom.playerList[0].deltaTimeAccumulator = 0
        game.infos.loadedRoom.playerList[0].deltaTimeHowManyValues = 0

proc update*(game: GameInstance): void {.gcsafe.} =
    game.infos.eventList.setLen(0)
    game.infos.loadedRoom.update(game.infos)

import supersnappy
proc serialize*(game: GameInstance): void {.gcsafe.} =
    let d = compress(game.infos.loadedRoom.serialize())
    let roomData = toFlatty(message.Message(header: MessageHeader.ROOM_DATA, data: d))

    # Sending data to the server.
    for connection in game.server.connections:
        game.server.send(connection, roomData)

    # Sending events to the server.
    for e in game.infos.eventList:
        let data = e.toFlatty()
        for connection in game.server.connections:
            game.server.send(connection, data)

proc init*(game: GameInstance): void =
    game.infos.eventList = newSeq[message.Message](0)
    game.infos.loadedRoom = Room()
    game.infos.loadedRoom.bulletList = initBulletList()
    var player = constructPlayer(VectorF64(x: 50, y: 50), 0, 5)
    game.infos.loadedRoom.playerList[0] = player
    # We load the test room.
    game.infos.loadedRoom.setupMap("assets/tilemaps/testRoom.tmx")

    # Creating the server, listening on the ELIS port (Port 5173)
    game.server = newReactor("127.0.0.1", 5173)
    echo "Server booted! Listening for 📦 packets! 📦"

proc checkNewDeadConnections(game: GameInstance): void {.gcsafe.} =
    for connection in game.server.newConnections:
        game.server.send(connection, toFlatty(message.Message(header: DESTROYABLE_TILES_DATA, data: toFlatty(game.infos.loadedRoom.destroyableTilesList))))
        let switchEvent = EventSwitch(state: game.infos.loadedRoom.switchOn)
        let m = message.Message(header: message.EVENT_SWITCH, data: toFlatty(switchEvent))
        game.server.send(connection, toFlatty(m))
        echo "[new] ", connection.address
        echo "[SERVER : ]", game.server.address

    for connection in game.server.deadConnections:
        echo "[dead] ", connection.address

proc beginTick(game: GameInstance) =
    game.server.tick()
    game.infos.timeStart = cpuTime().float
    game.infos.delta = (game.infos.timeStart - game.infos.timeFinish).float

proc endTick(game: GameInstance) =
    game.infos.timeFinish = cpuTime()
    game.infos.delta = game.infos.timeFinish - game.infos.timeStart
    game.infos.frame.inc
    if(game.infos.delta < TPS_DELAY):
        sleep((TPS_DELAY - game.infos.delta).int)

proc bootGameInstance*() {.thread.} =
    var game = GameInstance()
    game.init()

    # Main game loop
    while true:
        game.beginTick()

        game.fetchMessages()
        game.update()
        game.serialize()
        game.checkNewDeadConnections()

        game.endTick()