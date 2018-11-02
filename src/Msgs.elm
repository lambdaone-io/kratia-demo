module Msgs exposing (..)

import Models exposing (Manga)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    =  OnFetchManga (WebData Manga)
    | OnLocationChange Location
