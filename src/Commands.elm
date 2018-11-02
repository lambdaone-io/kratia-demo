module Commands exposing (..)

import Http exposing (emptyBody)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (Flags, Identity, Manga, MangaCharacter)
import RemoteData
import Platform.Cmd exposing (batch)

fetchInitialData : Flags -> Cmd Msg
fetchInitialData flags   =
     batch [  fetchManga flags.services.manga]

fetchManga : String -> Cmd Msg
fetchManga service =
    Http.get (service ++ "/manga/1/characters") mangaDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchManga



mangaDecoder : Decode.Decoder Manga
mangaDecoder =
    decode Manga
        |> required "request_hash" Decode.string
        |> required "request_cached" Decode.bool
        |> required "request_cache_expiry" Decode.int
        |> required "characters" (Decode.list mangaCharacterDecoder)


mangaCharacterDecoder : Decode.Decoder MangaCharacter
mangaCharacterDecoder =
    decode MangaCharacter
        |> required "mal_id" Decode.int
        |> required "url" Decode.string
        |> required "image_url" Decode.string
        |> required "name" Decode.string
        |> required "role" Decode.string




