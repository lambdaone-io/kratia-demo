module Page.Registration exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onSubmit, onInput)

import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, field, string)
import Json.Encode as Encode
import Member exposing (Cred(..), username)


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
import Member exposing (Cred(..) )

welcoming : Html Msg
welcoming =
    div []
        [ h1 [] [ text "" ]
        , p [] [ text "Welcome to the Kratia Demo" ]
        , p [] [ text "Kratia empowers communities by enabling them with digital governance. It helps the communities grow, evolve and adapt by offering lego blocks for them to design their collaborative decision-making process." ]
        , p [] [ text "To start with the demo, please register with a nickname:" ]
        ]

userView : Model -> Html Msg
userView model =
    let
        content =
            case model.maybeCred of
                Nothing -> [  welcoming,
                                      div [ class "p-4" ] [ form model ]
                                   ]
                Just cred -> []
    in
    section [] content


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

