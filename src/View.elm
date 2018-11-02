module View exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Msgs exposing (Msg)
import RemoteData
import Manga exposing (mangaArea)


view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    case model.route of
        Models.HelloRoute ->
            helloView model
        Models.NotFoundRoute ->
            notFoundView

notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]

helloView : Model -> Html msg
helloView model =
   case model.manga of
           RemoteData.NotAsked ->
               text "?"

           RemoteData.Loading ->
               text "Loading..."

           RemoteData.Success manga ->
                mangaArea manga

           RemoteData.Failure error ->
               text ("Can't retrieve manga" ++ (toString error))