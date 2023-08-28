import hub
import common/[vectors, constants, commonActors, serializedObjects, message, serializedObjects]
import ../actors/actors
import ../actors/implementations/player
import netty
import std/options
import ../gameInfos

proc `==`*(a, b: Port): bool {.borrow.}
proc `==`*(address1, address2: Address): bool =
    return ((address1.host == address2.host) and (address1.port == address2.port))

proc update*(hub: Hub) =
    return

proc assignCharacter*(hub: Hub, player: Player, character: int) =
    player.character = character.int8
    return

proc selectCharacter*(hub: Hub, player: Player) =
    var isAvaillable = true
    for p in hub.playerList:
        if(player.character == p.character and p.state == CHAR_SELECTED):
            isAvaillable = false
            break

    if(isAvaillable): player.state = CHAR_SELECTED

proc onDisconnect*(hub: Hub, address: Address, infos: var GameInfos) =
    if infos.master.address.get == address:
        infos.state = DEAD_GAME

    for i in 0..<hub.playerList.len:
        var p = hub.playerList[i]
        if p == nil: continue
        if p.address.isNone: continue
        if address == p.address.get():
            hub.playerList[i] = nil
            break

proc serializePlayers(hub: Hub): array[4, PlayerSerialize] =
    var arr: array[4, PlayerSerialize]
    for i in 0..<hub.playerList.len:
        let p = hub.playerList[i]
        if(p != nil):
            arr[i] = p.serialize()
    return arr

import flatty
proc serialize*(hub: Hub): string =
    var h = HubSerialize(
        playerList: hub.serializePlayers()
    )
    return toFlatty(h)