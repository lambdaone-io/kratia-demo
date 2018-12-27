module Page.Ballots exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http

import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Grid.Col as Col
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input

import Api exposing (Cred, Session, register)



-- MODEL


type alias Model =
    {  session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session = 
    (
        { session = session
        }
        , Cmd.none
    )



-- UPDATE


type Msg 
    = Clicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Clicked ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    section [] 
        [ div []
            [ h1 [] [ text "Ballots" ] ]
        ]
