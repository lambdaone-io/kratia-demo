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
import Page.About as About
import Page.NotFound as NtFnd
import Page.Ballots as Ball
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
    | Ballots Ball.Model


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
    case model of 
        Redirect session ->
            Navbar.subscriptions session.navState NavMsg
        
        NotFound session ->
            Navbar.subscriptions session.navState NavMsg
        
        About session -> 
            Navbar.subscriptions session.navState NavMsg
        
        Registration registration ->
            Navbar.subscriptions registration.session.navState NavMsg

        Ballots ballots ->
            Sub.batch
                [ Navbar.subscriptions ballots.session.navState NavMsg
                , Sub.map BallMsg ( Ball.subscriptions ballots )
                ]



-- UPDATE 


type Msg
    = Ignored
    | RouteChanged (Maybe Route)
    | UrlChanged Url
    | LinkClicked UrlRequest
    | NavMsg Navbar.State
    | RegMsg Reg.Msg
    | BallMsg Ball.Msg


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

        Ballots ballots ->
            Ball.toSession ballots


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

        Ballots ballots ->
            Ballots <| Ball.updateSession updt ballots


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
            case session.credentials of 
                Just _ ->
                    Ball.init session  
                        |> updateWith Ballots BallMsg model

                Nothing ->
                    ( model, Route.pushUrl Route.Registration session )


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

        ( BallMsg subMsg, Ballots ballots ) -> 
            Ball.update subMsg ballots
                |> updateWith Ballots BallMsg model

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
            Page.view session (\_ -> Ignored) NavMsg NtFnd.view

        About _ ->
            Page.view session (\_ -> Ignored) NavMsg About.view

        Registration registration ->
            Reg.view registration
                |> Page.view session RegMsg NavMsg

        Ballots ballots ->
            Ball.view ballots
                |> Page.view session BallMsg NavMsg
