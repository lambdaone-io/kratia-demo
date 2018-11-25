module Page.Register exposing (Model, Msg, init, update, view)

import Http
import Html exposing (Html, text, pre, div, h1, p)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Form as Form
import Bootstrap.Alert as Alert
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button

import Api exposing (Cred, rootCommunity, register)



-- MODEL


type alias Model =
    { nickname : String
    , loading : Bool
    , registered : Bool
    }


init : ( Model, Cmd Msg )
init = (
    { nickname = "" 
    , loading = False
    , registered = False
    }
    , Cmd.none)



-- UPDATE


type Msg 
    = Submitted
    | EnteredNickname String
    | Registered (Result Http.Error Cred)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Submitted ->
            ( { model | loading = True }, register { community = rootCommunity, data = model.nickname } Registered )

        EnteredNickname nickname ->
            ( { model | nickname = nickname }, Cmd.none )

        Registered _ ->
            ( { model | registered = True }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the boostrap CSS
        , Grid.row [] 
            [ Grid.col [] [ welcoming ] ]
        , Grid.row []
            [ Grid.col [] []
            , Grid.col 
                [ Col.middleXs ]
                [ if model.registered then success model else if model.loading then loading model else form model ]
            , Grid.col [] []
            ]
        ]


welcoming : Html Msg 
welcoming =
    div []
        [ h1 [] [ text "Kratia Demo" ]
        , p [] [ text "Welcome to the Kratia Demo" ]
        , p [] [ text "Kratia empowers communities by enabling them with digital governance. It helps the communities grow, evolve and adapt by offering lego blocks for them to design their collaborative decision-making process." ]
        , p [] [ text "To start with the demo, please register with a nickname:" ]
        ]


form : Model -> Html Msg 
form model =
    Form.formInline 
        [ onSubmit Submitted ]
        [ Input.text [ Input.attrs 
            [ placeholder "Nickname"
            , disabled model.loading
            , value model.nickname
            , onInput EnteredNickname 
            ] ]
        , Button.button
            [ Button.primary
            , Button.attrs [ class "ml-sm-2 my-2" ]
            ]
            [ text "Start" ]
        ]


loading : Model -> Html Msg
loading model = 
    div [] 
        [ Alert.simpleInfo []
            [ Alert.h4 [] [ text "Loading..." ] 
            , text <| "Thank you for registering " ++ model.nickname ++ ", we are setting up things for you now." 
            ]
        ]


success : Model -> Html Msg
success model =
    div [] 
        [ Alert.simpleInfo []
            [ Alert.h4 [] [ text "Success" ] 
            , text <| "Welcome " ++ model.nickname ++ "." 
            ]
        ]
