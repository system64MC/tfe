import netty

proc `==`*(a, b: Port): bool {.borrow.}
proc `==`*(address1, address2: Address): bool =
    return ((address1.host == address2.host) and (address1.port == address2.port))