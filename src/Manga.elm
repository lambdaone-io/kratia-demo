module Manga exposing (..)


import Html exposing (..)
import Html.Attributes exposing (class, href, value, src, width)
import Html.Events exposing (onClick)
import Http
import List exposing (filter, head)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional)

type alias MangaCharacter =
    { malId : Int
          , url : String
          , imageUrl : String
          , name : String
          , role : String
    }

type alias Manga =
    {  requestHash: String,
      requestCaches: Bool,
      requestCacheExpiry: Int,
      characters: List MangaCharacter
    }


communityView: Manga -> Html msg
communityView manga =
  div []
    [ div  [] [h1 [] [text "All community members"]],

       div []
       (List.map (\c -> div [] [text c.name, img [ src c.imageUrl, width 32 ] [], editCharacter c] ) manga.characters)

    ]


memberView: Manga -> Int -> Html msg
memberView manga id =
  let member = filter (\c -> c.malId == id) manga.characters
  in case head member of
      Just c -> div [] [text c.name, img [ src c.imageUrl, width 32 ] []]
      Nothing -> text "Not gound"


editCharacter : MangaCharacter -> Html.Html msg
editCharacter character  =
    let
        path = "/editmember" -- FIXME
    in
    a
        [ class "btn regular"
        , href path
        ]
        [ i [ class "fa fa-edit mr-1" ] [], text "Edit" ]



-- DECODERS

mangaDecoder : Decode.Decoder Manga
mangaDecoder =
    Decode.succeed Manga
        |> required "request_hash" Decode.string
        |> required "request_cached" Decode.bool
        |> required "request_cache_expiry" Decode.int
        |> required "characters" (Decode.list mangaCharacterDecoder)


mangaCharacterDecoder : Decode.Decoder MangaCharacter
mangaCharacterDecoder =
    Decode.succeed MangaCharacter
        |> required "mal_id" Decode.int
        |> required "url" Decode.string
        |> required "image_url" Decode.string
        |> required "name" Decode.string
        |> required "role" Decode.string