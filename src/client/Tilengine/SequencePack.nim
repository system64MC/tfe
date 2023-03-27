import Types, TilengineBinding

# SEQUENCEPACK
proc createSequencePack*(): TLN_SequencePack =
    return TLN_CreateSequencePack()

proc loadSequencePack*(file: string): TLN_SequencePack =
    return TLN_LoadSequencePack(file.cstring)

proc getSequence*(sp: TLN_SequencePack, index: int): TLN_Sequence =
    return TLN_GetSequence(sp, index.cint)

proc findSequence*(sp: TLN_SequencePack, name: string): TLN_Sequence =
    return TLN_FindSequence(sp, name.cstring)

proc getSequencePackCount*(sp: TLN_SequencePack): int =
    return TLN_GetSequencePackCount(sp).int

proc addSequenceToPack*(sp: TLN_SequencePack, sequence: TLN_Sequence): bool =
    return TLN_AddSequenceToPack(sp, sequence)

proc deleteSequencePack*(sp: TLN_SequencePack): bool =
    return TLN_DeleteSequencePack(sp)