import Ksnd
import strutils

var player: ptr structkplayert = nil
var song: ptr structksongt = nil
var info: ptr Ksonginfo
var meters* = newSeq[int32](256)


proc initMusic*(freq: uint): void =
    player = Ksndcreateplayer(freq.cint)
    #echo "player is nil"

proc startMusic*(path: string): void =
    var path2 = path.cstring
    if (song != nil):
      Ksndstop(player)
      Ksndfreesong(song)
      # TODO : This is a temporary fix to avoid a segfault. I hope
      # I would be able to fix it in the future.
      Ksndfreeplayer(player)
      player = Ksndcreateplayer(44100)
      song = nil
    song = KSND_LoadSong(player, path2)
    echo "passed here..."
    if(song == nil):
          echo("Error while loading song! Please check the path to the file")
          return

      #Ksndfreeplayer(player)
      #initMusic(44100)

    #echo "song is nil"
    KSND_PlaySong(player, song, 0)

proc pauseSong*(): void =
  Ksndpause(player, 1)

proc restartSong*(): void =
  if(song == nil):
    echo "No song loaded. Load a song first!"
    return
  Ksndplaysong(player, song, 0)

proc resumeSong*(): void =
  Ksndpause(player, 0)

proc setOversample*(oversample: int): void =
  Ksndsetplayerquality(player, oversample.cint)
  echo "Oversample set to " & $oversample

proc setVolume*(volume: int): void =
  Ksndsetvolume(player, volume.cint)
  echo "Volume set to " & $volume

proc getCurSongInfo*(): string =
  info = Ksndgetsonginfo(song, info)
  #echo info[].nchannels.toHex
  #return info[].songTitle
  var infoStr = ""
  infoStr = "Title : " & $info.songtitle & '\n'
  infoStr = infoStr & "Num. of channels : " & $info[].nchannels & '\n'
  infoStr = infoStr & "Num. of instruments : " & $info[].ninstruments & '\n'  & "Instruments : " & '\n'
  for i in 0..(info[].ninstruments - 1):
  #  if not($info.instrumentname[i] == "\0"):
    infoStr = infoStr & '\t' & $info[].instrumentname[i] & '\n'
  #echo info.nchannels
  return infoStr

proc getNumChannels*(): int32 =
  if(song == nil): return 0
  info = Ksndgetsonginfo(song, info)
  return info[].nchannels

proc getSongPosition*(): int =
  if(song == nil or player == nil): return 0
  return Ksndgetplayposition(player)

proc getSongLength*(): int =
  if(song == nil): return 0
  return Ksndgetsonglength(song)

proc getMeters*() =
  if(song == nil or player == nil): return
  Ksndgetvumeters(player, meters[0].addr, getNumChannels())