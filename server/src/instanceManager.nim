import netty
import gameInstance
import std/[tables, options, lists, sets, threadpool, os]
import database/orm/models
import common/[message, credentials]
import flatty
import crypto

type
    InstanceMan = ref object
        server*: Reactor
        instanceList: Table[string, GameInstance]
        
        freePorts: SinglyLinkedList[netty.Port] # Free ports between 51731 and 51986
        connectionsToVerify: HashSet[Address]

# var threadList: array[256, Thread[GameInstance]]

proc `==`(a, b: Port): bool {.borrow.}

import random
proc randomStr(): string =
  for _ in 0..<8:
    add(result, char(rand(int('a')..int('z'))))

proc getInstanceByCode(instanceMan: InstanceMan, code: string): GameInstance =
    let instance = instanceMan.instanceList[code]
    # TODO : if instance not in list, try to find it from database
    return instance

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
    instanceMan.instanceList.del(code)
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
            var port: Option[Port]
            if(mess.header == ENCRYPTED_CREDENTIALS_DATA):
                port = instanceMan.createInstance(user.get())
            else:
                # If we have a port, we retrieve the right instance
                let instance = instanceMan.getInstanceByCode($(code.cstring))
                if(instance == nil): port = none(Port)
                else: port = some(instance.server.address.port)
            if(port.isNone): instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_CREATE_GAME, data: "")))
            else: instanceMan.server.send(msg.conn, toFlatty(message.Message(header: OK_JOIN_SERVER, data: $(port.get.uint16))))
            instanceMan.connectionsToVerify.excl(msg.conn.address)
            # instanceMan.server.kick(msg.conn)
            echo "Connection OK"
    return true

proc listen(instanceMan: InstanceMan) {.gcsafe.} =

    for connection in instanceMan.server.newConnections:
        instanceMan.connectionsToVerify.incl(connection.address)

    for msg in instanceMan.server.messages:
        if not instanceMan.authenticate(msg): continue

proc checkServersToDeref(instanceMan: InstanceMan) {.gcsafe.} =
    let tried = chan.tryRecv()
    if tried.dataAvailable:
        instanceMan.deleteInstance(tried.msg)

proc bootInstanceManager*() {.thread.} =
    var instanceMan = InstanceMan()
    for i in 0..<256:
        instanceMan.freePorts.add(Port(51731 + i))

    instanceMan.server = newReactor("127.0.0.1", 51730)
    echo "Instance Manager Booted!"

    while true:
        instanceMan.server.tick()
        instanceMan.listen()