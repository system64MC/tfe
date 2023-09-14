import room
import std/[parsexml, xmlparser, streams, xmltree, strutils, os]
import common/[vectors, hitbox, commonActors]
import math

proc loadActors*(room: Room, path: string, layerName: string = "actors") =
    echo "LOADING ACTORS"

    var tree = loadXml(path)
    var
        enemyIndex = 0

    for elementName in tree:
        case elementName.tag:
        of "objectgroup":
            let t = elementName
            for item in t:
                let eType = item.attr("class").parseInt()
                let e = Enemy(
                    position: VectorF64(
                        x: item.attr("x").parseFloat().floor(),
                        y: item.attr("y").parseFloat().floor()
                    ),
                    hitbox: Hitbox(
                        size: (
                        case eType:
                        of 666: VectorU8(x: 32, y: 64)
                        of 667: VectorU8(x: 32, y: 64)
                        else: VectorU8(x: 15, y: 15)
                        )
                    ),
                    enemyType: eType,
                    lifePoints: (
                        case eType:
                        of 0: 3
                        of 1: 3
                        of 2: 3
                        of 666: 100
                        of 667: 200
                        else: 1
                        ),
                    totalLifePoints: (
                        case eType:
                        of 666: 100
                        of 667: 200
                        else: 1
                    )
                )
                if(eType < 666):
                    room.enemyList[enemyIndex] = e
                    enemyIndex.inc
                else:
                    room.boss = e
        else:
              continue