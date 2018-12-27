module Page.Registration exposing (Model, init, Msg, update, view, toSession, updateSession)

import Browser exposing (UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http

import Bootstrap.Form as Form
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Alert as Alert

import Api exposing (Cred, Session, register, withCreds)
import Route as Route



-- MODEL


type alias Model =
    { session : Session
    , nicknameInput : String
    , loading : Bool
    , errorMessages: List String
    }


init : Session -> ( Model, Cmd Msg )
init session = 
    (
        { session = session
        , nicknameInput = "" 
        , loading = False
        , errorMessages = []
        }
        , Cmd.none
    )



-- UPDATE


type Msg 
    = Submitted
    | EnteredNickname String
    | Registered (Result Http.Error Cred)
    | AlertMsg Alert.Visibility


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        Submitted ->
            ( { model | loading = True }, register 
                { session = model.session
                , nickname = model.nicknameInput 
                , onResponse = Registered 
                }
            )

        EnteredNickname nicknameInput ->
            ( { model | nicknameInput = nicknameInput }, Cmd.none )

        Registered (Ok cred) ->
            ( { model | session = withCreds cred model.session, loading = False } 
            , Route.pushUrl Route.Ballots model.session 
            )

        Registered (Err err) ->
            ( { model | loading = False, errorMessages = model.errorMessages ++ [(Debug.toString err)] }
            , Cmd.none 
            )

        AlertMsg _ ->
            ( { model | errorMessages = [] }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Kratia | Register"
    , content = 
        Grid.container []
            [ Grid.row [] 
                [ Grid.col [] 
                    [ welcoming, div [ class "p-4" ] [ form model ] ] 
                ]
            ]
    }


welcoming : Html Msg
welcoming =
    div []
        [ p [] [ text "To start with the demo, please register with a nickname:" ] ]


viewErrors : Model -> Html Msg
viewErrors model =
    Alert.config
        |> Alert.warning
        |> Alert.dismissable AlertMsg
        |> Alert.children
            ([ Alert.h4 [] [ text "Errors" ]
            ] ++ (List.map (\txt -> p [] [text txt]) model.errorMessages))
        |> Alert.view (if List.isEmpty model.errorMessages then Alert.closed else Alert.shown)


form : Model -> Html Msg
form model =
    Form.formInline
        [ onSubmit Submitted ]
        [ Input.text [ Input.attrs
            [ placeholder "Nickname"
            , disabled model.loading
            , value model.nicknameInput
            , onInput EnteredNickname
            ] ]
        , Button.button
            [ Button.primary
            , Button.attrs [ class "ml-sm-2 my-2"
                              , disabled (String.isEmpty model.nicknameInput)]
            ]
            [ text "Register" ]
        , viewErrors model
        ]



-- EXPORT


toSession : Model -> Session
toSession model = 
    model.session


updateSession : (Session -> Session) -> Model -> Model
updateSession updt model =
    { model | session = updt model.session }
