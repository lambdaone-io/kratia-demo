module Config exposing (Flags, Config, fromFlags)

import Api exposing (Service(..))



-- CONFIG


type alias Flags =
    { services : 
        { kratia : 
            { hostname : String
            , prefix : List String
            }
        }
    }


type alias Config =
    { kratia : Service }


fromFlags : Flags -> Config
fromFlags flags = 
    { kratia = Service flags.services.kratia.hostname flags.services.kratia.prefix }
