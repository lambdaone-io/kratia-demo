module Page.Ballots exposing (Model, Msg, init, update, view, toSession, updateSession)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http
import Time exposing (Posix, Zone, utc)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input

import DateFormat as DateFormat

import Api as Api exposing (Session)
import Kratia.Ballot exposing (Ballot)



-- MODEL


type alias Model =
    { session : Session
    , ballots : List Ballot
    }


init : Session -> ( Model, Cmd Msg )
init session = 
    (
        { session = session
        , ballots = []
        }
        , Api.listBallots 
            { session = session
            , onResponse = GotBallots
            }
    )



-- UPDATE


type Msg 
    = GotBallots ( Result Http.Error ( List Ballot ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        GotBallots ( Ok ballots ) ->
            ( { model | ballots = ballots }, Cmd.none )
        
        GotBallots ( Err _ ) ->
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
            , Grid.row []
                [ Grid.col []
                    [ div [ class "ballots" ] ( List.map renderBallot model.ballots ) ] 
                ]
            ]
    }


renderBallot : Ballot -> Html Msg
renderBallot ballot = 
    Card.config [ Card.attrs [ class "ballot" ] ]
        |> Card.headerH3 [] [ text ballot.data ]
        |> Card.block []
            [ Block.titleH3 [] [ text <| ballotCardFormatter utc ballot.closesOn ]
            , Block.text [] [ text "Vote now" ]
            ]
        |> Card.view



-- DATE


ballotCardFormatter : Zone -> Posix -> String
ballotCardFormatter =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.hourMilitaryFixed
        , DateFormat.text ":00 hrs."
        ]



-- EXPORT


toSession : Model -> Session
toSession model = 
    model.session


updateSession : (Session -> Session) -> Model -> Model
updateSession updt model =
    { model | session = updt model.session }
