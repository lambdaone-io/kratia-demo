module Page exposing (Page(..), view)


import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button

import Api exposing (Cred, username)
import Html exposing (Html, div, text)
import Browser exposing (Document)

import Route as Route
import Page.Registration as Reg



type Page
    = About
    | Registration Reg.Model
    | Ballots
    | NotFound


type alias Session =
    { credentials : Maybe Cred
    , state : Navbar.State 
    }


{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
view : Session -> ( subMsg -> msg ) -> ( Navbar.State -> msg ) -> { title : String, content : Html subMsg } -> Document msg
view session toMsg navMsg { title, content } =
    { title = title ++ " - Kratia"
    , body = (menu session navMsg) :: [ Html.map toMsg content ]
    }


menu : Session -> ( Navbar.State -> msg ) -> Html msg
menu session navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [ Route.href Route.Ballots ] [ text "Kratia" ]
        |> Navbar.items
            [ Navbar.itemLink [ Route.href Route.About ] [ text "About" ] ]
        |> Navbar.customItems
            (case session.credentials of
                Nothing -> 
                    [ Navbar.formItem [] 
                        [ Button.linkButton
                            [ Button.success
                            , Button.attrs [ Route.href Route.Registration ] 
                            ]
                            [ text "Register" ] 
                        ]
                    ]

                Just cred ->
                    [ Navbar.textItem [] [ text <| "Welcome " ++ (username cred) ] ]
            )
        |> Navbar.view session.state
