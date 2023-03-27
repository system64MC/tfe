import Types, TilengineBinding

# SEQUENCE
proc createSequence*(name: string, target: int, numFrames: int, frames: ptr TLN_SequenceFrame): TLN_Sequence =
    return TLN_CreateSequence(name.cstring, target.cint, numFrames.cint, frames)

proc createCycle*(name: string, numStrips: int, strips: ptr TLN_ColorStrip): TLN_Sequence =
    return TLN_CreateCycle(name.cstring, numStrips.cint, strips)

proc createSpriteSequence*(name: string, spriteset: TLN_Spriteset, basename: string, delay: int): TLN_Sequence =
    return TLN_CreateSpriteSequence(name.cstring, spriteset, basename.cstring, delay.cint)

proc cloneSequence*(src: TLN_Sequence): TLN_Sequence =
    return TLN_CloneSequence(src)

proc getSequenceInfo*(sequence: TLN_Sequence, info: ptr TLN_SequenceInfo): bool =
    return TLN_GetSequenceInfo(sequence, info)

proc deleteSequence*(sequence: TLN_Sequence): bool =
    return TLN_DeleteSequence(sequence)