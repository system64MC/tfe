type
    UserORM* = object
        pseudo*: string
        # Some security is always good.
        password*: string