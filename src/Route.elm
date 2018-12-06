module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING

type Route
    = About
    | Registration
    | Ballots


parser : Parser (Route -> a) a
parser =
    oneOf 
        [ Parser.map About Parser.top
        , Parser.map Registration (s "registration")
        , Parser.map Ballots (s "ballots")
        ]



-- PUBLIC HELPERS 


href : Route -> Attribute msg
href target =
    Attr.href (routeToString target)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let 
        parts = case page of 
            About -> []
            Registration -> [ "registration" ]
            Ballots -> [ "ballots" ]
    in
        "#/" ++ String.join "/" parts