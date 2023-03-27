import Types, TilengineBinding

# BITMAP
proc createBitmap*(w: int, h: int, bpp: int): TLN_Bitmap =
    return TLN_CreateBitmap(w.cint, h.cint, bpp.cint)

proc loadBitmap*(file: string): TLN_Bitmap =
    return TLN_LoadBitmap(file.cstring)

proc cloneBitmap*(src: TLN_Bitmap): TLN_Bitmap = 
    return TLN_CloneBitmap(src)

proc getBitmapPtr*(bitmap: TLN_Bitmap, x: int, y: int): ptr uint8 =
    return TLN_GetBitmapPtr(bitmap, x.cint, y.cint)

proc getBitmapWidth*(bitmap: TLN_Bitmap): int =
    return TLN_GetBitmapWidth(bitmap).int

proc getBitmapHeight*(bitmap: TLN_Bitmap): int =
    return TLN_GetBitmapHeight(bitmap).int

proc getBitmapDepth*(bitmap: TLN_Bitmap): int =
    return TLN_GetBitmapDepth(bitmap).int

proc getBitmapPitch*(bitmap: TLN_Bitmap): int =
    return TLN_GetBitmapPitch(bitmap).int

proc getBitmapPalette*(bitmap: TLN_Bitmap): TLN_Palette =
    return TLN_GetBitmapPalette(bitmap)

proc setBitmapPalette*(bitmap: TLN_Bitmap, palette: TLN_Palette): bool =
    return TLN_SetBitmapPalette(bitmap, palette)

proc deleteBitmap*(bitmap: TLN_Bitmap): bool = 
    return TLN_DeleteBitmap(bitmap)