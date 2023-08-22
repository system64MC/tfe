
from macros import hint

when not declared(structksongt):
  type
    structksongt* = distinct object
else:
  static :
    hint("Declaration of " & "struct_KSong_t" &
        " already exists, not redeclaring")
when not declared(structkplayert):
  type
    structkplayert* = distinct object
else:
  static :
    hint("Declaration of " & "struct_KPlayer_t" &
        " already exists, not redeclaring")
type
  Kplayer_436207892* = structkplayert ## Generated based on C:/Users/nicol/Documents/programmation/NimKlystron/include\ksnd.h:26:26
  Ksonginfo_436207895* = object
    songtitle*: cstring      ## Generated based on C:/Users/nicol/Documents/programmation/NimKlystron/include\ksnd.h:31:9
    instrumentname*: array[255'i64, cstring]
    ninstruments*: cint
    nchannels*: cint

  Ksong_436207897* = structksongt ## Generated based on C:/Users/nicol/Documents/programmation/NimKlystron/include\ksnd.h:19:24
  Ksonginfo_436207896* = (when declared(Ksonginfo):
    Ksonginfo
   else:
    Ksonginfo_436207895)
  Kplayer_436207894* = (when declared(Kplayer):
    Kplayer
   else:
    Kplayer_436207892)
  Ksong_436207898* = (when declared(Ksong):
    Ksong
   else:
    Ksong_436207897)
when not declared(Ksonginfo):
  type
    Ksonginfo* = Ksonginfo_436207895
else:
  static :
    hint("Declaration of " & "KSongInfo" & " already exists, not redeclaring")
when not declared(Kplayer):
  type
    Kplayer* = Kplayer_436207892
else:
  static :
    hint("Declaration of " & "KPlayer" & " already exists, not redeclaring")
when not declared(Ksong):
  type
    Ksong* = Ksong_436207897
else:
  static :
    hint("Declaration of " & "KSong" & " already exists, not redeclaring")
when not declared(Ksndsetvolume):
  proc Ksndsetvolume*(player: ptr Kplayer_436207894; volume: cint): void {.
      cdecl, importc: "KSND_SetVolume".}
else:
  static :
    hint("Declaration of " & "KSND_SetVolume" &
        " already exists, not redeclaring")
when not declared(Ksndpause):
  proc Ksndpause*(player: ptr Kplayer_436207894; state: cint): void {.cdecl,
      importc: "KSND_Pause".}
else:
  static :
    hint("Declaration of " & "KSND_Pause" & " already exists, not redeclaring")
when not declared(Ksndgetvumeters):
  proc Ksndgetvumeters*(player: ptr Kplayer_436207894; envelope: ptr cint;
                        nchannels: cint): void {.cdecl,
      importc: "KSND_GetVUMeters".}
else:
  static :
    hint("Declaration of " & "KSND_GetVUMeters" &
        " already exists, not redeclaring")
when not declared(Ksndfillbuffer):
  proc Ksndfillbuffer*(player: ptr Kplayer_436207894; buffer: ptr cshort;
                       bufferlength: cint): cint {.cdecl,
      importc: "KSND_FillBuffer".}
else:
  static :
    hint("Declaration of " & "KSND_FillBuffer" &
        " already exists, not redeclaring")
when not declared(Ksndgetsonglength):
  proc Ksndgetsonglength*(song: ptr Ksong_436207898): cint {.cdecl,
      importc: "KSND_GetSongLength".}
else:
  static :
    hint("Declaration of " & "KSND_GetSongLength" &
        " already exists, not redeclaring")
when not declared(Ksndplaysong):
  proc Ksndplaysong*(player: ptr Kplayer_436207894; song: ptr Ksong_436207898;
                     startposition: cint): void {.cdecl,
      importc: "KSND_PlaySong".}
else:
  static :
    hint("Declaration of " & "KSND_PlaySong" &
        " already exists, not redeclaring")
when not declared(Ksndgetplaytime):
  proc Ksndgetplaytime*(song: ptr Ksong_436207898; position: cint): cint {.
      cdecl, importc: "KSND_GetPlayTime".}
else:
  static :
    hint("Declaration of " & "KSND_GetPlayTime" &
        " already exists, not redeclaring")
when not declared(Ksndgetsonginfo):
  proc Ksndgetsonginfo*(song: ptr Ksong_436207898; data: ptr Ksonginfo_436207896): ptr Ksonginfo_436207896 {.
      cdecl, importc: "KSND_GetSongInfo".}
else:
  static :
    hint("Declaration of " & "KSND_GetSongInfo" &
        " already exists, not redeclaring")
when not declared(Ksndfreeplayer):
  proc Ksndfreeplayer*(player: ptr Kplayer_436207894): void {.cdecl,
      importc: "KSND_FreePlayer".}
else:
  static :
    hint("Declaration of " & "KSND_FreePlayer" &
        " already exists, not redeclaring")
when not declared(Ksndfreesong):
  proc Ksndfreesong*(song: ptr Ksong_436207898): void {.cdecl,
      importc: "KSND_FreeSong".}
else:
  static :
    hint("Declaration of " & "KSND_FreeSong" &
        " already exists, not redeclaring")
when not declared(Ksndcreateplayer):
  proc Ksndcreateplayer*(samplerate: cint): ptr Kplayer_436207894 {.cdecl,
      importc: "KSND_CreatePlayer".}
else:
  static :
    hint("Declaration of " & "KSND_CreatePlayer" &
        " already exists, not redeclaring")
when not declared(Ksndgetplayposition):
  proc Ksndgetplayposition*(player: ptr Kplayer_436207894): cint {.cdecl,
      importc: "KSND_GetPlayPosition".}
else:
  static :
    hint("Declaration of " & "KSND_GetPlayPosition" &
        " already exists, not redeclaring")
when not declared(Ksndloadsongfrommemory):
  proc Ksndloadsongfrommemory*(player: ptr Kplayer_436207894; data: pointer;
                               datasize: cint): ptr Ksong_436207898 {.cdecl,
      importc: "KSND_LoadSongFromMemory".}
else:
  static :
    hint("Declaration of " & "KSND_LoadSongFromMemory" &
        " already exists, not redeclaring")
when not declared(Ksndsetlooping):
  proc Ksndsetlooping*(player: ptr Kplayer_436207894; looping: cint): void {.
      cdecl, importc: "KSND_SetLooping".}
else:
  static :
    hint("Declaration of " & "KSND_SetLooping" &
        " already exists, not redeclaring")
when not declared(Ksndstop):
  proc Ksndstop*(player: ptr Kplayer_436207894): void {.cdecl,
      importc: "KSND_Stop".}
else:
  static :
    hint("Declaration of " & "KSND_Stop" & " already exists, not redeclaring")
when not declared(Ksndloadsong):
  proc Ksndloadsong*(player: ptr Kplayer_436207894; path: cstring): ptr Ksong_436207898 {.
      cdecl, importc: "KSND_LoadSong".}
else:
  static :
    hint("Declaration of " & "KSND_LoadSong" &
        " already exists, not redeclaring")
when not declared(Ksndsetplayerquality):
  proc Ksndsetplayerquality*(player: ptr Kplayer_436207894; oversample: cint): void {.
      cdecl, importc: "KSND_SetPlayerQuality".}
else:
  static :
    hint("Declaration of " & "KSND_SetPlayerQuality" &
        " already exists, not redeclaring")
when not declared(Ksndcreateplayerunregistered):
  proc Ksndcreateplayerunregistered*(samplerate: cint): ptr Kplayer_436207894 {.
      cdecl, importc: "KSND_CreatePlayerUnregistered".}
else:
  static :
    hint("Declaration of " & "KSND_CreatePlayerUnregistered" &
        " already exists, not redeclaring")