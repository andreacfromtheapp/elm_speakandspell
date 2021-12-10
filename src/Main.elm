module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import String exposing (..)


type Msg
    = Key String


type alias Model =
    { screen : String }


initialModel : Model
initialModel =
    { screen = "Welcome to Speak & Spell" }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Speak & Spell" ]
        , button [ onClick (Key "A") ] [ text "A" ]
        , h3 [] [ text model.screen ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Key string ->
            ( { model | screen = string }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
