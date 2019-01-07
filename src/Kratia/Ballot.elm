module Kratia.Ballot exposing (Ballot, ClosedBallot, decoder, decoderClosed)


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


type alias ClosedBallot =
    { ballotBox : String
    , closedOn : Posix
    , data : String
    , resolution : List String
    }


decoder : Decoder Ballot
decoder =
    Decode.succeed Ballot
        |> required "ballotBox" Decode.string
        |> required "ballot" ( Decode.list ( Decode.string ) )
        |> required "closesOn" decodePosix
        |> required "data" Decode.string


decoderClosed : Decoder ClosedBallot
decoderClosed =
    Decode.succeed ClosedBallot
        |> required "address" Decode.string
        |> required "closedOn" decodePosix
        |> required "data" Decode.string
        |> required "resolution" ( Decode.list ( Decode.string ) )


decodePosix : Decoder Posix 
decodePosix =
    Decode.int
        |> Decode.map ( \x -> x * 1000 )
        |> Decode.map millisToPosix 
