import ../actors/actors

type
  Hub* = ref object
    playerList*: array[4, actors.Player]