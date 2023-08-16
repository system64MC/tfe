import database/orm/models
import flatty
import netty

type
    Hub = ref object
        game: GameORM
        server: Reactor

import random
proc randomStr(): string =
  for _ in 0..<8:
    add(result, char(rand(int('a')..int('z'))))

proc hasFreeSlots(hub: Hub): bool =
    for p in hub.game.players:
        if(p == nil): return true
    return false

proc update(hub: Hub): void =
    echo "a"
    # On player connection, if no more space,
    # send message and close the connection. 
    if not hub.hasFreeSlots():
        echo "We should kick the player."

proc init(hub: Hub): void =
    while not hub.game.hasStarted:
        hub.update()

proc createHub(user: UserORM): void =
    var hub = Hub()
    # We create a new hub with a random ID.
    hub.game = newGame(user, randomStr())
    # Create server here...
    # init the hub. Might be nice to init it in a thread.
    hub.init()


