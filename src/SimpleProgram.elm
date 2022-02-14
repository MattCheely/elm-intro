module SimpleProgram exposing (..)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


main =
    Browser.sandbox
        { init = initialState
        , update = update
        , view = view
        }


type alias Model =
    { count : Int }


initialState : Model
initialState =
    { count = 0 }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Decrement ->
            { model | count = model.count - 1 }


view : Model -> Html Msg
view model =
    div [ class "wrapper" ]
        [ h1 [ class "count" ]
            [ text (String.fromInt model.count) ]
        , div [ class "controls" ]
            [ button [ class "increment", onClick Increment ]
                [ text "Bigger!" ]
            , button [ class "decrement", onClick Decrement ]
                [ text "Smaller!" ]
            ]
        ]
