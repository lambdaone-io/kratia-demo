module Page exposing (view)


import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col

import Api exposing (Cred, Session, username)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Browser exposing (Document)

import Route as Route
import Page.Registration as Reg
import Page.Ballots as Ball



{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
view : Session -> ( subMsg -> msg ) -> ( Navbar.State -> msg ) -> { title : String, content : Html subMsg } -> Document msg
view session toMsg navMsg { title, content } =
    { title = title ++ " - Kratia"
    , body = 
        [ Grid.containerFluid []
            [ Grid.row [] 
                [ Grid.col 
                    [ Col.attrs [ class "p-0" ] ] 
                    [ menu session navMsg ] ]
            , Grid.row []
                [ Grid.col [] [ Html.map toMsg content ] ]
            ]
        ]
    }


menu : Session -> ( Navbar.State -> msg ) -> Html msg
menu session navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.darkCustomClass "main-navbar"
        |> Navbar.brand [ Route.href Route.Ballots ] [ text "Kratia" ]
        |> Navbar.items
            [ Navbar.itemLink [ Route.href Route.About ] [ text "About" ] ]
        |> Navbar.customItems ( menuRight session )
        |> Navbar.view session.navState


menuRight : Session -> List ( Navbar.CustomItem msg )
menuRight session = 
    case session.credentials of
        Nothing -> menuRightNotLoggedIn
        Just credentials -> menuRightLoggedIn credentials


menuRightNotLoggedIn : List ( Navbar.CustomItem msg )
menuRightNotLoggedIn =
    [ Navbar.formItem [] 
        [ Button.linkButton
            [ Button.success
            , Button.attrs [ Route.href Route.Registration ] 
            ]
            [ text "Register" ] 
        ]
    ]


menuRightLoggedIn : Cred -> List ( Navbar.CustomItem msg ) 
menuRightLoggedIn credentials =
    [ Navbar.textItem [] 
        [ text <| "Welcome " ++ ( username credentials ) ] 
    ]
