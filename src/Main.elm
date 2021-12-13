module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import String exposing (append, dropRight, toUpper)


randomWordAPIRequest : String
randomWordAPIRequest =
    "https://random-words-api.vercel.app/word"


type Msg
    = GetNewWord (Result Http.Error (List NewWord))
    | GetAnotherWord
    | KeyPressed String
    | EraseLetter String
    | SubmitWord GuessWord CheckWord
    | ResetWord


type alias GuessWord =
    String


type alias CheckWord =
    String


type alias NewWord =
    { word : String
    , definition : String
    , pronunciation : String
    }


type alias Model =
    { -- status : Status
      title : String
    , newWord : NewWord
    , guessWord : GuessWord
    , checkWord : CheckWord
    , result : String
    }


initialModel : Model
initialModel =
    { -- status = Loading
      title = "Speak & Spell"
    , newWord =
        { word = "init word"
        , definition = "init definition"
        , pronunciation = "init pronunciation"
        }
    , guessWord = ""
    , checkWord = ""
    , result = ""
    }



-- type Status
--     = Loading
--     | Loaded NewWord
--     | Errored String
-- view : Model -> Html Msg
-- view model =
--     div [] <|
--         case model.status of
--             Loaded word ->
--                 viewLoaded word model
--             Loading ->
--                 [ text "Loading..." ]
--             Errored errorMessage ->
--                 [ text ("Error: " ++ errorMessage) ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text model.title ]
        , div []
            -- screen
            [ hr [] []
            , p [] [ text ("your word is: " ++ toUpper model.newWord.word) ]
            , p [] [ text ("definition: " ++ model.newWord.definition) ]
            , p [] [ text ("pronunciation: " ++ model.newWord.pronunciation) ]
            ]

        -- keyboard
        , hr [] []
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

        -- output
        , hr [] []
        , p [] [ text model.guessWord ]
        , p [] [ text model.result ]

        -- commands
        , hr [] []
        , div []
            [ button [ onClick GetAnotherWord ] [ text "New Word" ]
            , button [] [ text "Say Word" ]
            , button [] [ text "Spell Word" ]
            ]
        , div []
            [ button [ onClick ResetWord ] [ text "Reset Word" ]
            , button [ onClick (EraseLetter model.guessWord) ] [ text "Erase Letter" ]
            ]
        , div []
            [ button [ onClick (SubmitWord model.guessWord model.newWord.word) ] [ text "Submit Word" ]
            , button [ onClick ResetWord ] [ text "Rerty Word" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetNewWord (Ok word) ->
            ( { model | newWord = unwrapNewWordList word }, Cmd.none )

        GetNewWord (Err _) ->
            ( { model | title = "Server Error!" }, Cmd.none )

        GetAnotherWord ->
            ( { model | guessWord = "", result = "" }, initialCmd )

        KeyPressed string ->
            ( { model | guessWord = append model.guessWord (toUpper string) }, Cmd.none )

        EraseLetter word ->
            ( { model | guessWord = dropRight 1 word }, Cmd.none )

        SubmitWord guess check ->
            ( { model | result = checkResult guess (toUpper check) }, Cmd.none )

        ResetWord ->
            ( { model | guessWord = "", result = "" }, Cmd.none )


checkResult : GuessWord -> CheckWord -> String
checkResult guess check =
    if guess == check then
        "Congratulations :) " ++ guess ++ " is correct!"

    else if String.isEmpty guess then
        "Nope! An empty string isn't right.."

    else
        "Oh no :( " ++ guess ++ " isn't right."


nothingWord : NewWord
nothingWord =
    { word = "Nothing"
    , definition = "Nothing"
    , pronunciation = "Nothing"
    }


unwrapNewWordList : List NewWord -> NewWord
unwrapNewWordList wordsList =
    case List.head wordsList of
        Just word ->
            word

        Nothing ->
            nothingWord


newWordDecoder : Decoder NewWord
newWordDecoder =
    succeed NewWord
        |> required "word" string
        |> required "definition" string
        |> required "pronunciation" string


initialCmd : Cmd Msg
initialCmd =
    Http.get
        { url = randomWordAPIRequest
        , expect = Http.expectJson GetNewWord (list newWordDecoder)
        }


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
