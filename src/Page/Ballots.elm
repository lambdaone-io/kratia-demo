module Page.Ballots exposing (Model, Msg, init, update, subscriptions, view, toSession, updateSession)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http
import Task as Task
import Time as Time exposing (Posix, Zone)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio

import DateFormat as DateFormat

import Api as Api exposing (Session)
import Kratia.Ballot exposing (Ballot, ClosedBallot)



-- MODEL


type alias Model =
    { session : Session
    , ballots : List Ballots
    , closedBallots : List ClosedBallot
    , currentTime : Posix
    , createBallotInput : String
    , createBallotTimeInput : String
    , createBallotTimeSelection : TimeSelection
    , loadingCreateBallot : Bool
    }


type Ballots 
    = AlreadyVoted String Ballot
    | YetToVote Ballot


init : Session -> ( Model, Cmd Msg )
init session = 
    (
        { session = session
        , ballots = []
        , closedBallots = []
        , currentTime = Time.millisToPosix 0
        , createBallotInput = ""
        , createBallotTimeInput = ""
        , createBallotTimeSelection = Minutes
        , loadingCreateBallot = False
        }
        , Cmd.batch
            [ Task.perform GotTime Time.now
            , Api.listBallots 
                { session = session
                , onResponse = GotBallots
                }
            , Api.listClosedBallots 
                { session = session
                , onResponse = GotClosedBallots
                }
            ]
    )



-- UPDATE


type Msg 
    = GotBallots ( Result Http.Error ( List Ballot ) )
    | GotClosedBallots ( Result Http.Error ( List ClosedBallot ) )
    | GotTime Posix
    | CreateBallotInput String
    | CreateBallotTimeInput String
    | CreateBallotTimeSelection TimeSelection
    | CreateBallotSubmitted
    | CreateBallotResponded ( Result Http.Error Ballot )
    | Voted String Bool
    | VotedBinaryResponded ( Result Http.Error (String, String) )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        GotBallots ( Ok ballots ) ->
            ( { model | ballots = List.map YetToVote ballots }, Cmd.none )

        GotBallots ( Err e ) ->
            ( { model | createBallotInput = Api.errorMessage e } , Cmd.none )

        GotClosedBallots ( Ok ballots ) ->
            ( { model | closedBallots = ballots }, Cmd.none )

        GotClosedBallots ( Err e ) ->
            ( { model | createBallotInput = Api.errorMessage e } , Cmd.none )
        
        GotTime time ->
            ( { model | currentTime = time }, Cmd.none )

        CreateBallotInput input ->
            ( { model | createBallotInput = input }, Cmd.none )

        CreateBallotTimeInput input ->
            ( { model | createBallotTimeInput = input }, Cmd.none )

        CreateBallotTimeSelection timeSelection ->
            ( { model | createBallotTimeSelection = timeSelection }, Cmd.none )

        CreateBallotSubmitted ->
            ( { model | loadingCreateBallot = True } , Api.createBallot 
                { session = model.session
                , data = model.createBallotInput
                , closesOn = timeSelectionToMillis model.createBallotTimeInput model.createBallotTimeSelection
                , onResponse = CreateBallotResponded
                } 
            )
        
        CreateBallotResponded ( Ok ballot ) ->
            ( { model | 
                loadingCreateBallot = False,
                createBallotInput = "", 
                ballots = YetToVote ballot :: model.ballots
            }, Cmd.none )
        
        CreateBallotResponded ( Err e ) ->
            ( { model | loadingCreateBallot = False, createBallotInput = Api.errorMessage e }, Cmd.none )

        Voted box vote ->
            ( model, Api.voteBinary 
                { session = model.session
                , box = box
                , vote = vote
                , onResponse = VotedBinaryResponded
                } 
            )

        VotedBinaryResponded ( Err e ) -> 
            ( { model | loadingCreateBallot = False, createBallotInput = Api.errorMessage e }, Cmd.none )
        
        VotedBinaryResponded ( Ok ( resBallot, proof ) ) ->
            let 
                updateBallot ballot = 
                    case ballot of 
                        YetToVote ballot0 -> 
                            if ballot0.ballotBox == resBallot
                            then AlreadyVoted proof ballot0
                            else YetToVote ballot0
                        other -> 
                            other
                newBallots = 
                    List.map updateBallot model.ballots
            in
            ( { model | ballots = newBallots }, Cmd.none )


-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 GotTime



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
                        -- ( ( createBallot model ) :: ( ) )
                        ( List.map renderFutureBallot model.ballots ) ++ ( List.map renderClosedBallot model.closedBallots )
                    ] 
                ]
            ]
    }



-- CREATE BALLOT FORM


createBallot : Model -> Html Msg
createBallot model =
    Card.config [ Card.attrs [ class "ballot" ] ]
        |> Card.headerH3 [] [ text "Create ballot" ]
        |> Card.block []
            [ Block.custom <| createBallotForm model ]
        |> Card.view


