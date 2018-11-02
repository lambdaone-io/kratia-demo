module Models exposing (..)

import RemoteData exposing (WebData)

type alias Flags =
    {
    services: {
      manga: String
    }

    }
type alias Model =
    { flags: Flags
    , route: Route
    , manga  : WebData( Manga)
    , origin : String
    }


initialModel : Route -> String -> Flags -> Model
initialModel route origin flags =
    { flags = flags
    , route = HelloRoute
    , manga  = RemoteData.Loading
    , origin = origin

    }


type alias Identity =
    {  sub: String
       ,email: String
       ,familyName: Maybe String
       ,gender: Maybe String
       ,givenName: Maybe String
       ,locale: Maybe String
       ,name: Maybe String
       ,picture: Maybe String
       ,profile: Maybe String
    }


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


type Route
    =  NotFoundRoute | HelloRoute
