module Member exposing (..)


import Html exposing (..)
import Html.Attributes exposing (class, href, value, src, width)
import Html.Events exposing (onClick)
import Http
import List exposing (filter, head)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional)


-- CRED


{-| The authentication credentials for the Viewer (that is, the currently logged-in user.)
This includes:

- The cred's Username
- The cred's authentication token

By design, there is no way to access the token directly as a String.
It can be encoded for persistence, and it can be added to a header
to a HttpBuilder for a request, but that's it.

This token should never be rendered to the end user, and with this API, it
can't be!

-}

type alias Token = String

type Cred = Cred String Token


username : Cred -> String
username (Cred name _) = name

credHeader : Cred -> Http.Header
credHeader (Cred _ token) =
 Http.header "Authorization" ("Bearer " ++ token)

type alias RegistrationRequest =
    { community: String
    , data: String
    }

type alias RegistrationResponse =
    {  member: String
    }


-- DECODERS

registrationResponseDecoder : Decode.Decoder RegistrationResponse
registrationResponseDecoder =
    Decode.succeed RegistrationResponse
        |> required "member" Decode.string
