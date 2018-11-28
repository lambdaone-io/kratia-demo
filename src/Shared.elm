module Shared exposing (..)

import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.Modal as Modal
import Browser.Navigation as Navigation
import Member exposing (Cred(..) )
import Browser exposing (UrlRequest)
import Http exposing (Body, Expect)

import Url exposing (Url)

type alias Flags =
    {
    services: {
      kratia : String
    }
    }

type alias Model =
    { navKey : Navigation.Key
    , page : Page
    , navState : Navbar.State
    , modalVisibility : Modal.Visibility
    , maybeCred : Maybe Cred
    , nickname: String
    , loading: Bool
    , flags: Flags

    }

type Page
    = Home
    | GettingStarted
    | NotFound

type RemoteData a
    = NotAsked
    | Loading
    | Loaded a
    | Failure


type Msg
    = UrlChange Url
    | ClickedLink UrlRequest
    | NavMsg Navbar.State
    | CloseModal
    | ShowModal
    | RegisterMember
    | Registered (Result Http.Error String) String
    | EnteredNickname String