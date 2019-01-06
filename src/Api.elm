module Api exposing (Cred, Flags, Session, guest, withCreds, withNavState, username, register, listBallots, createBallot, errorMessage, voteBinary)

{-| This module is responsible for communicating to the Kratia API. -}

import Browser.Navigation as Nav
import Bootstrap.Navbar as Navbar
import Time exposing (Posix, posixToMillis)

import Url.Builder exposing (QueryParameter)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, field, string, list)
import Json.Encode as Encode

import Kratia.Ballot as Ballot exposing (Ballot)


-- CRED


type alias Token = String

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
type Cred = Cred String Token


username : Cred -> String 
username (Cred name _) = name


credHeader : Cred -> Http.Header
credHeader (Cred _ token) = 
    Http.header "Authorization" ("Bearer " ++ token)


{- Hardcoded user used only for speedy manual testing -}
hardcodedUser : Cred
hardcodedUser = Cred "User" "fdc7dcc3-3ecb-48c2-9954-334267623530"



-- SESSION


type alias Session = 
    { credentials : Maybe Cred
    , navKey : Nav.Key
    , navState : Navbar.State
    , config : Config
    }


type alias Config =
    { kratia : Service }


type alias Flags =
    { services : 
        { kratia : 
            { hostname : String
            , prefix : List String
            }
        }
    }


guest : Flags -> Nav.Key -> Navbar.State -> Session
guest flags key state =
    { credentials = Nothing -- Just hardcodedUser -- Change me to Nothing
    , navKey = key
    , navState = state 
    , config = 
      { kratia = Service flags.services.kratia.hostname flags.services.kratia.prefix }
    }


withCreds : Cred -> Session -> Session
withCreds cred session =
    { session | credentials = Just cred }


withNavState : Navbar.State -> Session -> Session
withNavState state session =
    { session | navState = state }



-- SERVICE


type alias Hostname = String


type alias PathSection = String


type Service = Service Hostname (List PathSection)


rootCommunity : String
rootCommunity = "19ce7b9b-a4da-4f9c-9838-c04fcb0ce9db"


url : Service -> List PathSection -> List QueryParameter -> String
url (Service hostname prefix) paths queryParams =
  Url.Builder.crossOrigin hostname
      (prefix ++ paths)
      queryParams



-- ENDPOINTS 


register : { session : Session, nickname : String, onResponse : (Result Http.Error Cred -> msg) } -> Cmd msg
register { session, nickname, onResponse } =
  Http.post 
    { url = url session.config.kratia ["registry"] []
    , body = Http.jsonBody <| Encode.object 
      [ ( "community", Encode.string rootCommunity )
      , ( "data", Encode.object 
            [ ( "nickname", Encode.string nickname ) ]
        )
      ]
    , expect = Http.expectJson (\result -> onResponse <| Result.map (Cred nickname) result ) (field "member" string)
    }


listBallots : { session : Session, onResponse : (Result Http.Error (List Ballot) -> msg) } -> Cmd msg
listBallots { session, onResponse } =
    session |> authed (\ cred ->
        Http.request
            { method = "GET"
            , headers = [ credHeader cred ]
            , url = url session.config.kratia ["collector"] []
            , body = Http.emptyBody
            , expect = Http.expectJson (\result -> onResponse result) (field "data" (list Ballot.decoder))
            , timeout = Nothing
            , tracker = Nothing
            }
    )


createBallot : { session : Session, data : String, closesOn: Posix, onResponse : (Result Http.Error Ballot -> msg) } -> Cmd msg
createBallot { session, data, closesOn, onResponse } =
    let
        closesSeconds = ( posixToMillis closesOn ) // 1000
        body = Http.jsonBody <| Encode.object
            [ ("validBallot", Encode.list Encode.string [ "yes", "no" ])
            , ("data", Encode.string data)
            , ("closesOn", Encode.int closesSeconds)
            ]
    in
    session |> authed (\ cred ->
        Http.request
            { method = "POST"
            , headers = [ credHeader cred ]
            , url = url session.config.kratia ["collector"] []
            , body = body
            , expect = Http.expectJson (\result -> onResponse result) (field "data" Ballot.decoder)
            , timeout = Nothing
            , tracker = Nothing
            }
    )


voteBinary : { session : Session, box : String, vote : Bool, onResponse : (Result Http.Error (String, String) -> msg) } -> Cmd msg
voteBinary { session, box, vote, onResponse } =
    let 
        vote0 = 
            if vote 
            then Encode.object [ ("yes", Encode.float 1.0), ("no", Encode.float 0.0) ]
            else Encode.object [ ("yes", Encode.float 0.0), ("no", Encode.float 1.0) ]
        body = Http.jsonBody <| Encode.object
            [ ("ballotBox", Encode.string box)
            , ("vote", vote0)
            ]
    in
    session |> authed (\ cred ->
        Http.request
            { method = "POST"
            , headers = [ credHeader cred ]
            , url = url session.config.kratia ["collector", "vote"] []
            , body = body
            , expect = Http.expectJson (\result -> onResponse <| Result.map (\proof -> (box, proof)) result) (field "proof" string)
            , timeout = Nothing
            , tracker = Nothing
            }
    )



-- ENDPOINTS HELPERS


authed : ( Cred -> Cmd msg ) -> Session  -> Cmd msg
authed f session = 
    case session.credentials of 
        Nothing ->
            Cmd.none
        
        Just cred ->
            f cred


errorMessage : Http.Error -> String
errorMessage err =
    case err of
        Http.BadUrl _ ->
            "Bad url, this is a bug that should be reported"

        Http.Timeout ->
            "The server timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "Got unexpected response " ++ ( String.fromInt status )

        Http.BadBody _ ->
            "Bad body on request, this is a bug that should be reported"
