module Main exposing (main)


import Browser.Navigation as Nav
import Browser exposing (UrlRequest)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, s, top)
import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (..)

import Bootstrap.Navbar as Navbar
import Bootstrap.Grid.Col as Col

import Api exposing (Cred, Flags, Session, guest, username, withNavState)
import Route exposing (Route)
import Page as Page
import Page.Blank as Blk
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


type Model 
    = Redirect Session
    | NotFound Session
    | About Session
    | Registration Reg.Model
    | Ballots Session


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let 
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
        
        ( model, routeCmd ) =
            changeRouteTo (Route.fromUrl url)
                (Redirect (guest flags key navState))
    in
        ( model, Cmd.batch [ routeCmd, navCmd ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let 
        session =
            lastSession model
    in
    Navbar.subscriptions session.navState NavMsg



-- UPDATE 


type Msg
    = Ignored
    | RouteChanged (Maybe Route)
    | UrlChanged Url
    | LinkClicked UrlRequest
    | NavMsg Navbar.State
    | RegMsg Reg.Msg


lastSession : Model -> Session
lastSession model = 
    case model of 
        Redirect session ->
            session
        
        NotFound session ->
            session
        
        About session -> 
            session
        
        Registration registration ->
            Reg.toSession registration

        Ballots session ->
            session


updateSession : (Session -> Session) -> Model -> Model
updateSession updt model = 
    case model of 
        Redirect session ->
            Redirect <| updt session
        
        NotFound session ->
            NotFound <| updt session
        
        About session -> 
            About <| updt session
        
        Registration registration ->
            Registration <| Reg.updateSession updt registration

        Ballots session ->
            Ballots <| updt session


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let 
        session =
            lastSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )
        
        Just Route.About ->
            ( About session, Cmd.none )

        Just Route.Registration ->
            Reg.init session  
                |> updateWith Registration RegMsg model

        Just Route.Ballots ->
            ( Ballots session, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let 
        session =
            lastSession model
    in
    case ( msg, model ) of
        ( RouteChanged route, _ ) ->
            changeRouteTo route model

        ( UrlChanged url, _ ) -> 
            changeRouteTo (Route.fromUrl url) model

        ( LinkClicked req, _ ) ->
            case req of
                Browser.Internal url -> ( model, Nav.pushUrl session.navKey <| Url.toString url )
                Browser.External href -> ( model, Nav.load href )

        ( NavMsg state, _ ) -> 
            ( model |> updateSession (withNavState state), Cmd.none )

        ( RegMsg subMsg, Registration registration ) -> 
            Reg.update subMsg registration
                |> updateWith Registration RegMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        session =
            lastSession model
    in
    case model of
        Redirect _ ->
            Page.view session (\_ -> Ignored) NavMsg Blk.view

        NotFound _ ->
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

        Ballots _ ->
            Page.view session (\_ -> Ignored) NavMsg
                { title = "Ballots"
                , content = h1 [] [ text "Ballots" ] 
                }

        About _ ->
            Page.view session (\_ -> Ignored) NavMsg
                { title = "About"
                , content = h1 [] [ text "About" ]
                }
