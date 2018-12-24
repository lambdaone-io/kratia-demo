module Main exposing (main)


import Browser.Navigation as Nav
import Browser exposing (UrlRequest)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (..)

import Bootstrap.Navbar as Navbar
import Bootstrap.Grid.Col as Col

import Api exposing (Cred, username, Service(..))
import Config exposing (Config, Flags, fromFlags)
import Route exposing (Route)
import Page as Page exposing (Page(..))
import Page.Registration as Reg



main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { credentials : Maybe Cred
    , config : Config
    , navKey : Nav.Key
    , navState : Navbar.State
    , page : Page
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let 
        config = fromFlags flags

        ( navState, navCmd ) =
            Navbar.initialState NavMsg
        
        ( model, routeCmd ) =
            changeRouteTo (Route.fromUrl url)
                { credentials = Nothing
                , config = config
                , navKey = key
                , navState = navState
                , page = About
                }
    in
        ( model, Cmd.batch [ routeCmd, navCmd ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg



-- UPDATE 


type Msg
    = Ignored
    | RouteChanged (Maybe Route)
    | UrlChanged Url
    | LinkClicked UrlRequest
    | NavMsg Navbar.State
    | RegMsg Reg.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RouteChanged route, _ ) ->
            changeRouteTo route model

        ( UrlChanged url, _ ) -> 
            changeRouteTo (Route.fromUrl url) model

        ( LinkClicked req, _ ) ->
             case req of
                 Browser.Internal url -> ( model, Nav.pushUrl model.navKey <| Url.toString url )
                 Browser.External href -> ( model, Nav.load href )

        ( NavMsg state, _ ) -> 
            ( { model | navState = state } , Cmd.none )

        ( RegMsg subMsg, Registration registration ) -> 
            Reg.update subMsg registration
                |> updateWith Registration RegMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
        
        Just Route.About ->
            ( { model | page = About }, Cmd.none )

        Just Route.Registration ->
            Reg.init model.config.kratia model.credentials
                |> updateWith Registration RegMsg model

        Just Route.Ballots ->
            ( { model | page = Ballots }, Cmd.none )


updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( { model | page = toModel subModel }, Cmd.map toMsg subCmd )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        session =
            { credentials = model.credentials
            , state = model.navState
            }
    in
    case model.page of
        NotFound ->
            Page.view session (\_ -> Ignored) NavMsg
                { title = "404"
                , content =
                    div []
                        [ h1 [] [ text "Not found" ]
                        , text "Sorry couldn't find that page"
                        ]
                }

        Registration registration ->
            Page.view session RegMsg NavMsg
                { title = "Registration"
                , content = Reg.view registration
                }

        Ballots ->
            Page.view session (\_ -> Ignored) NavMsg
                { title = "404"
                , content = h1 [] [ text "Ballots" ] 
                }

        About ->
            Page.view session (\_ -> Ignored) NavMsg
                { title = "About"
                , content = h1 [] [ text "About" ]
                }