createBallotForm : Model -> Html Msg
createBallotForm model =
    Form.form
        [ onSubmit CreateBallotSubmitted ]
        [ Form.group []
            [ Form.label [ for "issueinput" ] [ text "Write down a YES/NO question"]
            , Input.text 
                [ Input.attrs
                    [ placeholder "Issue at hand"
                    , disabled model.loadingCreateBallot
                    , value model.createBallotInput
                    , onInput CreateBallotInput
                    ]
                , Input.id "issueinput"
                ]
            ]
        , Form.group []
            ( [ Form.label [ for "issuetimeinput" ] [ text "Closes in" ] 
              , Input.number
                [ Input.attrs
                    [ placeholder "Lasting time"
                    , disabled model.loadingCreateBallot
                    , value model.createBallotTimeInput
                    , onInput CreateBallotTimeInput
                    ]
                , Input.id "issuetimeinput"
                ]
              ] ++
            ( Radio.radioList "timeselect"
                [ Radio.create 
                    [ Radio.id "minutes" 
                    , Radio.checked ( model.createBallotTimeSelection == Minutes )
                    , Radio.onClick ( CreateBallotTimeSelection Minutes )
                    ] "Minutes"
                , Radio.create 
                    [ Radio.id "hours" 
                    , Radio.checked ( model.createBallotTimeSelection == Hours )
                    , Radio.onClick ( CreateBallotTimeSelection Hours )
                    ] "Hours"
                , Radio.create 
                    [ Radio.id "days" 
                    , Radio.checked ( model.createBallotTimeSelection == Days )
                    , Radio.onClick ( CreateBallotTimeSelection Days )
                    ] "Days"
                ]
            ) )
        , Button.button
            [ Button.primary
            , Button.attrs 
                [ class "ml-sm-2 my-2"
                , disabled (String.isEmpty model.createBallotInput)
                ]
            ]
            [ text "Submit" ]
        ]



-- RENDER FUTURE BALLOTS 


renderFutureBallot : Ballots -> Html Msg 
renderFutureBallot ballot = 
    case ballot of 
        YetToVote ballot0 ->
            Card.config [ Card.attrs [ class "ballot" ] ]
                |> Card.headerH4 [] [ a [ href ballot0.data.pull_request.html_url ] [ text <| "Pull Request " ++ String.fromInt ballot0.data.number ] ]
                |> Card.block []
                    [ Block.titleH5 [] [ text <| "Ballot closes on: " ++ ballotCardFormatter Time.utc ballot0.closesOn ]
                    , Block.text [] [ renderVoteButtons ballot0 ]
                    ]
                |> Card.view
        
        AlreadyVoted proof ballot0 ->
            Card.config [ Card.attrs [ class "ballot" ] ]
                |> Card.headerH4 [] [ a [ href ballot0.data.pull_request.html_url ] [ text <| "Pull Request " ++ String.fromInt ballot0.data.number ] ]
                |> Card.block []
                    [ Block.titleH5 [] [ text <| "Ballot closes on: " ++ ballotCardFormatter Time.utc ballot0.closesOn ]
                    , Block.text [] [ text ( "Proof of vote: " ++ proof ) ]
                    ]
                |> Card.view


renderVoteButtons : Ballot -> Html Msg
renderVoteButtons ballot = 
    div []
        [ Button.button [ Button.info, Button.attrs [ onClick ( Voted ballot.ballotBox True ) ] ] [ text "Yes" ]
        , Button.button [ Button.warning, Button.attrs [ onClick ( Voted ballot.ballotBox False ) ] ] [ text "No" ]
        ]



-- RENDER CLOSED BALLOTS 


renderClosedBallot : ClosedBallot -> Html Msg
renderClosedBallot ballot =
    let 
        prUrl = ballot.data.pull_request.html_url
        prNum = String.fromInt ballot.data.number
        ballotClosedOn = ballotCardFormatter Time.utc ballot.closedOn
    in
    Card.config [ Card.attrs [ class "ballot" ] ]
        |> Card.headerH4 [] [ a [ href prUrl ] [ text <| "Pull Request " ++ prNum ] ]
        |> Card.block []
            [ Block.titleH5 [] [ text <| "Ballot closed on: " ++ ballotClosedOn ]
            , Block.text [] ( List.map (\r -> text <| "Merged: " ++ r ) ballot.resolution )
            ]
        |> Card.view



-- DATE


type TimeSelection 
    = Minutes
    | Hours
    | Days


timeSelectionToMillis : String -> TimeSelection -> Int
timeSelectionToMillis input selection =
    let 
        offset = 
            case selection of 
                Minutes ->
                    1000 * 60

                Hours ->
                    1000 * 60 * 60

                Days ->
                    1000 * 60 * 60 * 24
        millis = 
            offset * ( String.toInt input |> Maybe.withDefault 0 )
    in
    millis


ballotCardFormatter : Zone -> Posix -> String
ballotCardFormatter =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.hourMilitaryFixed
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.text " UTC"
        ]



-- EXPORT


toSession : Model -> Session
toSession model = 
    model.session


updateSession : (Session -> Session) -> Model -> Model
updateSession updt model =
    { model | session = updt model.session }
