import ../room/room
import netty
import common/[credentials]
import std/[times, os, tables, httpclient, asyncdispatch, strformat]

type
    GameState* = enum
        TITLE_SCREEN,
        MUSIC_ROOM,
        HUB,
        GAME_LEVEL

    Game* = ref object
        state*: GameState
        room*: Room
        client*: Reactor
        # httpClient*: AsyncHttpClient
        connection*: Connection
        frame*: int
        credentials*: CredentialsEncrypted




var frame* = 0