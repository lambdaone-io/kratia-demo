module Update exposing (..)

import Commands exposing (..)
import Models exposing (Model)
import Msgs exposing (Msg)
import Navigation exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchManga response -> ( { model | manga = response }, Cmd.none )
        Msgs.OnLocationChange _ -> (model, Cmd.none)
