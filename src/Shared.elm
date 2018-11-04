module Shared exposing (..)

import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Button as Button
import Bootstrap.ListGroup as Listgroup
import Bootstrap.Modal as Modal
import Browser.Navigation as Navigation
import Manga exposing (Manga)

type alias Flags =
    {
    services: {
      manga : String
    }
    }

type alias Model =
    { navKey : Navigation.Key
    , page : Page
    , navState : Navbar.State
    , modalVisibility : Modal.Visibility
    , manga : RemoteData Manga
    }

type Page
    = Home
    | GettingStarted
    | Modules
    | NotFound

type RemoteData a
    = NotAsked
    | Loading
    | Loaded a
    | Failure