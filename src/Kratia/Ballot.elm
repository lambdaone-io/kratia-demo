module Kratia.Ballot exposing (Ballot, decoder)


import Time exposing (Posix, millisToPosix)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)



-- TYPES


type alias Ballot =
    { ballotBox : String
    , ballot : List String
    , closesOn : Posix
    , data : String
    }


decoder : Decoder Ballot
decoder =
    Decode.succeed Ballot
        |> required "ballotBox" Decode.string
        |> required "ballot" ( Decode.list ( Decode.string ))
        |> required "closesOn" ( Decode.map millisToPosix Decode.int )
        |> required "data" Decode.string