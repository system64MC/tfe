import Types, TilengineBinding

# OBJECTS
proc createObjectList*(): TLN_ObjectList =
    return TLN_CreateObjectList()

proc addTileObjectToList*(list: TLN_ObjectList, id: uint16, gid: uint16, flags: uint16, x: int, y: int): bool =
    return TLN_AddTileObjectToList(list, id, gid, flags, x.cint, y.cint)

proc loadObjectList*(file: string, layerName: string): TLN_ObjectList =
    return TLN_LoadObjectList(file.cstring, layerName.cstring)

proc cloneObjectList*(src: TLN_Objectlist): TLN_Objectlist =
    return TLN_CloneObjectList(src)

proc getListNumObjects*(list: TLN_ObjectList): int =
    return TLN_GetListNumObjects(list).cint

proc getListObject*(list: TLN_ObjectList, info: ptr TLN_ObjectInfo): bool =
    return TLN_GetListObject(list, info)

proc deleteObjectList*(list: TLN_ObjectList): bool =
    TLN_DeleteObjectList(list)