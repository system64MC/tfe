import netty
import gameInstance
import std/[tables, options, lists, sets]
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

proc `==`(a, b: Port): bool {.borrow.}

import random
proc randomStr(): string =
  for _ in 0..<8:
    add(result, char(rand(int('a')..int('z'))))

proc getPortByCode(instanceMan: InstanceMan, code: string): Option[Port] =
    let instance = instanceMan.instanceList[code]
    if(instance == nil): return none(Port)
    return some(instance.server.address.port)

proc createInstance(instanceMan: InstanceMan, master: UserORM): Option[Port] =
    let str = randomStr()
    var port = instanceMan.freePorts.head.value
    instanceMan.instanceList[str] = newGameInstance(port, master, str)
    # instanceMan.freePorts.remove(instanceMan.freePorts.head)
    discard instanceMan.freePorts.remove(instanceMan.freePorts.head)

    return some(port)

proc kick(server: Reactor, connection: Connection) =
    server.disconnect(connection)

proc authenticate(instanceMan: InstanceMan, msg: netty.Message): bool =
    if msg.data == "": return false
    let mess = fromFlatty(msg.data, message.Message)
    if(instanceMan.connectionsToVerify.contains(msg.conn.address)):
        echo "Checking connection"
        echo "header : ", mess.header
        if(mess.header != ENCRYPTED_CREDENTIALS_DATA):
            instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
            instanceMan.connectionsToVerify.excl(msg.conn.address)
            instanceMan.server.kick(msg.conn)
            echo "Connection not OK 1"
            return false
        else:
            let credentials = fromFlatty(mess.data, CredentialsEncrypted)
            let user = getUserByNameAndPassword($(credentials.name.cstring), $(decrypt(credentials.password).cstring))

            if user.isNone:
                instanceMan.server.send(msg.conn, toFlatty(message.Message(header: ERROR_AUTH, data: "")))
                instanceMan.connectionsToVerify.excl(msg.conn.address)
                instanceMan.server.kick(msg.conn)
                echo "Connection not OK 2"
                return false
    echo "Connection OK"
    instanceMan.connectionsToVerify.excl(msg.conn.address)
    return true

proc listen(instanceMan: InstanceMan) =

    for connection in instanceMan.server.newConnections:
        instanceMan.connectionsToVerify.incl(connection.address)

    for msg in instanceMan.server.messages:
        if not instanceMan.authenticate(msg): continue

proc bootInstanceManager*() {.thread.} =
    var instanceMan = InstanceMan()
    for i in 0..<256:
        instanceMan.freePorts.add(Port(51731 + i))

    instanceMan.server = newReactor("127.0.0.1", 51730)
    echo "Instance Manager Booted!"

    while true:
        instanceMan.server.tick()
        instanceMan.listen()