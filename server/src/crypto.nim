import libsodium/sodium

var publicKey = ""
var privateKey = ""

proc generateKeys*() =
    let (pubk, privk) = cryptobox_keypair()
    publicKey = pubk
    privateKey = privk

proc getPublicKey*(): string =
    {.cast(gcsafe).}:
        return publicKey

proc getPrivateKey*(): string =
    {.cast(gcsafe).}:
        return privateKey

proc decrypt*(encrypted: string): string =
    {.cast(gcsafe).}:
        let str = cryptobox_seal_open(encrypted, publicKey, privateKey)
        echo str
        return str