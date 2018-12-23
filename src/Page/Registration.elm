module Page.Registration exposing (Model, init, Msg, update, view)

import Browser.Navigation as Navigation
import Browser exposing (UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http as Http

import Bootstrap.Form as Form
import Bootstrap.Grid.Col as Col
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Alert as Alert

import Api exposing (Cred, Service, register)



-- MODEL


type alias Model =
    { kratia : Service
    , credentials : Maybe Cred
    , nicknameInput : String
    , loading : Bool
    , errorMessages: List String
    }


init : Service -> Maybe Cred -> ( Model, Cmd Msg )
init kratia credentials = 
    (
        { kratia = kratia
        , credentials = credentials
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
                { service = model.kratia
                , nickname = model.nicknameInput 
                , onResponse = Registered 
                }
            )

        EnteredNickname nicknameInput ->
            ( { model | nicknameInput = nicknameInput }, Cmd.none )

        Registered (Ok cred) ->
            ( { model | credentials = Just cred, loading = False } , Cmd.none )

        Registered (Err err) ->
            ( { model | loading = False , errorMessages = model.errorMessages ++ [(Debug.toString err)] }, Cmd.none )

        AlertMsg _ ->
            ( { model | errorMessages = [] }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    section [] (case model.credentials of
        Nothing -> 
            [  welcoming, div [ class "p-4" ] [ form model ] ]

        Just cred ->
            []
    )


welcoming : Html Msg
welcoming =
    div []
        [ h1 [] [ text "" ]
        , p [] [ text "Welcome to the Kratia Demo" ]
        , p [] [ text "Kratia empowers communities by enabling them with digital governance. It helps the communities grow, evolve and adapt by offering lego blocks for them to design their collaborative decision-making process." ]
        , p [] [ text "To start with the demo, please register with a nickname:" ]
        ]


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
