module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)

import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, field, string)
import Json.Encode as Encode
import Member exposing (Cred(..), registrationResponseDecoder, username)


import Browser.Navigation as Navigation
import Browser exposing (UrlRequest)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Grid.Col as Col
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.ListGroup as Listgroup
import Bootstrap.Modal as Modal
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button

import Shared exposing (..)
import Http exposing (send)
import Member exposing (Cred(..), RegistrationResponse, registrationResponseDecoder)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = UrlChange

        }

init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        ( model, urlCmd ) =
            urlUpdate url
            {
            maybeCred = Nothing,
            navKey = key,
            navState = navState,
            page = Home,
            modalVisibility = Modal.hidden
            , loading = False
            , nickname = ""
            , flags = flags
            }
    in
        ( model, Cmd.batch [ urlCmd, navCmd] )



type Msg
    = UrlChange Url
    | ClickedLink UrlRequest
    | NavMsg Navbar.State
    | CloseModal
    | ShowModal
    | RegisterMember
    | Registered (Result Http.Error RegistrationResponse) String
    | EnteredNickname String


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink req ->
             case req of
                 Browser.Internal url -> ( model, Navigation.pushUrl model.navKey <| Url.toString url )
                 Browser.External href -> ( model, Navigation.load href )
        UrlChange url -> urlUpdate url model
        NavMsg state -> ( { model | navState = state } , Cmd.none )
        CloseModal -> ( { model | modalVisibility = Modal.hidden } , Cmd.none )
        ShowModal -> ( { model | modalVisibility = Modal.shown } , Cmd.none )
        Registered (Ok response) nickname-> ( { model | maybeCred = Just (Cred nickname response.member) } , Cmd.none )
        Registered (Err err) nickname -> ( model, Cmd.none )
        EnteredNickname nickname -> ( { model | nickname = nickname }, Cmd.none )
        RegisterMember -> ( { model | loading = True }, register model.flags.services.kratia model.nickname )




urlUpdate : Url -> Model -> ( Model, Cmd Msg )
urlUpdate url model =
    case decode url of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just route ->
            ( { model | page = route }, Cmd.none )


decode : Url -> Maybe Page
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    |> UrlParser.parse routeParser


routeParser : Parser (Page -> a) a
routeParser =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map GettingStarted (s "some-page")
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Kratia"
    , body =
        [ div []
            [ menu model
            , mainContent model
            , modal model
            ]
        ]
    }



menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ href "#" ] [ text "Kratia" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#some-page" ] [ text "Some page" ]
            ]
        |> Navbar.customItems
            [ Navbar.textItem []
            [ let
               content =
                case model.maybeCred of
                  Nothing -> "Please, login"
                  Just cred ->  "Welcome, " ++ (username cred)
              in text content] ]
        |> Navbar.view model.navState


mainContent : Model -> Html Msg
mainContent model =
    Grid.container [] <|
        case model.page of
            Home ->
                pageHome model

            GettingStarted ->
                pageGettingStarted model

            NotFound ->
                pageNotFound


pageHome : Model -> List (Html Msg)
pageHome model =
    [
     Grid.row []
        [ Grid.col []
            [ Card.config [ Card.outlinePrimary ]
                |> Card.headerH4 [] [ text "Getting started" ]
                |> Card.block []
                    [ Block.text [] [ text "Getting started is real easy. Just click the start button." ]
                    , Block.custom <| userView model
                    ]
                |> Card.view
            ]

        ]
    ]


pageGettingStarted : Model -> List (Html Msg)
pageGettingStarted model =
    [ h2 [] [ text "Getting started" ]
    , Button.button
        [ Button.success
        , Button.large
        , Button.block
        , Button.attrs [ onClick ShowModal ]
        ]
        [ text "Click me" ]
    ]


pageNotFound : List (Html Msg)
pageNotFound =
    [ h1 [] [ text "Not found" ]
    , text "Sorry couldn't find that page"
    ]


modal : Model -> Html Msg
modal model =
    Modal.config CloseModal
        |> Modal.small
        |> Modal.h4 [] [ text "Getting started ?" ]
        |> Modal.body []
            [ Grid.containerFluid []
                [ Grid.row []
                    [ Grid.col
                        [ Col.xs6 ]
                        [ text "Col 1" ]
                    , Grid.col
                        [ Col.xs6 ]
                        [ text "Col 2" ]
                    ]
                ]
            ]
        |> Modal.view model.modalVisibility

userView : Model -> Html Msg
userView model =
    let
        content =
            case model.maybeCred of
                Nothing -> form model
                Just cred -> text ""
    in
    section []
        [  div [ class "p-4" ] [ content ]
        ]

form : Model -> Html Msg
form model =
    Form.formInline
        [ onSubmit RegisterMember ]
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
            [ text "Register" ]
        ]


rootCommunity : String
rootCommunity = "19ce7b9b-a4da-4f9c-9838-c04fcb0ce9db"


register : String -> String  -> Cmd Msg
register server nickname =
 Http.post (server ++ "/api/v1/registry")
   (Http.jsonBody <| Encode.object
     [ ( "community", Encode.string rootCommunity )
     , ( "data", Encode.string nickname )
     ]) registrationResponseDecoder
     |> Http.send (\resp -> Registered resp nickname)
