module Api exposing (..)

{-| This module is responsible for communicating to the Kratia API. -}


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



-- Endpoints


rootCommunity : String
rootCommunity = "19ce7b9b-a4da-4f9c-9838-c04fcb0ce9db"


url : String -> List String -> List QueryParameter -> String
url hostname paths queryParams =
  Url.Builder.crossOrigin hostname
      ("api" :: "v1" :: paths)
      queryParams


register : String -> String -> (Result Http.Error Cred -> msg) -> Cmd msg
register hostname nickname msg =
    Http.post 
      { url = url hostname ["registry"] []
      , body = Http.jsonBody <| Encode.object 
        [ ( "community", Encode.string rootCommunity )
        , ( "data", Encode.string nickname )
        ]
      , expect = Http.expectJson (\result -> msg <| Result.map (Cred nickname) result ) (field "member" string)
      }
