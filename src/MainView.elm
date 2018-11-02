module MainView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (Model )
import Models exposing (Model)
import Msgs exposing (Msg)
import View exposing (page)


mainView : Model -> Html Msg
mainView model =
  div []
      [
      div [ class "container" ]
          [ div [ id "main" ]
              [ page model ]
          ]
          ]


