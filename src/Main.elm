module Main exposing (main)

import Browser
import Css exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import String exposing (append, dropRight, toUpper)


type Msg
    = KeyPressed Letter
    | EraseLetter Word
    | ResetWord Word
    | SubmitWord Word


type alias Model =
    { title : String
    , word : Word
    }


initialModel : Model
initialModel =
    { title = "Speak & Spell"
    , word = ""
    }


type alias Letter =
    String


type alias Word =
    String



{-
   appendToWord : Word -> Letter -> Word
   appendToWord word letter =
       append word letter


   popTheLastLetter : Word -> Word
   popTheLastLetter word =
       dropRight 1 word
-}


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text model.title ]
        , div []
            [ button [] [ text "Module Select" ]
            , button [] [ text "New Word" ]
            , button [] [ text "Say It" ]
            , button [] [ text "Spell" ]
            ]
        , br [] []
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
        , div []
            [ p [] [ text model.word ]
            ]
        , div []
            [ button [ onClick (ResetWord "") ] [ text "Replay" ]
            , button [ onClick (EraseLetter model.word) ] [ text "Erase" ]
            , button [ onClick (SubmitWord model.word) ] [ text "Enter" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed string ->
            ( { model | word = append model.word (toUpper string) }, Cmd.none )

        ResetWord string ->
            ( { model | word = string }, Cmd.none )

        EraseLetter string ->
            ( { model | word = dropRight 1 string }, Cmd.none )

        SubmitWord string ->
            ( { model | word = string ++ " submitted!" }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
