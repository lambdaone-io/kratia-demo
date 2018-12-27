module Page.Ballots exposing (Model, Msg, init, update, view, toSession, updateSession)

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


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Kratia | Ballots"
    , content = 
        Grid.container []
            [ Grid.row [] 
                [ Grid.col [] 
                    [ h1 [] [ text "Ballots" ] ] 
                ]
            ]
    }



-- EXPORT


toSession : Model -> Session
toSession model = 
    model.session


updateSession : (Session -> Session) -> Model -> Model
updateSession updt model =
    { model | session = updt model.session }
