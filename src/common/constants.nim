const    
    SCREEN_X* = 256
    SCREEN_Y* = 144

    # ROOM_CHUNK_WIDTH* = (SCREEN_X / 16) + 4
    # ROOM_CHUNK_HEIGHT* = SCREEN_X / 16
    
    FPS* = 60.0
    TPS* = 60.0
    FPS_DELAY* = (1000.0 / FPS.float)
    TPS_DELAY* = (1000.0 / TPS.float)
    MINIMAL_LATENCY* = (1.0 / TPS.float)
    MAX_LATENCY* = (1.0 / (TPS.float / 5))