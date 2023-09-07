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
                let e = Ennemy(
                    position: VectorF64(
                        x: item.attr("x").parseFloat().floor(),
                        y: item.attr("y").parseFloat().floor()
                    ),
                    hitbox: Hitbox(
                        size: VectorU8(x: 15, y: 15)
                    ),
                    ennemyType: item.attr("class").parseInt()
                )
                room.enemyList[enemyIndex] = e
                enemyIndex.inc
        else:
              continue