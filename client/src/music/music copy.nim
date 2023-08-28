import Ksnd
import strutils

var player: ptr structkplayert = nil
var song: ptr structksongt = nil
var info: ptr Ksonginfo


proc initMusic*(freq: uint): void =
    player = Ksndcreateplayer(freq.cint)
    #echo "player is nil"

proc startMusic*(path: string): void =
    var path2 = path.cstring
    var song2 = KSND_LoadSong(player, path2)
    if(song2 == nil):
          echo("Error while loading song! Please check the path to the file")
          return

    if not(song == nil):
      Ksndstop(player)
      Ksndfreesong(song)
      #Ksndfreeplayer(player)
      #initMusic(44100)
    song = song2

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