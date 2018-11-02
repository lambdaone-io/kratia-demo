module Manga exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (Manga, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Base64 exposing(..)

mangaArea: Manga -> Html msg
mangaArea manga =
  div []
    [ text "Here's some manga",
      ul []
           (List.map (\c -> li [] [div [] [text c.name, img [ src c.imageUrl, width 32 ] []] ]) manga.characters)
    ]

