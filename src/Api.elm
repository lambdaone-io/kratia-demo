module Api exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, value, src, width)
import Html.Events exposing (onClick)
import Http exposing (..)
import List exposing (filter, head)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional)
import Shared exposing (Msg(..))
import Json.Decode as Decode exposing (Decoder, Value, field, string)
import Json.Encode as Encode


type alias RegistrationRequest =
    { community: String
    , data: String
    }

type alias RegistrationResponse =
    {  member: String
    }


-- DECODERS

registrationResponseDecoder : Decode.Decoder RegistrationResponse
registrationResponseDecoder =
    Decode.succeed RegistrationResponse
        |> required "member" Decode.string

-- Operations


rootCommunity : String
rootCommunity = "19ce7b9b-a4da-4f9c-9838-c04fcb0ce9db"


register : String -> String  -> Cmd Msg
register server nickname =
 Http.post (server ++ "/api/v1/registry")
   (Http.jsonBody <| Encode.object
     [ ( "community", Encode.string rootCommunity )
     , ( "data", Encode.string nickname )
     ]) registrationResponseDecoder
     |> Http.send (\resp -> Registered (case resp of
                                         Err e -> Err e
                                         Ok r -> Ok r.member
                                         ) nickname)

-- Help, this ^^^ should be a simple Result.map
