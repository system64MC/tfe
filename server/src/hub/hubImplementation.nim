import hub
import common/[vectors, constants, commonActors, serializedObjects, message, serializedObjects]
import ../actors/actors
import ../actors/implementations/player
import netty
import std/options
import ../gameInfos
import ../database/orm/models
import ../ipComp


proc update*(hub: Hub) =
    return

proc assignCharacter*(hub: Hub, player: Player, character: int) =
    player.character = character.int8
    return

proc selectCharacter*(hub: Hub, player: Player) =
    var isAvaillable = true
    for p in hub.playerList:
        if(p == nil): continue
        if(player.name == p.name): continue
        if(player.character == p.character and p.state == CHAR_SELECTED):
            isAvaillable = false
            break

    if(isAvaillable): player.state = CHAR_SELECTED

proc onDisconnect*(hub: Hub, address: Address, infos: var GameInfos, list: var array[4, PlayerORM]) =
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
proc serialize*(hub: Hub, code: string): string =
    var h = HubSerialize(
        playerList: hub.serializePlayers(),
        code: code
    )
    return toFlatty(h)