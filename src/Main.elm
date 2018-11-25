module Main exposing (main)

import Browser
import Http
import Html exposing (Html, pre, text)
import Page.Register as Register



-- MAIN


main = 
    Browser.element 
        { init = init
        , update = update
        , subscriptions = subscriptions     
        , view = view
        }



-- MODEL


type Model 
    = Register Register.Model


init : () -> ( Model, Cmd Msg )
init _ = 
    case Register.init of 
        ( model, cmd ) -> 
            ( Register model, Cmd.map GotRegisterMsg cmd )



-- UPDATE


type Msg 
    = GotRegisterMsg Register.Msg



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case ( msg, model ) of
        ( GotRegisterMsg subMsg, Register register ) ->
            Register.update subMsg register
                |> updateWith Register GotRegisterMsg model


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none



-- VIEW

view : Model -> Html Msg
view model =
    case model of 
        Register register ->
            Html.map GotRegisterMsg <| Register.view register
