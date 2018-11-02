module Main exposing (..)

import Commands exposing (fetchInitialData)
import Models exposing (Flags, Model, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Update exposing (update)
import MainView exposing (mainView)
import Debug
import Routing

init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
        ( initialModel  (Routing.parseLocation location) location.origin flags
        , fetchInitialData flags  )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MAIN

main : Program Flags Model Msg
main =
    Navigation.programWithFlags Msgs.OnLocationChange
        { init = init
        , view = mainView
        , update = update
        , subscriptions = subscriptions
        }
