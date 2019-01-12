module GitHub.PullRequest exposing (..)


import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import GitHub.GitHubUser as GHUser exposing (GitHubUser)


type alias PullRequestEvent = 
    { action : String
    , number : Int
    , pull_request : PullRequest
    }


type alias PullRequest =
    { id: Int
    , html_url : String
    , state : String 
    , user : GitHubUser
    , body : String
    , created_at : String
    }


eventDecoder : Decoder PullRequestEvent
eventDecoder =
    Decode.succeed PullRequestEvent
        |> required "action" Decode.string
        |> required "number" Decode.int
        |> required "pull_request" decoder


decoder : Decoder PullRequest
decoder =
    Decode.succeed PullRequest
        |> required "id" Decode.int
        |> required "html_url" Decode.string
        |> required "state" Decode.string
        |> required "user" GHUser.decoder
        |> required "body" Decode.string 
        |> required "created_at" Decode.string
