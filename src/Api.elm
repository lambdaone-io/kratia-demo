module Api exposing (Cred, Flags, Session, guest, withCreds, withNavState, username, register)

{-| This module is responsible for communicating to the Kratia API. -}

import Browser.Navigation as Nav
import Bootstrap.Navbar as Navbar

import Url.Builder exposing (QueryParameter)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, field, string)
import Json.Encode as Encode


-- CRED


type alias Token = String

{-| The authentication credentials for the Viewer (that is, the currently logged-in user.)
This includes:
  - The cred's Username
  - The cred's authentication token
By design, there is no way to access the token directly as a String.
It can be encoded for persistence, and it can be added to a header
to a HttpBuilder for a request, but that's it.
This token should never be rendered to the end user, and with this API, it
can't be!
-}
type Cred = Cred String Token


username : Cred -> String 
username (Cred name _) = name


credHeader : Cred -> Http.Header
credHeader (Cred _ token) = 
    Http.header "Authorization" ("Bearer " ++ token)



-- SESSION


type alias Session = 
    { credentials : Maybe Cred
    , navKey : Nav.Key
    , navState : Navbar.State
    , config : Config
    }


type alias Config =
    { kratia : Service }


type alias Flags =
    { services : 
        { kratia : 
            { hostname : String
            , prefix : List String
            }
        }
    }


guest : Flags -> Nav.Key -> Navbar.State -> Session
guest flags key state =
    { credentials = Nothing
    , navKey = key
    , navState = state 
    , config = 
      { kratia = Service flags.services.kratia.hostname flags.services.kratia.prefix }
    }


withCreds : Cred -> Session -> Session
withCreds cred session =
    { session | credentials = Just cred }


withNavState : Navbar.State -> Session -> Session
withNavState state session =
    { session | navState = state }



-- SERVICE


type alias Hostname = String


type alias PathSection = String


type Service = Service Hostname (List PathSection)


rootCommunity : String
rootCommunity = "19ce7b9b-a4da-4f9c-9838-c04fcb0ce9db"


url : Service -> List PathSection -> List QueryParameter -> String
url (Service hostname prefix) paths queryParams =
  Url.Builder.crossOrigin hostname
      (prefix ++ paths)
      queryParams



-- ENDPOINTS 


register : { session : Session, nickname : String, onResponse : (Result Http.Error Cred -> msg) } -> Cmd msg
register { session, nickname, onResponse } =
    Http.post 
      { url = url session.config.kratia ["registry"] []
      , body = Http.jsonBody <| Encode.object 
        [ ( "community", Encode.string rootCommunity )
        , ( "data", Encode.string nickname )
        ]
      , expect = Http.expectJson (\result -> onResponse <| Result.map (Cred nickname) result ) (field "member" string)
      }
