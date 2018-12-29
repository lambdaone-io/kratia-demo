module Page.Ballots exposing (Model, Msg, init, update, view, toSession, updateSession)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http
import Time exposing (Posix, Zone, utc, millisToPosix)

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
    , createBallotInput : String
    , loadingCreateBallot : Bool
    }


init : Session -> ( Model, Cmd Msg )
init session = 
    (
        { session = session
        , ballots = []
        , createBallotInput = ""
        , loadingCreateBallot = False
        }
        , Api.listBallots 
            { session = session
            , onResponse = GotBallots
            }
    )



-- UPDATE


type Msg 
    = GotBallots ( Result Http.Error ( List Ballot ))
    | CreateBallotInput String
    | CreateBallotSubmitted
    | CreateBallotResponded ( Result Http.Error Ballot )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        GotBallots ( Ok ballots ) ->
            ( { model | ballots = ballots }, Cmd.none )
        
        GotBallots ( Err e ) ->
            ( { model | createBallotInput = Api.errorMessage e } , Cmd.none )

        CreateBallotInput input ->
            ( { model | createBallotInput = input }, Cmd.none )

        CreateBallotSubmitted ->
            ( { model | loadingCreateBallot = True } , Api.createBallot 
                { session = model.session
                , data = model.createBallotInput
                , closesOn = millisToPosix 1543190400000
                , onResponse = CreateBallotResponded
                } 
            )
        
        CreateBallotResponded ( Ok ballot ) ->
            ( { model | 
                loadingCreateBallot = False,
                createBallotInput = "", 
                ballots = ballot :: model.ballots
            }, Cmd.none )
        
        CreateBallotResponded ( Err e ) ->
            ( { model | loadingCreateBallot = False, createBallotInput = Api.errorMessage e }, Cmd.none )



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
                    [ div [ class "ballots" ] <|
                        ( createBallot model ) :: ( List.map renderBallot model.ballots ) 
                    ] 
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


createBallot : Model -> Html Msg
createBallot model =
    Card.config [ Card.attrs [ class "ballot" ] ]
        |> Card.headerH3 [] [ text "Create ballot" ]
        |> Card.block []
            [ Block.text [] [ text "Write down the issue that requires a decision" ]
            , Block.custom <| createBallotForm model
            ]
        |> Card.view


createBallotForm : Model -> Html Msg
createBallotForm model =
    Form.formInline
        [ onSubmit CreateBallotSubmitted ]
        [ Input.text [ Input.attrs
            [ placeholder "Issue at hand"
            , disabled model.loadingCreateBallot
            , value model.createBallotInput
            , onInput CreateBallotInput
            ] ]
        , Button.button
            [ Button.primary
            , Button.attrs 
                [ class "ml-sm-2 my-2"
                , disabled (String.isEmpty model.createBallotInput)
                ]
            ]
            [ text "Submit" ]
        ]



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
