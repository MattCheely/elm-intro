module GifProgram exposing (..)

import Browser
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Http exposing (expectJson)
import Json.Decode as Decode exposing (Decoder)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }



-- Model


type alias Model =
    { imgUrl : String }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { imgUrl = notFoundImg }, Cmd.none )


giphyKey : String
giphyKey =
    "vSKgXSeeaqqZZMy4huWtGhiJfygTmtpC"


notFoundImg : String
notFoundImg =
    "https://media.giphy.com/media/26xBIygOcC3bAWg3S/giphy.gif"


loadingImg : String
loadingImg =
    "https://media.giphy.com/media/W22b2eea2XxB6DiTWg/giphy.gif"


searchDecoder : Decoder String
searchDecoder =
    Decode.at [ "data", "images", "fixed_height_small", "url" ] Decode.string



-- Update


type Msg
    = Search
    | SearchResults (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( { model | imgUrl = loadingImg }, catSearch )

        SearchResults result ->
            let
                url =
                    result
                        |> Result.withDefault notFoundImg
            in
            ( { model | imgUrl = url }, Cmd.none )


catSearch : Cmd Msg
catSearch =
    Http.get
        { url = "https://api.giphy.com/v1/gifs/random?tag=cat&rating=g&api_key=" ++ giphyKey
        , expect = expectJson SearchResults searchDecoder
        }



-- View


view : Model -> Html Msg
view model =
    div [ class "cat-picker" ]
        [ div [ class "cat-image" ]
            [ img [ src model.imgUrl ] [] ]
        , button [ onClick Search ] [ text "CATS!" ]
        ]



-- Subscriptions


subs : Model -> Sub Msg
subs model =
    Sub.none
