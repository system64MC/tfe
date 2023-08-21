import database/orm/models
import flatty
import netty
import common/message
import common/credentials
import crypto
import std/options
import std/sets

type
    Hub = ref object
        game: GameORM
        players: array[4, PlayerORM]
        server: Reactor
        connectionsToVerify: HashSet[Connection]

import random
proc randomStr(): string =
  for _ in 0..<8:
    add(result, char(rand(int('a')..int('z'))))

proc hasFreeSlots(hub: Hub): int =
    for i in 0..<hub.players.len:
        let p = hub.players[i]
        if(p == nil): return i
    return -1

proc kick(server: Reactor, connection: Connection) =
    server.disconnect(connection)

proc authenticate(hub: Hub, msg: netty.Message): bool =
    let mess = fromFlatty(msg.data, message.Message)
    if msg.conn in hub.connectionsToVerify:
        if(mess.header != ENCRYPTED_CREDENTIALS_DATA):
            hub.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
            hub.connectionsToVerify.excl(msg.conn)
            hub.server.kick(msg.conn)
            return false
        else:
            let credentials = fromFlatty(mess.data, CredentialsEncrypted)
            let user = getUserByNameAndPassword(credentials.name, decrypt(credentials.password))

            if user.isNone:
                hub.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
                hub.connectionsToVerify.excl(msg.conn)
                hub.server.kick(msg.conn)
                return false
            else:
                # We create the player...
    return true

proc update(hub: Hub): void =
    for msg in hub.server.messages:
        if not hub.authenticate(msg): continue
             
    # On player connection, if no more space,
    # send message and close the connection.
    for c in hub.server.newConnections:
        if hub.hasFreeSlots() == -1:
            hub.server.send(c, toFlatty(message.Message(header: ERROR_FULL, data: "")))
            hub.server.kick(c)
        else:
            hub.connectionsToVerify.incl(c)
            # hub.connectionsToVerify.add(c)

proc init(hub: Hub): void =
    while not hub.game.hasStarted:
        hub.update()

proc createHub(user: UserORM): void =
    var hub = Hub()
    # hub.connectionsToVerify = newSeq[Connection]()
    hub.connectionsToVerify = initHashSet[Connection]()
    # We create a new hub with a random ID.
    hub.game = newGame(user, randomStr())
    # Create server here...
    # init the hub. Might be nice to init it in a thread.
    hub.init()


