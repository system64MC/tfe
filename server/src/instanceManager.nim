import netty
import gameInstance
import std/[tables, options, lists, sets, threadpool, os]
import database/orm/models
import common/[message, credentials]
import flatty
import crypto
import ipComp

type
    InstanceMan = ref object
        server*: Reactor
        instanceList: Table[string, GameInstance]
        
        freePorts: SinglyLinkedList[netty.Port] # Free ports between 51731 and 51986
        connectionsToVerify: HashSet[Address]

# var threadList: array[256, Thread[GameInstance]]


import random
proc randomStr(): string =
  randomize()
  for _ in 0..<8:
    add(result, char(rand(int('a')..int('z'))))

type
    ErrorCreate = enum
        NONE,
        NOT_MASTER,
        NOT_EXIST,
        SESSION_FINISHED,
        PORTS_FULL

proc getInstanceFromDatabase(instanceMan: InstanceMan, user: UserORM, code: string): tuple[error: ErrorCreate, port: Option[Port]] =
    if(instanceMan.freePorts.head == nil): return (PORTS_FULL, none(Port))
    let game = getGameByCode(code)
    if(game.isNone):
        return (NOT_EXIST, none(Port))
    echo "the game exists"
    if(game.get().state in {GameORMState.HAS_FINISHED, GameORMState.GAME_OVER}):
        return (SESSION_FINISHED, none(Port))
    if(game.get().creator.pseudo != user.pseudo): return (NOT_MASTER, none(Port))

    let port = instanceMan.freePorts.head.value
    # TODO : Caution, deep copy involved, check for bugs.
    # TODO : I need to fix a bug here
    var players = getPlayersByGame(game.get())
    if(players.isNone): return
    var playersGame = players.get()
    var myGame = game.get()
    let instance = loadGameInstanceSave(myGame, playersGame, user, port)
    discard instanceMan.freePorts.remove(instanceMan.freePorts.head)
    spawn instance.bootGameInstance2()
    instanceMan.instanceList[code] = instance
    echo port.uint16
    return (NONE, some(port))

proc getInstanceByCode(instanceMan: InstanceMan, user: UserORM, code: string): tuple[error: ErrorCreate, port: Option[Port]] =
    let instance = instanceMan.instanceList.getOrDefault(code, nil)
    if(instance != nil):
        echo "Game already loaded!"
        return (NONE, some(instance.server.address.port))
    else:
        echo "Game not loaded, looking in database..."
        return instanceMan.getInstanceFromDatabase(user, code)
        # return (PORTS_FULL, none(Port))
    # let instance = instanceMan.instanceList[code]
    # TODO : if instance not in list, try to find it from database

proc createInstance(instanceMan: InstanceMan, master: UserORM): Option[Port] {.gcsafe.} =
    if(instanceMan.freePorts.head == nil): return none(Port)
    let str = randomStr()
    var port = instanceMan.freePorts.head.value
    let inst = newGameInstance(port, master, str)
    # instanceMan.freePorts.remove(instanceMan.freePorts.head)
    discard instanceMan.freePorts.remove(instanceMan.freePorts.head)
    var gameInst: Thread[GameInstance]
    # createThread(gameInst, bootGameInstance2, inst)
    spawn inst.bootGameInstance2()
    instanceMan.instanceList[str] = inst
    echo "code : ", str
    echo "Instance created!"
    return some(port)

proc deleteInstance(instanceMan: InstanceMan, code: string) =
    let port = instanceMan.instanceList[code].server.address.port
    var inst = instanceMan.instanceList[code]
    instanceMan.instanceList.del(code)
    echo "deleting"
    instanceMan.freePorts.add(port)

proc kick(server: Reactor, connection: Connection) =
    server.disconnect(connection)

proc authenticate(instanceMan: InstanceMan, msg: netty.Message): bool {.gcsafe.} =
    let mess = fromFlatty(msg.data, message.Message)
    if(instanceMan.connectionsToVerify.contains(msg.conn.address)):
        echo "Checking connection"
        echo "header : ", mess.header
        if((mess.header != ENCRYPTED_CREDENTIALS_DATA and mess.header != ENCRYPTED_CREDENTIALS_WITH_CODE) or mess.data == ""):
            instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
            instanceMan.connectionsToVerify.excl(msg.conn.address)
            # instanceMan.server.kick(msg.conn)
            echo "Connection not OK 1"
            return false
        else:
            var credentials: CredentialsEncrypted
            var code = ""
            if(mess.header == ENCRYPTED_CREDENTIALS_DATA): 
                credentials = fromFlatty(mess.data, CredentialsEncrypted)
            else:
                let tmp = fromFlatty(mess.data, CredentialsEncWithCode)
                credentials = tmp.credentials
                code = tmp.gameCode
            let user = getUserByNameAndPassword($(credentials.name.cstring), $(decrypt(credentials.password).cstring))

            if user.isNone:
                instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
                instanceMan.connectionsToVerify.excl(msg.conn.address)
                # instanceMan.server.kick(msg.conn)
                echo "Connection not OK 2"
                return false
            # var port: Option[Port]
            if(mess.header == ENCRYPTED_CREDENTIALS_DATA):
                let port = instanceMan.createInstance(user.get())
                if(port.isNone):
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_CREATE_GAME, data: "")))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    return false
                instanceMan.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_SERVER, data: $(port.get.uint16))))
                instanceMan.connectionsToVerify.excl(msg.conn.address)
                echo "Connection OK"
                return true
            else:
                let (error, port) = instanceMan.getInstanceByCode(user.get(), $(code.cstring))
                echo error
                case error:
                of NONE:
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_SERVER, data: $(port.get.uint16))))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    echo "Connection OK"
                    return true
                of NOT_EXIST:
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_NOT_EXIST, data: "")))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    return false
                of NOT_MASTER:
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_NOT_MASTER, data: "")))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    return false
                of PORTS_FULL:
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_CREATE_GAME, data: "")))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    return false
                of SESSION_FINISHED:
                    instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_FINISHED, data: "")))
                    instanceMan.connectionsToVerify.excl(msg.conn.address)
                    return false
                # If we have a port, we retrieve the right instance
            #     let instance = instanceMan.getInstanceByCode($(code.cstring))
            #     if(instance == nil): port = none(Port)
            #     else: port = some(instance.server.address.port)
            # if(port.isNone):
            #     instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_CREATE_GAME, data: "")))
            #     instanceMan.connectionsToVerify.excl(msg.conn.address)
            #     return false
            # else: instanceMan.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_SERVER, data: $(port.get.uint16))))
            # instanceMan.connectionsToVerify.excl(msg.conn.address)
            
            # # instanceMan.server.kick(msg.conn)
            # echo "Connection OK"
    return true

proc checkServersToDeref(instanceMan: InstanceMan) {.gcsafe.} =
    let tried = chan.tryRecv()
    if tried.dataAvailable:
        let code = tried.msg
        instanceMan.deleteInstance(code)

proc listen(instanceMan: InstanceMan) {.gcsafe.} =
    instanceMan.checkServersToDeref()

    for connection in instanceMan.server.newConnections:
        instanceMan.connectionsToVerify.incl(connection.address)

    for msg in instanceMan.server.messages:
        if not instanceMan.authenticate(msg): continue

proc bootInstanceManager*() {.thread.} =
    var instanceMan = InstanceMan()
    for i in 0..<256:
        instanceMan.freePorts.add(Port(51731 + i))

    instanceMan.server = newReactor("0.0.0.0", 51730)
    echo "Instance Manager Booted!"

    while true:
        instanceMan.server.tick()
        instanceMan.listen()