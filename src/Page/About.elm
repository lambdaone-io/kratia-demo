module Page.About exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Bootstrap.Grid as Grid



view : { title : String, content : Html msg }
view =
    { title = "Kratia"
    , content = 
        Grid.container []
            [ Grid.row [] 
                [ Grid.col [] 
                    [ h1 [] [ text "Welcome to the Kratia Demo" ]
                    , p [] [ text "Kratia empowers communities by enabling them with digital governance. It helps the communities grow, evolve and adapt by offering lego blocks for them to design their collaborative decision-making process." ]
                    ]
                ]
            ]
    }