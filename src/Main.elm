module Main exposing (main)

import Browser
import Css exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import String exposing (..)


type Msg
    = KeyPressed Letter
    | ResetWord Word
    | EraseLetter


type alias Model =
    { instructions : String
    , word : Word
    }


type alias Letter =
    String


type alias Word =
    String


initialModel : Model
initialModel =
    { instructions = "Press Keys To Compose a Word"
    , word = ""
    }


appendToWord : Word -> Letter -> Word
appendToWord word letter =
    append word letter


popTheLastLetter : Word -> Word
popTheLastLetter word =
    dropRight 1 word


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Speak & Spell" ]
        , h4 [] [ text model.instructions ]
        , div []
            [ button [ onClick (KeyPressed "a") ] [ text "A" ]
            , button [ onClick (KeyPressed "b") ] [ text "B" ]
            , button [ onClick (KeyPressed "c") ] [ text "C" ]
            , button [ onClick (KeyPressed "d") ] [ text "D" ]
            , button [ onClick (KeyPressed "e") ] [ text "E" ]
            , button [ onClick (KeyPressed "f") ] [ text "F" ]
            , button [ onClick (KeyPressed "g") ] [ text "G" ]
            , button [ onClick (KeyPressed "h") ] [ text "H" ]
            , button [ onClick (KeyPressed "i") ] [ text "I" ]
            , button [ onClick (KeyPressed "j") ] [ text "J" ]
            , button [ onClick (KeyPressed "k") ] [ text "K" ]
            , button [ onClick (KeyPressed "l") ] [ text "L" ]
            , button [ onClick (KeyPressed "m") ] [ text "M" ]
            ]
        , div []
            [ button [ onClick (KeyPressed "n") ] [ text "N" ]
            , button [ onClick (KeyPressed "o") ] [ text "O" ]
            , button [ onClick (KeyPressed "p") ] [ text "P" ]
            , button [ onClick (KeyPressed "q") ] [ text "Q" ]
            , button [ onClick (KeyPressed "r") ] [ text "R" ]
            , button [ onClick (KeyPressed "s") ] [ text "S" ]
            , button [ onClick (KeyPressed "t") ] [ text "T" ]
            , button [ onClick (KeyPressed "u") ] [ text "U" ]
            , button [ onClick (KeyPressed "v") ] [ text "V" ]
            , button [ onClick (KeyPressed "w") ] [ text "W" ]
            , button [ onClick (KeyPressed "x") ] [ text "X" ]
            , button [ onClick (KeyPressed "y") ] [ text "Y" ]
            , button [ onClick (KeyPressed "z") ] [ text "Z" ]
            ]
        , p [] [ text model.word ]
        , button [ onClick (ResetWord "") ] [ text "Reset" ]
        , button [ onClick EraseLetter ] [ text "Delete" ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed string ->
            ( { model | word = appendToWord model.word (toUpper string) }, Cmd.none )

        ResetWord string ->
            ( { model | word = string }, Cmd.none )

        EraseLetter ->
            ( { model | word = popTheLastLetter model.word }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
