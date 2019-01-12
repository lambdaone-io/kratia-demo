module GitHub.GitHubUser exposing (..)


import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias GitHubUser =
    { login : String
    , id : Int
    , avatar_url : String
    }


decoder : Decoder GitHubUser
decoder =
    Decode.succeed GitHubUser
        |> required "login" Decode.string
        |> required "id" Decode.int
        |> required "avatar_url" Decode.string
